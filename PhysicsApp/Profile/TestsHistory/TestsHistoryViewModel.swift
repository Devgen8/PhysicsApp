//
//  TestsHistoryViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 14.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreData

class TestsHistoryViewModel {
    
    let usersReference = Firestore.firestore().collection("users")
    var testsNames = [String]()
    var answersCorrections = [String:[Int]]()
    var points = [String:Int]()
    var semiWrightAnswersNumbers = [String:Int]()
    var wrightAnswersNumbers = [String:Int]()
    var tasks = [String:[String]]()
    var time = [String:Int]()
    var userAnswers = [String:[String:String]]()
    var wrightAnswers = [String:[String]]()
    var primaryPoints = [String:[Int]]()
    
    func getTests(completion: @escaping (Bool) -> ()) {
        if (UserDefaults.standard.value(forKey: "isTestHistoryRead") as? Bool) == nil {
            getHistoryFromFirestore { (isReady) in
                completion(isReady)
            }
        } else {
            getHistoryFromCoreData { (isReady) in
                completion(isReady)
            }
        }
    }
    
    func getHistoryFromFirestore(completion: @escaping (Bool) -> ()) {
        if let userId = Auth.auth().currentUser?.uid {
            usersReference.document(userId).collection("testsHistory").order(by: "date", descending: true).getDocuments { (snapshot, error) in
                guard error == nil, let documents = snapshot?.documents else {
                    print("error reading tests history: \(String(describing: error?.localizedDescription))")
                    return
                }
                for document in documents {
                    if let name = document.data()["name"] as? String {
                        self.testsNames.append(name)
                        self.answersCorrections[name] = document.data()["answersCorrection"] as? [Int]
                        self.points[name] = document.data()["points"] as? Int
                        self.semiWrightAnswersNumbers[name] = document.data()["semiWrightAnswerNumber"] as? Int
                        self.tasks[name] = document.data()["tasksNames"] as? [String]
                        self.time[name] = document.data()["timeTillEnd"] as? Int
                        self.userAnswers[name] = document.data()["userAnswers"] as? [String:String]
                        self.wrightAnswers[name] = document.data()["wrightAnswers"] as? [String]
                        self.wrightAnswersNumbers[name] = document.data()["wrightAnswerNumber"] as? Int
                        self.primaryPoints[name] = document.data()["primaryPoints"] as? [Int]
                    }
                }
                completion(true)
            }
        }
        saveTestsHistoryInCoreData()
        updateKey()
    }
    
    func saveTestsHistoryInCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<TestsHistory> = TestsHistory.fetchRequest()
                let result = try context.fetch(fechRequest)
                let testsHistory = result.first ?? TestsHistory(context: context)
                let testsCopy = NSMutableOrderedSet()
                for testName in testsNames {
                    let testResults = TestsResults(context: context)
                    testResults.name = testName
                    testResults.wrightAnswerNumber = Int16(wrightAnswersNumbers[testName] ?? 0)
                    testResults.semiWrightAnswerNumber = Int16(semiWrightAnswersNumbers[testName] ?? 0)
                    testResults.points = Int16(points[testName] ?? 0)
                    testResults.timeTillEnd = Int16(time[testName] ?? 0)
                    testResults.testResultObject = TestsResultsObject(userAnswers: userAnswers[testName] ?? [:],
                                                                      answersCorrection: answersCorrections[testName] ?? [],
                                                                      tasksNames: tasks[testName] ?? [],
                                                                      wrightAnswers: wrightAnswers[testName] ?? [],
                                                                      primaryPoints: primaryPoints[testName] ?? [])
                    testsCopy.add(testResults)
                }
                testsHistory.tests = testsCopy
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getHistoryFromCoreData(completion: @escaping (Bool) -> ()) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<TestsHistory> = TestsHistory.fetchRequest()
                let result = try context.fetch(fechRequest)
                let testsHistory = result.first ?? TestsHistory(context: context)
                var testsCopy = NSOrderedSet()
                if testsHistory.tests != nil {
                    testsCopy = testsHistory.tests?.mutableCopy() as! NSOrderedSet
                }
                for coreTest in testsCopy {
                    let testName = (coreTest as! TestsResults).name ?? ""
                    testsNames.append(testName)
                    wrightAnswersNumbers[testName] = Int((coreTest as! TestsResults).wrightAnswerNumber)
                    semiWrightAnswersNumbers[testName] = Int((coreTest as! TestsResults).semiWrightAnswerNumber)
                    points[testName] = Int((coreTest as! TestsResults).points)
                    time[testName] = Int((coreTest as! TestsResults).timeTillEnd)
                    let resultsObject = (coreTest as! TestsResults).testResultObject as! TestsResultsObject
                    userAnswers[testName] = resultsObject.userAnswers
                    answersCorrections[testName] = resultsObject.answersCorrection
                    wrightAnswers[testName] = resultsObject.wrightAnswers
                    primaryPoints[testName] = resultsObject.primaryPoints
                    tasks[testName] = resultsObject.tasksNames
                }
                completion(true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateKey() {
        UserDefaults.standard.set(true, forKey: "isTestHistoryRead")
    }
    
    func getTestsNumber() -> Int {
        return testsNames.count
    }
    
    func getTestName(for row: Int) -> String {
        return "\(testsNames[row]) (\(points[testsNames[row]] ?? 0) б.)"
    }
    
    func getTasksProgress(for row: Int) -> (Float, Float) {
        let testName = testsNames[row]
        let success = Float(Float(wrightAnswersNumbers[testName] ?? 0) / Float(32))
        let semiSuccess = Float(Float(semiWrightAnswersNumbers[testName] ?? 0) / Float(32)) + success
        return (success, semiSuccess)
    }
    
    func transportData(to viewModel: TestsHistoryResultsViewModel, for index: Int) {
        let name = testsNames[index]
        viewModel.testName = name
        viewModel.answersCorrection = answersCorrections[name] ?? []
        viewModel.points = points[name] ?? 0
        viewModel.semiWrightAnswerNumber = semiWrightAnswersNumbers[name] ?? 0
        viewModel.wrightAnswerNumber = wrightAnswersNumbers[name] ?? 0
        viewModel.tasks = tasks[name] ?? []
        viewModel.timeTillEnd = time[name] ?? 0
        viewModel.userAnswers = userAnswers[name] ?? [:]
        viewModel.realWrightAnswers = wrightAnswers[name] ?? []
        viewModel.primaryPoints = primaryPoints[name] ?? []
    }
}
