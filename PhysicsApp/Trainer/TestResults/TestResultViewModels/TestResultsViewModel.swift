//
//  TestResultsViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 19.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import CoreData

class TestResultsViewModel: GeneralTestResultsViewModel {
    var testName = ""
    var timeTillEnd = 0
    var wrightAnswerNumber = 0
    var semiWrightAnswerNumber = 0
    var wrightAnswers = [String:(Double?, Double?, String?)]()
    var userAnswers = [String:String]()
    var answersCorrection = [Int]()
    var taskImages = [String:UIImage]()
    var taskDescriptions = [String:UIImage]()
    var openedCells = [Int]()
    var cPartPoints = [Int]()
    var tasksWithShuffle = [5,6,7,11,12,16,17,18,21]
    var resultPoints = [Int]()
    var hundredSystemPoints = 0
    var testPoints = 0
    var testAnswersUpdater: TestAnswersUpdater?
    let usersReference = Firestore.firestore().collection("users")
    var everyTaskAnswer = [Int]()
    
    func isCellOpened(index: Int) -> Bool {
        return openedCells.contains(index)
    }
    
    func closeCell(for index: Int) {
        openedCells = openedCells.filter( { $0 != index } )
    }
    
    func openCell(for index: Int) {
        openedCells.append(index)
    }
    
    func getTestDurationString() -> String {
        let allSeconds = 14100 - timeTillEnd
        var hours = "\(allSeconds / 3600)"
        if hours.count == 1 {
            hours = "0" + hours
        }
        var minutes = "\((allSeconds % 3600) / 60)"
        if minutes.count == 1 {
            minutes = "0" + minutes
        }
        var seconds = "\((allSeconds % 3600) % 60)"
        if seconds.count == 1 {
            seconds = "0" + seconds
        }
        return "\(hours) : \(minutes) : \(seconds)"
    }
    
    func getWrightAnswersNumberString() -> String {
        return "\(wrightAnswerNumber)"
    }
    
    func getImage(for taskName: String) -> UIImage? {
        return taskImages[taskName]
    }
    
    func getDescription(for taskName: String) -> UIImage? {
        return taskDescriptions[taskName]
    }
    
    func getUsersAnswer(for taskName: String) -> String? {
        return userAnswers[taskName]
    }
    
    func getTaskCorrection(for index: Int) -> Int {
        if answersCorrection.count <= index {
            return 0
        } else {
            return answersCorrection[index]
        }
    }
    
    func getUsersFinalPoints() -> Int {
        return hundredSystemPoints
    }
    
    func getUserPoints(for taskNumber: Int) -> String {
        if taskNumber < 26 {
            if resultPoints.count <= taskNumber {
                return ""
            } else {
                return "\(resultPoints[taskNumber])"
            }
        } else {
            return "\(cPartPoints[taskNumber - 26])"
        }
    }
    
    func getWrightAnswer(for index: Int) -> String {
        let taskName = "Задание №\(index)"
        if let (wrightAnswer, alternativeAnswer, stringAnswer) = wrightAnswers[taskName] {
            if stringAnswer != nil {
                return stringAnswer ?? "0"
            }
            if tasksWithShuffle.contains(index) {
                if  alternativeAnswer != nil, alternativeAnswer != 0.0 {
                    return "\(Int(wrightAnswer ?? 0.0)) или \(Int(alternativeAnswer ?? 0.0))"
                } else {
                    return "\(Int(wrightAnswer ?? 0.0))"
                }
            }
            if wrightAnswer != nil {
                return "\(wrightAnswer ?? 0)"
            }
        }
        return "0"
    }
    
    func updateTestCompletion() {
        var finishedTests = UserDefaults.standard.value(forKey: "finishedTests") as? [String] ?? []
        finishedTests = finishedTests.filter({ $0 != testName })
        UserDefaults.standard.set(finishedTests, forKey: "finishedTests")
    }
    
    func checkUserAnswers(completion: @escaping (Bool) -> ()) {
        updateTestCompletion()
        for index in 1...26 {
            let taskName = "Задание №\(index)"
            var isWright = 0
            if let (wrightAnswer, alternativeAnswer, stringAnswer) = wrightAnswers[taskName] {
                let defaultStringAnswer = userAnswers[taskName]?.replacingOccurrences(of: ",", with: ".")
                if let wrightAnswer = wrightAnswer, let userAnswer = Double(defaultStringAnswer ?? "") {
                    if index == 24 {
                        let userAnswerLetters = [Character]("\(Int(userAnswer))")
                        let wrightAnswerLetters = [Character]("\(Int(wrightAnswer))")
                        var mistakes = 0
                        for letterIndex in 0..<wrightAnswerLetters.count {
                            if alternativeAnswer != nil, alternativeAnswer != 0.0 {
                                if !userAnswerLetters.contains(wrightAnswerLetters[letterIndex]) {
                                    mistakes += 1
                                }
                            } else {
                                if userAnswerLetters.count > letterIndex, userAnswerLetters[letterIndex] != wrightAnswerLetters[letterIndex] {
                                    mistakes += 1
                                }
                            }
                        }
                        mistakes += abs(userAnswerLetters.count - wrightAnswerLetters.count)
                        if mistakes == 0 {
                            isWright = 2
                        } else if mistakes == 1 {
                            isWright = 1
                        } else {
                            isWright = 0
                        }
                    } else {
                        if tasksWithShuffle.contains(index) {
                            let userAnswerLetters = [Character]("\(Int(userAnswer))")
                            let wrightAnswerLetters = [Character]("\(Int(wrightAnswer))")
                            if userAnswerLetters.count - wrightAnswerLetters.count > 0 {
                                isWright = 0
                            } else {
                                var mistakes = wrightAnswerLetters.count - userAnswerLetters.count
                                for letterIndex in 0..<wrightAnswerLetters.count {
                                    if alternativeAnswer != nil, alternativeAnswer != 0.0 {
                                        if !userAnswerLetters.contains(wrightAnswerLetters[letterIndex]) {
                                            mistakes += 1
                                        }
                                    } else {
                                        if userAnswerLetters.count > letterIndex, userAnswerLetters[letterIndex] != wrightAnswerLetters[letterIndex] {
                                            mistakes += 1
                                        }
                                    }
                                }
                                if mistakes == 0 {
                                    isWright = 2
                                } else if mistakes == 1 {
                                    isWright = 1
                                } else {
                                    isWright = 0
                                }
                            }
                        } else {
                            isWright = wrightAnswer == userAnswer ? 2 : 0
                        }
                    }
                }
                if let wrightAnswer = stringAnswer, let userAnswer = defaultStringAnswer {
                    isWright = wrightAnswer == userAnswer ? 2 : 0
                }
                answersCorrection.append(isWright)
                if isWright == 2 {
                    wrightAnswerNumber += 1
                }
                if isWright == 1 {
                    semiWrightAnswerNumber += 1
                }
                if EGEInfo.advancedTasks.contains(index), index != 25 && index != 26  {
                    resultPoints.append(isWright)
                } else {
                    resultPoints.append(isWright == 2 ? 1 : 0)
                }
            }
        }
        hundredSystemPoints = getHundredSystemPoints()
        setTestDataInFirestore()
        completion(true)
    }
    
    func setTestDataInFirestore() {
        if let userId = Auth.auth().currentUser?.uid {
            var tasksNames = [String]()
            var wrightAnswerStrings = [String]()
            for index in 1...32 {
                tasksNames.append("Задание №\(index)")
                wrightAnswerStrings.append(getWrightAnswer(for: index))
            }
            saveTestResultsInCoreData()
            usersReference.document(userId).collection("testsHistory").document(testName).setData(["name":testName,
                                                                                                   "wrightAnswerNumber":wrightAnswerNumber,
                                                                                                   "semiWrightAnswerNumber":semiWrightAnswerNumber,
                                                                                                   "userAnswers":userAnswers,
                                                                                                   "points":hundredSystemPoints,
                                                                                                   "answersCorrection":answersCorrection,
                                                                                                   "timeTillEnd":timeTillEnd,
                                                                                                   "tasksNames":tasksNames,
                                                                                                   "wrightAnswers":wrightAnswerStrings,
                                                                                                   "primaryPoints":everyTaskAnswer,
                                                                                                   "date":Date()])
        }
    }
    
    func saveTestResultsInCoreData() {
        if Auth.auth().currentUser?.uid != nil, let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<TestsHistory> = TestsHistory.fetchRequest()
                let result = try context.fetch(fechRequest)
                let testsHistory = result.first ?? TestsHistory(context: context)
                let testsCopy = testsHistory.tests?.mutableCopy() as! NSMutableOrderedSet
                let testResults = TestsResults(context: context)
                testResults.name = testName
                testResults.wrightAnswerNumber = Int16(wrightAnswerNumber)
                testResults.semiWrightAnswerNumber = Int16(semiWrightAnswerNumber)
                testResults.points = Int16(hundredSystemPoints)
                testResults.timeTillEnd = Int16(timeTillEnd)
                var tasksNames = [String]()
                var wrightAnswerStrings = [String]()
                for index in 1...32 {
                    tasksNames.append("Задание №\(index)")
                    wrightAnswerStrings.append(getWrightAnswer(for: index))
                }
                testResults.testResultObject = TestsResultsObject(userAnswers: userAnswers,
                                                                  answersCorrection: answersCorrection,
                                                                  tasksNames: tasksNames,
                                                                  wrightAnswers: wrightAnswerStrings,
                                                                  primaryPoints: everyTaskAnswer)
                var index = -1
                var count = 0
                for oldTest in testsCopy {
                    if (oldTest as! TestsResults).name == testResults.name {
                        index = count
                        break
                    }
                    count += 1
                }
                if index != -1 {
                    testsCopy.removeObject(at: index)
                }
                testsCopy.add(testResults)
                testsHistory.tests = testsCopy
                
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getHundredSystemPoints() -> Int {
        var primaryPoints = 0
        resultPoints.forEach({ primaryPoints += $0; everyTaskAnswer.append($0) })
        var index = 0
        for rowNumber in 26..<26 + cPartPoints.count {
            primaryPoints += cPartPoints[index]
            everyTaskAnswer.append(cPartPoints[index])
            if rowNumber + 1 == 28 {
                answersCorrection.append(cPartPoints[1])
                if cPartPoints[1] == 2 {
                    wrightAnswerNumber += 1
                }
                if cPartPoints[1] == 1 {
                    semiWrightAnswerNumber += 1
                }
            } else {
                if cPartPoints[rowNumber - 26] == 3 {
                    answersCorrection.append(2)
                    wrightAnswerNumber += 1
                } else if cPartPoints[rowNumber - 26] == 0 {
                    answersCorrection.append(0)
                } else {
                    answersCorrection.append(1)
                    semiWrightAnswerNumber += 1
                }
            }
            index += 1
        }
        testPoints = EGEInfo.hundredSystem[primaryPoints]
        return testPoints
    }
    
    func updateTestDataAsDone() {
        testAnswersUpdater?.deleteTestsAnswers()
        updateTestDataInCoreData()
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).collection("stats").document(testName).setData(["name":testName,"doneTasks":wrightAnswerNumber, "points":testPoints, "semiDoneTasks":semiWrightAnswerNumber])
        }
    }
    
    func updateTestDataInCoreData() {
        if Auth.auth().currentUser?.uid != nil, let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                (trainer?.tests?.first(where: { ($0 as! Test).name == testName }) as! Test).numberOfWrightAnswers = Int16(wrightAnswerNumber)
                (trainer?.tests?.first(where: { ($0 as! Test).name == testName }) as! Test).points = Int16(testPoints)
                (trainer?.tests?.first(where: { ($0 as! Test).name == testName }) as! Test).numberOfSemiWrightAnswers = Int16(semiWrightAnswerNumber)
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getColorPercentage() -> (Float, Float) {
        let greenPercentage = Float(wrightAnswerNumber) / Float(32)
        let yellowPercentage = Float(semiWrightAnswerNumber) / Float(32) + greenPercentage
        return (greenPercentage, yellowPercentage)
    }
}
