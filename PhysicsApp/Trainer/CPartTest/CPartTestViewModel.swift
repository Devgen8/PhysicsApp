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
    
    //MARK: Fields
    
    private var tasks = [TaskModel]()
    private var cPartTasks = ["Задание №27", "Задание №28", "Задание №29", "Задание №30", "Задание №31", "Задание №32"]
    private var timeTillEnd = 0
    private var wrightAnswers = [String:(String?, Bool?)]()
    private var testAnswers = [String:String]()
    private var tasksImages = [String:UIImage]()
    private var tasksDescriptions = [String:UIImage]()
    private var name = ""
    private var tasksPoints = [0,0,0,0,0,0]
    
    var testAnswersUpdater: TestAnswersUpdater?
    
    //MARK: Interface
    
    func setName(_ newName: String) {
        name = newName
    }
    
    func setTimeTillEnd(_ newTime: Int) {
        timeTillEnd = newTime
    }
    
    func setwrightAnswers(_ newAnswers: [String:(String?, Bool?)]) {
        wrightAnswers = newAnswers
    }
    
    func setTestAnswers(_ newAnswers: [String:String]) {
        testAnswers = newAnswers
    }
    
    func setTasksImages(_ newImages: [String:UIImage]) {
        tasksImages = newImages
    }
    
    func setTasks(_ newTasks: [TaskModel]) {
        tasks = newTasks
    }
    
    func setTasksDescriptions(_ newDescriptions: [String:UIImage]) {
        tasksDescriptions = newDescriptions
    }
    
    func getNumberOfDescriptions() -> Int {
        return cPartTasks.count
    }
    
    func getTaskName(for index: Int) -> String {
        return cPartTasks[index]
    }
    
    func getName() -> String {
        return name
    }
    
    func getDescriptionImage(for index: Int) -> UIImage {
        return tasks.first(where: {
            if NamesParser.isTestCustom(name) {
                return NamesParser.getTaskLocation(taskName: $0.name ?? "").0 == cPartTasks[index]
            } else {
                return $0.name == cPartTasks[index]
            }
            })?.taskDescription ?? UIImage()
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
            (viewModel as! CustomTestResultViewModel).setTasks(tasks)
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
        if !finishedTests.contains(name) {
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
