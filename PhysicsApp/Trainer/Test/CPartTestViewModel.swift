//
//  CPartTestViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 04.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class CPartTestViewModel {
    var tasks = [TaskModel]()
    var cPartTasks = ["Задание №27", "Задание №28", "Задание №29", "Задание №30", "Задание №31", "Задание №32"]
    var timeTillEnd = 0
    var wrightAnswers = [String:(Double?, Double?, String?)]()
    var testAnswers = [String:String]()
    var tasksImages = [String:UIImage]()
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
        return tasks.first(where: { $0.name == cPartTasks[index] })?.taskDescription ?? UIImage()
    }
    
    func transportData(to viewModel: TestResultsViewModel) {
        viewModel.timeTillEnd = timeTillEnd
        viewModel.wrightAnswers = wrightAnswers
        viewModel.userAnswers = testAnswers
        viewModel.taskImages = tasksImages
        viewModel.testName = name
        viewModel.cPartPoints = tasksPoints
        viewModel.testAnswersUpdater = testAnswersUpdater
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
