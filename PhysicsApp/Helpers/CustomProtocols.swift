//
//  CustomProtocols.swift
//  TrainingApp
//
//  Created by мак on 16/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

protocol UnsolvedTaskUpdater {
    func updateUnsolvedTasks(with unsolvedTasks: [String:[String]], and solvedTasks: [String:[String]]?)
}

protocol TestAnswersUpdater {
    func deleteTestsAnswers()
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

protocol CPartPointsUpdater {
    func updatePoints(for index: Int, with points: Int)
}

protocol TestViewModel {
    func getTestTasks(completion: @escaping (Bool) -> ())
    func getTasksNumber() -> Int
    func saveUsersProgress(with time: Int)
    func isTestFinished() -> Bool
    func transportData(to viewModel: CPartTestViewModel, with time: Int)
    func getPhotoForTask(_ index: Int) -> UIImage
    func getTimeTillEnd() -> Double
    func getFirstQuestionAnswer() -> String?
    func getUsersAnswer(for taskIndex: Int) -> String
    func writeAnswerForTask(_ index: Int, with answer: String)
    func getNextTaskIndex(after index: Int) -> Int
    func getTimeString(from allSeconds: Int) -> String
    func getMaxRatio() -> CGFloat
    var name: String { set get }
    var testAnswers: [String:String] { set get }
}

protocol GeneralTestResultsViewModel {
    var timeTillEnd: Int { get set }
    var wrightAnswers: [String:(Double?, Double?, String?)] { get set }
    var userAnswers: [String:String] { get set }
    var taskImages: [String:UIImage] { get set }
    var testName: String { get set }
    var cPartPoints: [Int] { get set }
    var testAnswersUpdater: TestAnswersUpdater? { get set }
    func checkUserAnswers(completion: @escaping (Bool) -> ())
    func updateTestDataAsDone()
    func isCellOpened(index: Int) -> Bool
    func closeCell(for index: Int)
    func openCell(for index: Int)
    func getTestDurationString() -> String
    func getWrightAnswersNumberString() -> String
    func getImage(for taskName: String) -> UIImage?
    func getDescription(for taskName: String) -> UIImage?
    func getUsersAnswer(for taskName: String) -> String?
    func getTaskCorrection(for index: Int) -> Int
    func getUsersFinalPoints() -> Int
    func getUserPoints(for taskNumber: Int) -> String
    func getColorPercentage() -> (Float, Float)
    func getWrightAnswer(for index: Int) -> String
}

protocol ProfileInfoUpdater {
    func updateProfileInfo()
}

protocol SelectedThemesUpdater {
    func updateTheme(with theme: String)
}

protocol TrainerAdminViewModel {
    func getTrainerData(completion: @escaping (Bool) -> ())
    func updateWrightAnswer(with text: String)
    func getTasksNumber() -> Int
    func getTask(for index: Int) -> String
    func updatePhotoData(with data: Data)
    func updateTaskDescription(with data: Data)
    func updateInverseState(to bool: Bool)
    func updateStringState(to bool: Bool)
    func uploadNewTaskToTrainer(completion: @escaping (Bool) -> ())
    func uploadNewTaskToTest(_ testName: String, completion: @escaping (Bool) -> ())
    func updateSelectedTask(with index: Int)
    func updateSelectedTheme(with index: Int)
    func getSelectedTheme() -> String
    func updateTaskNumber(with number: String)
    func searchTask(completion: @escaping (TaskModel?) -> ())
    func clearOldData()
}

protocol ImageOpener {
    func openImage(_ image: UIImage)
}
