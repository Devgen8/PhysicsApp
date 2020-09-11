//
//  TaskViewModel.swift
//  TrainingApp
//
//  Created by мак on 18/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import CoreData

class TaskViewModel {
    
    //MARK: Fields
    
    private var theme: String?
    private let themeReference = Firestore.firestore().collection("trainer")
    private let usersReference = Firestore.firestore().collection("users")
    private let adminStatsReference = Firestore.firestore().collection("adminStats")
    private var task: TaskModel?
    private var taskNumber: Int?
    private var numberOfTasks:  Int?
    private var isTaskUnsolved: Bool?
    private var unsolvedTasks = [String:[String]]()
    private var solvedTasks = [String:[String]]()
    private var themesUnsolvedTasks = [String:[String]]()
    private var isFirstAnswer = true
    private var sortType: TasksSortType?
    private var allTasks = [TaskModel]()
    
    var unsolvedTasksUpdater: UnsolvedTaskUpdater?
    
    //MARK: Interface
    
    func checkImagesExist(completion: @escaping (Bool)->()) {
        if task?.taskDescription != nil && task?.image != nil {
            completion(true)
        } else {
            downloadPhotos { (isReady) in
                completion(isReady)
            }
        }
    }
    
    private func saveImagesToCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                if let sort = sortType {
                    if sort == .tasks {
                        ((trainer?.egeTasks?.first(where: { ($0 as! EgeTask).name == theme}) as! EgeTask).tasks?.first(where: {(($0 as! TaskData).name == task?.name)}) as! TaskData).taskDescription = task?.taskDescription?.pngData()
                        ((trainer?.egeTasks?.first(where: { ($0 as! EgeTask).name == theme}) as! EgeTask).tasks?.first(where: {(($0 as! TaskData).name == task?.name)}) as! TaskData).image = task?.image?.pngData()
                    }
                    if sort == .themes {
                        ((trainer?.egeThemes?.first(where: { ($0 as! EgeTheme).name == theme}) as! EgeTheme).tasks?.first(where: {(($0 as! TaskData).name == task?.name)}) as! TaskData).taskDescription = task?.taskDescription?.pngData()
                        ((trainer?.egeThemes?.first(where: { ($0 as! EgeTheme).name == theme}) as! EgeTheme).tasks?.first(where: {(($0 as! TaskData).name == task?.name)}) as! TaskData).image = task?.image?.pngData()
                    }
                }
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func downloadPhotos(completion: @escaping (Bool) -> ()) {
        let (themeName, taskNumber) = NamesParser.getTaskLocation(taskName: task?.name ?? "")
        let imageRef = Storage.storage().reference().child("trainer/\(themeName)/task\(taskNumber).png")
        imageRef.getData(maxSize: 4 * 2048 * 2048) { [weak self] data, error in
            guard let `self` = self, error == nil else {
                print("Error downloading images: \(String(describing: error?.localizedDescription))")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                self.task?.image = image
                self.downloadDescription { (isReady) in
                    completion(isReady)
                }
            }
        }
    }
    
    private func downloadDescription(completion: @escaping (Bool) -> ()) {
        let (themeName, taskNumber) = NamesParser.getTaskLocation(taskName: task?.name ?? "")
        let imageRef = Storage.storage().reference().child("trainer/\(themeName)/task\(taskNumber)description.png")
        imageRef.getData(maxSize: 4 * 2048 * 2048) { [weak self] data, error in
            guard let `self` = self, error == nil else {
                print("Error downloading descriptions: \(String(describing: error?.localizedDescription))")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                self.task?.taskDescription = image
                self.saveImagesToCoreData()
                completion(true)
            }
        }
    }
    
    func checkAnswer(_ stringAnswer: String?) -> (Bool, String) {
        var isWright = false
        if let wrightAnswer = task?.wrightAnswer, let userAnswer = stringAnswer {
            if (task?.alternativeAnswer) == true {
                // wrightAnswer
                let charsArray = [Character](wrightAnswer)
                var wrightCount = 0
                var wrightSum = 0
                for letter in charsArray {
                    wrightSum += Int(String(letter)) ?? 0
                    wrightCount += 1
                }
                
                // usersAnswer
                let charsUsersArray = [Character](userAnswer)
                var usersCount = 0
                var usersSum = 0
                for letter in charsUsersArray {
                    usersSum += Int(String(letter)) ?? 0
                    usersCount += 1
                }
                
                // checking
                isWright = ((wrightCount == usersCount) && (wrightSum == usersSum))
            } else {
                isWright = wrightAnswer == userAnswer
            }
        }
        updateKeyInfo()
        if isWright {
            isTaskUnsolved = false
            updateStatistics()
            return (true, "ПРАВИЛЬНО!")
        } else {
            isTaskUnsolved = true
            updateStatistics()
            return (false, "НЕПРАВИЛЬНО")
        }
    }
    
    func updateTaskStatus() {
        let (theme, _) = NamesParser.getTaskLocation(taskName: task?.name ?? "")
        guard Auth.auth().currentUser?.uid != nil, let unsolvedTask = self.task?.name else {
            print("Couldn't write unsolved tasks")
            return
        }
        
        if isTaskUnsolved == true {
            if solvedTasks[theme]?.contains(unsolvedTask) ?? false {
                solvedTasks[theme] = solvedTasks[theme]?.filter({ $0 != unsolvedTask })
            }
            if unsolvedTasks[theme] == nil {
                unsolvedTasks[theme] = [unsolvedTask]
            } else {
                if !(unsolvedTasks[theme]?.contains(unsolvedTask) ?? true) {
                    unsolvedTasks[theme]?.append(unsolvedTask)
                }
            }
        }
        if isTaskUnsolved == false {
            if unsolvedTasks[theme]?.contains(unsolvedTask) ?? false {
                unsolvedTasks[theme] = unsolvedTasks[theme]?.filter({ $0 != unsolvedTask })
                themesUnsolvedTasks[self.theme ?? ""] = themesUnsolvedTasks[self.theme ?? ""]?.filter({ $0 != unsolvedTask })
            }
            if solvedTasks[theme] == nil {
                solvedTasks[theme] = [unsolvedTask]
            } else {
                if !(solvedTasks[theme]?.contains(unsolvedTask) ?? true) {
                    solvedTasks[theme]?.append(unsolvedTask)
                }
            }
        }
        putTaskUnsolved()
    }
    
    func updateTaskStats(with change: Int) {
        if change > 0 {
            saveFirstTryTaskInCoreData()
        }
        if let taskName = task?.name, change != 0 {
            adminStatsReference.document(taskName).getDocument { (document, error) in
                guard error == nil else {
                    print("error reading task stats: \(String(describing: error?.localizedDescription))")
                    return
                }
                var successes: Int = document?.data()?["succeded"] as? Int ?? 0
                var failures: Int = document?.data()?["failed"] as? Int ?? 0
                if change > 0 {
                    successes += 1
                }
                if change < 0 {
                    failures += 1
                }
                if failures + successes == 1 {
                    var themeTypeString = [Character]()
                    var taskTheme = ""
                    for letter in self.theme ?? "" {
                        if themeTypeString.count < 7 {
                            themeTypeString.append(letter)
                        } else {
                            break
                        }
                    }
                    if String(themeTypeString) != "Задание" {
                        taskTheme = self.theme ?? ""
                    } else {
                        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                            do {
                                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                                let result = try context.fetch(fechRequest)
                                let trainer = result.first
                                var taskNameArray = [Character](taskName)
                                var index = taskNameArray.count
                                for _ in taskNameArray {
                                    index -= 1
                                    let removedLetter = taskNameArray.remove(at: index)
                                    if removedLetter == "." {
                                        break
                                    }
                                }
                                let egeTaskName = String(taskNameArray)
                                let egeThemesInTask = ((trainer?.egeTasks?.first(where: { ($0 as! EgeTask).name == egeTaskName }) as! EgeTask).themes as! ThemesInEgeTask)
                                taskTheme = egeThemesInTask.egeTaskThemes[(self.task?.serialNumber ?? 1) - 1]
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    self.adminStatsReference.document(taskName).setData([Task.succeded.rawValue : successes,
                                                                        Task.failed.rawValue : failures,
                                                                        "name" : taskName,
                                                                        "theme" : taskTheme])
                } else {
                    self.adminStatsReference.document(taskName).updateData([Task.succeded.rawValue : successes,
                                                                            Task.failed.rawValue : failures])
                }
            }
        }
    }
    
    func updateParentUnsolvedTasks() {
        if let tasksUpdater = unsolvedTasksUpdater as? TasksListViewModel {
            tasksUpdater.setThemeUnsolvedTasks(themesUnsolvedTasks)
        }
        unsolvedTasksUpdater?.updateUnsolvedTasks(with: unsolvedTasks, and: solvedTasks)
    }
    
    func savePreviousTask() {
        allTasks[(taskNumber ?? 1) - 1] = task ?? TaskModel()
    }
    
    func changeTaskNumber(on value: Int) {
        if taskNumber != nil {
            taskNumber! += value
        }
    }
    
    func changeCurrentTask() {
        task = allTasks[(taskNumber ?? 1) - 1]
    }
    
    func getTaskName() -> String? {
        return task?.name
    }
    
    func getNumberOfTasks() -> Int? {
        return numberOfTasks
    }
    
    func setNumberOfTasks(_ newNumber: Int?) {
        numberOfTasks = newNumber
    }
    
    func getTaskNumber() -> Int? {
        return taskNumber
    }
    
    func setTaskNumber(_ newNumber: Int?) {
        taskNumber = newNumber
    }
    
    func getTheme() -> String? {
        return theme
    }
    
    func setTheme(_ newTheme: String?) {
        theme = newTheme
    }
    
    func getTask() -> TaskModel? {
        return task
    }
    
    func setTask(_ newTask: TaskModel?) {
        task = newTask
    }
    
    func setUnsolvedTasks(_ newTasks: [String:[String]]) {
        unsolvedTasks = newTasks
    }
    
    func setSolvedTasks(_ newTasks: [String:[String]]) {
        solvedTasks = newTasks
    }
    
    func setThemeUnsolvedTasks(_ newTasks: [String:[String]]) {
        themesUnsolvedTasks = newTasks
    }
    
    func setSortType(_ type: TasksSortType?) {
        sortType = type
    }
    
    func setAllTasks(_ newTasks: [TaskModel]) {
        allTasks = newTasks
    }
    
    func getAllTasksNumber() -> Int {
        return allTasks.count
    }
    
    func clearOldData() {
        isTaskUnsolved = nil
        isFirstAnswer = true
    }
    
    //MARK: Private section
    
    private func updateKeyInfo() {
        if UserDefaults.standard.value(forKey: "isUserInformedAboutAuth") as? Bool == nil {
            UserDefaults.standard.set(true, forKey: "isUserInformedAboutAuth")
        }
    }
    
    private func updateStatistics() {
        guard let theme = theme, let unsolvedTask = self.task?.name else {
            print("Couldn't write unsolved tasks")
            return
        }
        // stats for school
        if !(solvedTasks[theme]?.contains(unsolvedTask) ?? false || unsolvedTasks[theme]?.contains(unsolvedTask) ?? false) {
            var completedTasks = UserDefaults.standard.value(forKey: "completedTasks") as? [String] ?? []
            if !completedTasks.contains(unsolvedTask) {
                var change = 0
                if isTaskUnsolved == true {
                    change = -1
                    updateTaskStats(with: change)
                }
                if isTaskUnsolved == false {
                    change = 1
                    updateTaskStats(with: change)
                }
                completedTasks.append(unsolvedTask)
                UserDefaults.standard.set(completedTasks, forKey: "completedTasks")
            }
        }
    }
    
    private func putTaskUnsolved() {
        if (Auth.auth().currentUser?.uid) != nil {
            saveUnsolvedTasksToCoreData()
        }
    }
    
    // Firestore
    
    private func saveFirstTryTaskInFirestore(tasks: [String]) {
        if let userId = Auth.auth().currentUser?.uid {
            usersReference.document(userId).updateData(["firstTryTasks" : tasks])
        }
    }
    
    private func saveUnsolvedTasksToFirestore() {
        if let userId = Auth.auth().currentUser?.uid {
            usersReference.document(userId).updateData(["unsolvedTasks" : unsolvedTasks,
                                                     "solvedTasks" : solvedTasks])
        }
    }
    
    // Core Data
    
    private func saveFirstTryTaskInCoreData() {
        if Auth.auth().currentUser?.uid != nil, let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<User> = User.fetchRequest()
                let result = try context.fetch(fechRequest)
                if let user = result.first {
                    var newFirstTryTasks = (user.solvedTasks as! StatusTasks).firstTryTasks
                    let coreDataUnsolved = (user.solvedTasks as! StatusTasks).unsolvedTasks
                    let coreDataSolved = (user.solvedTasks as! StatusTasks).solvedTasks
                    if let taskName = task?.name {
                        let (taskNumber, _) = NamesParser.getTaskLocation(taskName: taskName)
                        if !(coreDataUnsolved[taskNumber]?.contains(taskName) ?? false) && !(coreDataSolved[taskNumber]?.contains(taskName) ?? false) {
                            newFirstTryTasks.append(taskName)
                            saveFirstTryTaskInFirestore(tasks: newFirstTryTasks)
                        }
                    }
                    user.solvedTasks = StatusTasks(solvedTasks: coreDataSolved, unsolvedTasks: coreDataUnsolved, firstTryTasks: newFirstTryTasks)
                }
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func saveUnsolvedTasksToCoreData() {
        if Auth.auth().currentUser?.uid != nil, let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<User> = User.fetchRequest()
                let result = try context.fetch(fechRequest)
                if let user = result.first {
                    let firstTryTasksFromUser = (user.solvedTasks as! StatusTasks).firstTryTasks
                    user.solvedTasks = StatusTasks(solvedTasks: solvedTasks, unsolvedTasks: unsolvedTasks, firstTryTasks: firstTryTasksFromUser)
                    saveUnsolvedTasksToFirestore()
                }
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
