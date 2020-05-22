//
//  TestTrainerViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 16.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreData

class TestTrainerViewModel: TrainerViewModelProvider {
    
    let testReference = Firestore.firestore().collection("tests")
    var tests = [String]()
    var numbersOfWrightTasks = [String:Int]()
    var numbersOfSemiWrightTasks = [String:Int]()
    var testsPoints = [String:Int]()
    var primarySystem = [String:Int]()
    var hundredSystem = [String:Int]()
    var isFirstTimeReading = false
    
    func getThemes(completion: @escaping (Bool) -> ()) {
        if let lastUpdateDate = UserDefaults.standard.value(forKey: "testsUpdateDate") as? Date,
            let weeksDifference = Calendar.current.dateComponents([.weekOfMonth], from: Date(), to: lastUpdateDate).weekOfMonth {
            let formater = DateFormatter()
            let weekday = formater.weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1]
            formater.dateFormat = "dd-MM-yyyy"
            let oldDate = formater.string(from: lastUpdateDate)
            let todayDate = formater.string(from: Date())
            if (weeksDifference >= 1 || weekday == "Monday") && oldDate != todayDate {
                getTestsFromFirestore { (isReady) in
                    completion(isReady)
                }
            } else {
                getTestsFromCoreData { (isReady) in
                    completion(isReady)
                }
            }
        } else {
            isFirstTimeReading = true
            getTestsFromFirestore { (isReady) in
                completion(isReady)
            }
        }
    }
    
    func getTestsFromCoreData(completion: @escaping (Bool) -> ()) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()

            do {
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                if let egeTests = trainer?.tests {
                    let sortedEgeTests = egeTests.sorted { (firstTheme, secondTheme) in
                        if let firstName = (firstTheme as! Test).name,
                            let secondName = (secondTheme as! Test).name {
                            return firstName > secondName
                        }
                        return true
                    }
                    tests = []
                    for test in sortedEgeTests {
                        let egeTest = (test as! Test)
                        tests.append(egeTest.name ?? "")
                        numbersOfWrightTasks[egeTest.name ?? ""] = Int(egeTest.numberOfWrightAnswers)
                        testsPoints[egeTest.name ?? ""] = Int(egeTest.points)
                        numbersOfSemiWrightTasks[egeTest.name ?? ""] = Int(egeTest.numberOfSemiWrightAnswers)
                    }
                }
                completion(true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func isTestCustom(_ testName: String) -> Bool {
        if testName.count < 7 {
            return false
        } else {
            var charsArray = [Character]()
            var index = 0
            for letter in testName {
                charsArray.append(letter)
                index += 1
                if index == 7 {
                    break
                }
            }
            if String(charsArray) == "Пробник" {
                return true
            } else {
                return false
            }
        }
    }
    
    func saveTestsInCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                let oldTests = trainer?.tests?.mutableCopy() as? NSMutableSet
                let egeTests = NSMutableSet()
                for test in tests {
                    if oldTests?.first(where: { ($0 as! Test).name == test }) == nil {
                        let newTest = Test(context: context)
                        newTest.name = test
                        newTest.numberOfWrightAnswers = Int16(numbersOfWrightTasks[test] ?? 0)
                        newTest.numberOfSemiWrightAnswers = Int16(numbersOfSemiWrightTasks[test] ?? 0)
                        newTest.points = Int16(testsPoints[test] ?? 0)
                        egeTests.add(newTest)
                    }
                }
                for oldTest in oldTests ?? NSMutableSet() {
                    egeTests.add(oldTest)
                }
                trainer?.tests = egeTests
                trainer?.testParameters = TestParametersObject(primarySystem: primarySystem, hundredSystem: hundredSystem)

                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateKeysInfo() {
        UserDefaults.standard.set(Date(), forKey: "testsUpdateDate")
        UserDefaults.standard.set(tests, forKey: "notUpdatedTests")
    }
    
    func getTestsFromFirestore(completion: @escaping (Bool) -> ()) {
        testReference.getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                print("Error reading tests: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            self.tests = []
            for document in documents {
                if let testName = document.data()["name"] as? String {
                    self.tests.append(testName)
                }
            }
            self.checkTestsAccessibility { (isReady) in
                completion(true)
            }
        }
    }
    
    func checkTestsAccessibility(completion: @escaping (Bool) -> ()) {
        var index = 0
        let testsNumber = tests.count
        for test in tests {
            testReference.document(test).collection("tasks").getDocuments { [weak self] (snapshot, error) in
                guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                    print("Error reading tasks number in each test: \(String(describing: error?.localizedDescription))")
                    completion(false)
                    return
                }
                if documents.count != 32 {
                    self.tests = self.tests.filter({ $0 != test })
                }
                index += 1
                if index == testsNumber {
                    self.getEgeData { (isReady) in
                        completion(isReady)
                    }
                }
            }
        }
    }
    
    func getEgeData(completion: @escaping (Bool) -> ()) {
        var index = 1
        for points in EGEInfo.primarySystem {
            primarySystem["Задание №\(index)"] = points
            index += 1
        }
        index = 0
        for points in EGEInfo.hundredSystem {
            hundredSystem["\(index)"] = points
            index += 1
        }
        if self.isFirstTimeReading {
            self.getUsersStats { (isReady) in
                completion(isReady)
            }
        } else {
            self.saveTestsInCoreData()
            self.updateKeysInfo()
            self.getTestsFromCoreData { (isReady) in
                completion(isReady)
            }
        }
    }
    
    func getUsersStats(completion: @escaping (Bool) -> ()) {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).collection("stats").getDocuments { (snapshot, error) in
                guard error == nil, let documents = snapshot?.documents else {
                    return
                }
                for document in documents {
                    if let name = document.data()["name"] as? String {
                        self.numbersOfWrightTasks[name] = document.data()["doneTasks"] as? Int ?? 0
                        self.testsPoints[name] = document.data()["points"] as? Int ?? 0
                        self.numbersOfSemiWrightTasks[name] = document.data()["semiDoneTasks"] as? Int ?? 0
                    }
                }
                self.saveTestsInCoreData()
                self.updateKeysInfo()
                completion(true)
            }
        }
    }
    
    func getThemesCount() -> Int {
        return tests.count
    }
    
    func getTheme(for index: Int) -> String {
        return tests[index]
    }
    
    func getTasksProgress(for index: Int) -> (Float, Float) {
        let testName = tests[index]
        let success = Float(Float(numbersOfWrightTasks[testName] ?? 0) / Float(32))
        let semiSuccess = Float(Float(numbersOfSemiWrightTasks[testName] ?? 0) / Float(32)) + success
        return (success, semiSuccess)
    }
    
    func getTestPoints(for index: Int) -> Int {
        let testName = tests[index]
        return testsPoints[testName] ?? 0
    }
    
    // we do not need this functions for this view model
    func getUnsolvedTasksCount() -> Int {
         return 0
    }
    
    func getUnsolvedTasks() -> [String : [String]] {
        return [:]
    }
}
