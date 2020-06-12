//
//  CPartTestViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 04.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import FirebaseAuth

class CPartTestViewModel {
    var tasks = [TaskModel]()
    var cPartTasks = ["Задание №27", "Задание №28", "Задание №29", "Задание №30", "Задание №31", "Задание №32"]
    var timeTillEnd = 0
    var wrightAnswers = [String:(Double?, Double?, String?)]()
    var testAnswers = [String:String]()
    var tasksImages = [String:UIImage]()
    var tasksDescriptions = [String:UIImage]()
    var name = ""
    var tasksPoints = [0,0,0,0,0,0]
    var testAnswersUpdater: TestAnswersUpdater?
    
    func getNumberOfDescriptions() -> Int {
        return cPartTasks.count
    }
    
    func getTaskName(for index: Int) -> String {
        return cPartTasks[index]
    }
    
    func getDescriptionImage(for index: Int) -> UIImage {
        return tasks.first(where: {
            if isTestCustom() {
                return getTaskLocation(taskName: $0.name ?? "").0 == cPartTasks[index]
            } else {
                return $0.name == cPartTasks[index]
            }
            })?.taskDescription ?? UIImage()
    }
    
    func isTestCustom() -> Bool {
        if name.count < 7 {
            return false
        } else {
            var charsArray = [Character]()
            var index = 0
            for letter in name {
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
    
    func getTaskLocation(taskName: String) -> (String, String) {
        var themeNameSet = [Character]()
        var taskNumberSet = [Character]()
        var isDotFound = false
        for letter in taskName {
            if letter == "." {
                isDotFound = true
                continue
            }
            if isDotFound {
                taskNumberSet.append(letter)
            } else {
                themeNameSet.append(letter)
            }
        }
        let themeName = String(themeNameSet)
        let taskNumber = String(taskNumberSet)
        return (themeName, taskNumber)
    }
    
    func transportData(to viewModel: GeneralTestResultsViewModel) {
        if viewModel is CustomTestResultViewModel {
            (viewModel as! CustomTestResultViewModel).timeTillEnd = timeTillEnd
            (viewModel as! CustomTestResultViewModel).wrightAnswers = wrightAnswers
            (viewModel as! CustomTestResultViewModel).userAnswers = testAnswers
            (viewModel as! CustomTestResultViewModel).taskImages = tasksImages
            (viewModel as! CustomTestResultViewModel).testName = name
            (viewModel as! CustomTestResultViewModel).cPartPoints = tasksPoints
            (viewModel as! CustomTestResultViewModel).testAnswersUpdater = testAnswersUpdater
            (viewModel as! CustomTestResultViewModel).tasks = tasks
        }
        if viewModel is TestResultsViewModel {
            (viewModel as! TestResultsViewModel).timeTillEnd = timeTillEnd
            (viewModel as! TestResultsViewModel).wrightAnswers = wrightAnswers
            (viewModel as! TestResultsViewModel).userAnswers = testAnswers
            (viewModel as! TestResultsViewModel).taskImages = tasksImages
            (viewModel as! TestResultsViewModel).testName = name
            (viewModel as! TestResultsViewModel).cPartPoints = tasksPoints
            (viewModel as! TestResultsViewModel).testAnswersUpdater = testAnswersUpdater
            (viewModel as! TestResultsViewModel).taskDescriptions = tasksDescriptions
        }
    }
    
    func saveTestCompletion() {
        var finishedTests = UserDefaults.standard.value(forKey: "finishedTests") as? [String] ?? []
        if Auth.auth().currentUser?.uid != nil, !finishedTests.contains(name) {
            finishedTests.append(name)
        }
        UserDefaults.standard.set(finishedTests, forKey: "finishedTests")
    }
}

extension CPartTestViewModel: CPartPointsUpdater {
    func updatePoints(for index: Int, with points: Int) {
        tasksPoints[index] = points
    }
}
