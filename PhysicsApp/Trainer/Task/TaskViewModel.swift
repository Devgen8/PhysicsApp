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
    
    var theme: String?
    let themeReference = Firestore.firestore().collection("trainer")
    let usersReference = Firestore.firestore().collection("users")
    let adminStatsReference = Firestore.firestore().collection("adminStats")
    var task: TaskModel?
    var taskNumber: Int?
    var numberOfTasks:  Int?
    var isTaskUnsolved: Bool?
    var unsolvedTasks = [String:[String]]()
    var unsolvedTasksUpdater: UnsolvedTaskUpdater?
    var solvedTasks = [String:[String]]()
    var themesUnsolvedTasks = [String:[String]]()
    var isFirstAnswer = true
    
    func checkAnswer(_ stringAnswer: String?) -> (Bool, String) {
        var isWright = false
        var defaultStringAnswer = stringAnswer?.replacingOccurrences(of: ",", with: ".")
        defaultStringAnswer = defaultStringAnswer?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let wrightAnswer = task?.wrightAnswer, let userAnswer = Double(defaultStringAnswer ?? "") {
            if (task?.alternativeAnswer) != nil {
                // wrightAnswer
                let stringWrightAnswer = "\(wrightAnswer)"
                let charsArray = [Character](stringWrightAnswer)
                var wrightCount = 0
                var wrightSum = 0
                for letter in charsArray {
                    wrightSum += Int(String(letter)) ?? 0
                    wrightCount += 1
                }
                
                // usersAnswer
                let stringUsersAnswer = "\(userAnswer)"
                let charsUsersArray = [Character](stringUsersAnswer)
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
        if let wrightAnswer = task?.stringAnswer, let userAnswer = defaultStringAnswer {
            isWright = wrightAnswer == userAnswer
        }
        if isWright {
            isTaskUnsolved = false
            updateStatistics()
            return (true, "Правильно!")
        } else {
            isTaskUnsolved = true
            updateStatistics()
            return (false, "Неправильно :(")
        }
    }
    
    func updateStatistics() {
        guard let theme = theme, let unsolvedTask = self.task?.name else {
            print("Couldn't write unsolved tasks")
            return
        }
        // stats for school
        if !(solvedTasks[theme]?.contains(unsolvedTask) ?? false || unsolvedTasks[theme]?.contains(unsolvedTask) ?? false) {
            if isFirstAnswer {
                var change = 0
                if isTaskUnsolved == true {
                    change = -1
                    isFirstAnswer = false
                    updateTaskStats(with: change)
                }
                if isTaskUnsolved == false {
                    change = 1
                    isFirstAnswer = false
                    updateTaskStats(with: change)
                }
            }
        }
    }
    
    func updateTaskStatus() {
        let (theme, _) = getTaskLocation(taskName: task?.name ?? "")
        guard let unsolvedTask = self.task?.name else {
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
                                taskTheme = egeThemesInTask.egeTaskThemes[self.task?.serialNumber ?? 0]
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
    
    func saveFirstTryTaskInCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<User> = User.fetchRequest()
                let result = try context.fetch(fechRequest)
                let user = result.first
                var newFirstTryTasks = (user?.solvedTasks as! StatusTasks).firstTryTasks
                let coreDataUnsolved = (user?.solvedTasks as! StatusTasks).unsolvedTasks
                let coreDataSolved = (user?.solvedTasks as! StatusTasks).solvedTasks
                if let taskName = task?.name {
                    newFirstTryTasks.append(taskName)
                }
                user?.solvedTasks = StatusTasks(solvedTasks: coreDataSolved, unsolvedTasks: coreDataUnsolved, firstTryTasks: newFirstTryTasks)
                saveFirstTryTaskInFirestore(tasks: (user?.solvedTasks as! StatusTasks).firstTryTasks)
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveFirstTryTaskInFirestore(tasks: [String]) {
        if let userId = Auth.auth().currentUser?.uid {
            usersReference.document(userId).updateData(["firstTryTasks" : tasks])
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
    
    func putTaskUnsolved() {
        saveUnsolvedTasksToCoreData()
        if let userId = Auth.auth().currentUser?.uid {
            usersReference.document(userId).updateData(["unsolvedTasks" : unsolvedTasks,
                                                     "solvedTasks" : solvedTasks])
        }
    }
    
    func saveUnsolvedTasksToCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<User> = User.fetchRequest()
                let result = try context.fetch(fechRequest)
                let user = result.first
                let firstTryTasksFromUser = (user?.solvedTasks as! StatusTasks).firstTryTasks
                user?.solvedTasks = StatusTasks(solvedTasks: solvedTasks, unsolvedTasks: unsolvedTasks, firstTryTasks: firstTryTasksFromUser)
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateParentUnsolvedTasks() {
        if let tasksUpdater = unsolvedTasksUpdater as? TasksListViewModel {
            tasksUpdater.themesUnsolvedTasks = themesUnsolvedTasks
        }
        unsolvedTasksUpdater?.updateUnsolvedTasks(with: unsolvedTasks, and: solvedTasks)
    }
    
    func changeUsersRating() {
        var change = 0
        if solvedTasks[theme ?? ""]?.contains(task?.name ?? "") ?? false && isTaskUnsolved ?? false {
            change = -1
        }
        if !(solvedTasks[theme ?? ""]?.contains(task?.name ?? "") ?? false) && !(isTaskUnsolved ?? true) {
            change = 1
        }
        if change != 0 {
            updateUsersRating(with: change)
        }
    }
    
    func updateUsersRating(with change: Int) {
//        if let userId = Auth.auth().currentUser?.uid {
//            usersReference.document(userId).getDocument { (document, error) in
//                guard error == nil else {
//                    print("Error reading user rating: \(String(describing: error?.localizedDescription))")
//                    return
//                }
//                let rating = document?.data()?["rating"] as? Int
//                var newRating = 0
//                if let rating = rating {
//                    newRating = rating + change
//                }
//                self.usersReference.document(userId).updateData(["rating" : newRating])
//            }
//        }
    }
}
