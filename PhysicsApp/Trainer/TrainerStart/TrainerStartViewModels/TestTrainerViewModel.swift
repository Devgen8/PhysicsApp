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
    var isFirstTimeReading = false
    
    func getThemes(completion: @escaping (Bool) -> ()) {
        if let lastUpdateDate = UserDefaults.standard.value(forKey: "testsUpdateDate") as? Date,
            let weeksDifference = Calendar.current.dateComponents([.weekOfMonth], from: Date(), to: lastUpdateDate).weekOfMonth {
            if weeksDifference >= 1 {
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
                    }
                }
                completion(true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveTestsInCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                let egeTests = NSMutableSet()
                for test in tests {
                    let newTest = Test(context: context)
                    newTest.name = test
                    newTest.numberOfWrightAnswers = Int16(numbersOfWrightTasks[test] ?? 0)
                    egeTests.add(newTest)
                }
                trainer?.tests = egeTests

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
        return (Float(Float(numbersOfWrightTasks[testName] ?? 0) / Float(32)), 1.0)
    }
    
    // we do not need this functions for this view model
    func getUnsolvedTasksCount() -> Int {
         return 0
    }
    
    func getUnsolvedTasks() -> [String : [String]] {
        return [:]
    }
}
