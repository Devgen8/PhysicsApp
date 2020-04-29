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
    var task: TaskModel?
    var taskNumber: Int?
    var numberOfTasks:  Int?
    var isTaskUnsolved: Bool?
    var unsolvedTasks = [String:[String]]()
    var unsolvedTasksUpdater: UnsolvedTaskUpdater?
    var solvedTasks = [String:[String]]()
    var themesUnsolvedTasks = [String:[String]]()
    
    func checkAnswer(_ stringAnswer: String?) -> (Bool, String) {
        var isWright = false
        let defaultStringAnswer = stringAnswer?.replacingOccurrences(of: ",", with: ".")
        if let wrightAnswer = task?.wrightAnswer, let userAnswer = Double(defaultStringAnswer ?? "") {
            if let alternativeAnswer = task?.alternativeAnswer {
                isWright = (wrightAnswer == userAnswer || alternativeAnswer == userAnswer)
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
            return (true, "Правильно! +1 балл")
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
            if isTaskUnsolved == true {
                if let failed = task?.failed {
                    task?.failed = failed + 1
                } else {
                    task?.failed = 1
                }
                updateTaskStats()
            }
            if isTaskUnsolved == false {
                if let succeded = task?.succeded {
                    task?.succeded = succeded + 1
                } else {
                    task?.succeded = 1
                }
                updateTaskStats()
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
    
    func updateTaskStats() {
        if let theme = theme, let number = task?.serialNumber {
            themeReference.document(theme).collection("tasks").document("task\(number)").updateData([Task.succeded.rawValue : task?.succeded ?? 0,
                                                                                          Task.failed.rawValue : task?.failed ?? 0])
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
                let statusTasks = StatusTasks(solvedTasks: solvedTasks, unsolvedTasks: unsolvedTasks)
                user?.solvedTasks = statusTasks
                
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
