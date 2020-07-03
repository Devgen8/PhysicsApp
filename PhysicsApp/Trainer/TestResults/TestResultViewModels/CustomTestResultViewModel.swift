//
//  CustomTestResultViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 13.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import CoreData
import FirebaseFirestore
import FirebaseAuth

class CustomTestResultViewModel: GeneralTestResultsViewModel {
    
    //MARK: Fields
    
    private var openedCells = [Int]()
    private var tasks = [TaskModel]()
    private var tasksWithShuffle = [5,6,7,11,12,16,17,18,21]
    private var wrightAnswerNumber = 0
    private var semiWrightAnswerNumber = 0
    private var answersCorrection = [Int]()
    private var resultPoints = [Int]()
    private var hundredSystemPoints = 0
    private var testPoints = 0
    private let usersReference = Firestore.firestore().collection("users")
    private var everyTaskAnswer = [Int]()
    
    var timeTillEnd = 0
    var wrightAnswers = [String : (Double?, Double?, String?)]()
    var userAnswers = [String : String]()
    var taskImages = [String : UIImage]()
    var testName = ""
    var cPartPoints = [Int]()
    var testAnswersUpdater: TestAnswersUpdater?
    
    //MARK: Interface
    
    func checkUserAnswers(completion: @escaping (Bool) -> ()) {
        updateTestCompletion()
        for index in 1...26 {
            let taskName = tasks[index - 1].name ?? ""
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
        updateTasksStatus()
        completion(true)
    }
    
    func updateTestDataAsDone() {
        if Auth.auth().currentUser?.uid != nil, let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
            
            do {
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                context.delete(trainer?.tests?.first(where: {($0 as! Test).name == testName}) as! NSManagedObject)
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func isCellOpened(index: Int) -> Bool {
        return openedCells.contains(index)
    }
    
    func closeCell(for index: Int) {
        openedCells = openedCells.filter( { $0 != index } )
    }
    
    func openCell(for index: Int) {
        openedCells.append(index)
    }
    
    func setTasks(_ newTasks: [TaskModel]) {
        tasks = newTasks
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
        return taskImages[getParticulerTaskName(for: taskName)]
    }
    
    func getDescription(for taskName: String) -> UIImage? {
        return tasks.first(where: { getParticulerTaskName(for: taskName) == $0.name })?.taskDescription
    }
    
    func getUsersAnswer(for taskName: String) -> String? {
        return userAnswers[getParticulerTaskName(for: taskName)]
    }
    
    func getParticulerTaskName(for name: String) -> String {
        return tasks.first(where: { NamesParser.getTaskLocation(taskName: $0.name ?? "").0 == name })?.name ?? ""
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
    
    func getColorPercentage() -> (Float, Float) {
        let greenPercentage = Float(wrightAnswerNumber) / Float(32)
        let yellowPercentage = Float(semiWrightAnswerNumber) / Float(32) + greenPercentage
        return (greenPercentage, yellowPercentage)
    }
    
    func getWrightAnswer(for index: Int) -> String {
        let taskName = getParticulerTaskName(for: "Задание №\(index)")
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
    
    //MARK: Private section
    
    private func updateTestCompletion() {
        var finishedTests = UserDefaults.standard.value(forKey: "finishedTests") as? [String] ?? []
        finishedTests = finishedTests.filter({ $0 != testName })
        UserDefaults.standard.set(finishedTests, forKey: "finishedTests")
    }
    
    private func updateTasksStatus() {
        if Auth.auth().currentUser?.uid != nil, let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<User> = User.fetchRequest()
                let result = try context.fetch(fechRequest)
                let user = result.first
                var newFirstTryTasks = (user?.solvedTasks as! StatusTasks).firstTryTasks
                var coreDataUnsolved = (user?.solvedTasks as! StatusTasks).unsolvedTasks
                var coreDataSolved = (user?.solvedTasks as! StatusTasks).solvedTasks
                var taskIndex = 1
                for task in tasks {
                    if taskIndex > 26 {
                        if let stringAnswer = task.stringAnswer {
                            if stringAnswer == userAnswers["Задание №\(taskIndex)"] {
                                if !isTaskAlreadySeen(taskName: task.name ?? "", solvedTasks: coreDataSolved, unsolvedTasks: coreDataUnsolved) {
                                    newFirstTryTasks.append(task.name ?? "")
                                    coreDataSolved = addTask(task.name ?? "", to: coreDataSolved, category: "Задание №\(taskIndex)")
                                } else {
                                    coreDataUnsolved = deleteTask(task.name ?? "", to: coreDataUnsolved, category: "Задание №\(taskIndex)")
                                    coreDataSolved = addTask(task.name ?? "", to: coreDataSolved, category: "Задание №\(taskIndex)")
                                }
                            } else {
                                if isTaskAlreadySeen(taskName: task.name ?? "", solvedTasks: coreDataSolved, unsolvedTasks: coreDataUnsolved) {
                                    coreDataSolved = deleteTask(task.name ?? "", to: coreDataSolved, category: "Задание №\(taskIndex)")
                                }
                                coreDataUnsolved = addTask(task.name ?? "", to: coreDataUnsolved, category: "Задание №\(taskIndex)")
                            }
                        } else {
                            if task.wrightAnswer == Double(userAnswers["Задание №\(taskIndex)"] ?? "") {
                                if !isTaskAlreadySeen(taskName: task.name ?? "", solvedTasks: coreDataSolved, unsolvedTasks: coreDataUnsolved) {
                                    newFirstTryTasks.append(task.name ?? "")
                                    coreDataSolved = addTask(task.name ?? "", to: coreDataSolved, category: "Задание №\(taskIndex)")
                                } else {
                                    coreDataUnsolved = deleteTask(task.name ?? "", to: coreDataUnsolved, category: "Задание №\(taskIndex)")
                                    coreDataSolved = addTask(task.name ?? "", to: coreDataSolved, category: "Задание №\(taskIndex)")
                                }
                            } else {
                                if isTaskAlreadySeen(taskName: task.name ?? "", solvedTasks: coreDataSolved, unsolvedTasks: coreDataUnsolved) {
                                    coreDataSolved = deleteTask(task.name ?? "", to: coreDataSolved, category: "Задание №\(taskIndex)")
                                }
                                coreDataUnsolved = addTask(task.name ?? "", to: coreDataUnsolved, category: "Задание №\(taskIndex)")
                            }
                        }
                    } else {
                        if answersCorrection[taskIndex - 1] == 2 {
                            if !isTaskAlreadySeen(taskName: task.name ?? "", solvedTasks: coreDataSolved, unsolvedTasks: coreDataUnsolved) {
                                newFirstTryTasks.append(task.name ?? "")
                                coreDataSolved = addTask(task.name ?? "", to: coreDataSolved, category: "Задание №\(taskIndex)")
                            } else {
                                coreDataUnsolved = deleteTask(task.name ?? "", to: coreDataUnsolved, category: "Задание №\(taskIndex)")
                                coreDataSolved = addTask(task.name ?? "", to: coreDataSolved, category: "Задание №\(taskIndex)")
                            }
                        } else {
                            if isTaskAlreadySeen(taskName: task.name ?? "", solvedTasks: coreDataSolved, unsolvedTasks: coreDataUnsolved) {
                                coreDataSolved = deleteTask(task.name ?? "", to: coreDataSolved, category: "Задание №\(taskIndex)")
                            }
                            coreDataUnsolved = addTask(task.name ?? "", to: coreDataUnsolved, category: "Задание №\(taskIndex)")
                        }
                    }
                    taskIndex += 1
                }
                user?.solvedTasks = StatusTasks(solvedTasks: coreDataSolved, unsolvedTasks: coreDataUnsolved, firstTryTasks: newFirstTryTasks)
                setTestDataInFirestore(solvedTasks: coreDataSolved, unsolvedTasks: coreDataUnsolved, firstTryTasks: newFirstTryTasks)
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func addTask(_ taskName: String, to statusTasks: [String:[String]], category: String) -> [String:[String]] {
        var newStatusTasks = statusTasks
        if let foundTasks = newStatusTasks[category] {
            if !foundTasks.contains(taskName) {
                newStatusTasks[category]?.append(taskName)
            }
        } else {
            newStatusTasks[category] = [taskName]
        }
        return newStatusTasks
    }
    
    private func deleteTask(_ taskName: String, to statusTasks: [String:[String]], category: String) -> [String:[String]] {
        var newStatusTasks = statusTasks
        if newStatusTasks[category]?.contains(taskName) ?? false {
            newStatusTasks[category] = statusTasks[category]?.filter({ $0 != taskName })
        }
        return newStatusTasks
    }
    
    private func isTaskAlreadySeen(taskName: String, solvedTasks: [String:[String]], unsolvedTasks: [String:[String]]) -> Bool {
        let (themeName, _) = NamesParser.getTaskLocation(taskName: taskName)
        if !(solvedTasks[themeName]?.contains(taskName) ?? false) && !(unsolvedTasks[themeName]?.contains(taskName) ?? false) {
            return false
        } else {
            return true
        }
    }
    
    // Firestore
    
    private func setTestDataInFirestore(solvedTasks: [String:[String]], unsolvedTasks: [String:[String]], firstTryTasks: [String]) {
        if let userId = Auth.auth().currentUser?.uid {
            usersReference.document(userId).updateData(["unsolvedTasks" : unsolvedTasks,
                                                     "solvedTasks" : solvedTasks,
                                                     "firstTryTasks" : firstTryTasks])
            var tasksNames = [String]()
            var wrightAnswerStrings = [String]()
            var index = 0
            for task in tasks {
                tasksNames.append(task.name ?? "")
                wrightAnswerStrings.append(getWrightAnswer(for: index + 1))
                index += 1
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
    
    // Core Data
    
    private func saveTestResultsInCoreData() {
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
                var index = 0
                for task in tasks {
                    tasksNames.append(task.name ?? "")
                    wrightAnswerStrings.append(getWrightAnswer(for: index + 1))
                    index += 1
                }
                testResults.testResultObject = TestsResultsObject(userAnswers: userAnswers, answersCorrection: answersCorrection, tasksNames: tasksNames, wrightAnswers: wrightAnswerStrings, primaryPoints: everyTaskAnswer)
                testsCopy.add(testResults)
                testsHistory.tests = testsCopy
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func getHundredSystemPoints() -> Int {
        var primaryPoints = 0
        resultPoints.forEach({ primaryPoints += $0; everyTaskAnswer.append($0)})
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
}
