//
//  CustomProtocols.swift
//  TrainingApp
//
//  Created by мак on 16/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation

protocol UnsolvedTaskUpdater {
    func updateUnsolvedTasks(with unsolvedTasks: [String:[String]], and solvedTasks: [String:[String]]?)
}

protocol DataConstructer {
    var unsolvedTasks: [String:[String]] { set get }
    func constructData(for row: Int) -> String
    func getItemsCount() -> Int
}

protocol MixViewModel {
    var mixName: String? { set get }
    func getNumberOfTasks() ->  Int
    func prepareUserTasks(completion: @escaping (Bool) -> ())
    func getTaskName(for index: Int) -> String
    func transportData(for viewModel: TaskViewModel, at index: Int)
    func isTaskSolved(for index: Int) -> Bool
    func getUsersName(completion: @escaping (String?) -> ())
}

protocol TrainerViewModelProvider {
    func getThemes(completion: @escaping (Bool) -> ())
    func getThemesCount() -> Int
    func getTheme(for index: Int) -> String
    func getTasksProgress(for index: Int) -> (Float, Float)
    func getUnsolvedTasksCount() -> Int
    func getUnsolvedTasks() -> [String:[String]]
}
