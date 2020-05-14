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
    func checkUserAnswers(completion: (Bool) -> ())
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
