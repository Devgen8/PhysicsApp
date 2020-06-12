//
//  AdminStatsViewModel.swift
//  PhysicsApp
//
//  Created by мак on 04/04/2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation
import FirebaseFirestore
import CoreData
import FirebaseStorage

class AdminStatsViewModel {
    
    let adminStatsReference = Firestore.firestore().collection("adminStats")
    let trainerReference = Firestore.firestore().collection("trainer")
    var tasks = [AdminStatsModel]()
    var tasksLevel = [String:[String]]()
    var sort = AdminStatsSortType.task
    var numberOfCells = 0
    var cellLabels = [String]()
    var cellPercantage = [Int]()
    var descending = true
    
    func getThemes(completion: @escaping (Bool) -> ()) {
        if let lastUpdateDate = UserDefaults.standard.value(forKey: "adminStatsUpdateDate") as? Date,
            let hourDifference = Calendar.current.dateComponents([.hour], from: Date(), to: lastUpdateDate).hour {
            if hourDifference >= 1 {
                getThemesFromFirestore { (isReady) in
                    completion(isReady)
                }
            } else {
                getThemesFromCoreData { (isReady) in
                    completion(isReady)
                }
            }
        } else {
            getThemesFromFirestore { (isReady) in
                completion(isReady)
            }
        }
    }
    
    func getThemesFromCoreData(completion: @escaping (Bool) -> ()) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Admin> = Admin.fetchRequest()
                let result = try context.fetch(fechRequest)
                let admin = result.first
                tasks = []
                if let newTasks = admin?.tasks {
                    for task in newTasks {
                        var newTask = AdminStatsModel()
                        newTask.failed = Int((task as! AdminStatTask).failed)
                        newTask.succeded = Int((task as! AdminStatTask).succeded)
                        newTask.name = (task as! AdminStatTask).name
                        newTask.theme = (task as! AdminStatTask).theme
                        tasks.append(newTask)
                    }
                } else {
                    completion(false)
                }
                tasksLevel = (admin?.tasksLevels as! TasksLevelsObject).tasksLevels
                completion(true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getThemesFromFirestore(completion: @escaping (Bool) -> ()) {
        adminStatsReference.getDocuments { (snapshot, error) in
            guard error == nil, let documents = snapshot?.documents else {
                print("Error reading admin stats: \(String(describing: error?.localizedDescription))")
                return
            }
            self.tasks = []
            for document in documents {
                var newTask = AdminStatsModel()
                newTask.name = document.data()["name"] as? String
                newTask.theme = document.data()["theme"] as? String
                newTask.failed = document.data()["failed"] as? Int
                newTask.succeded = document.data()["succeded"] as? Int
                self.tasks.append(newTask)
            }
            self.getTasksLevel { (isReady) in
                completion(isReady)
            }
        }
    }
    
    func getTasksLevel(completion: @escaping (Bool) -> ()) {
        var levels = [String:[String]]()
        levels["Базовый"] = []
        levels["Повышенный"] = []
        levels["Высокий"] = []
        EGEInfo.baseTasks.forEach({ levels["Базовый"]?.append("Задание №\($0)") })
        EGEInfo.advancedTasks.forEach({ levels["Повышенный"]?.append("Задание №\($0)") })
        EGEInfo.masterTasks.forEach({ levels["Высокий"]?.append("Задание №\($0)") })
        self.tasksLevel = levels
        self.saveTasksInCoreData()
        self.updateKeysInfo()
        completion(true)
    }
    
    func updateKeysInfo() {
        UserDefaults.standard.set(Date(), forKey: "adminStatsUpdateDate")
    }
    
    func saveTasksInCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Admin> = Admin.fetchRequest()
                let result = try context.fetch(fechRequest)
                var admin: Admin?
                if result.isEmpty {
                    admin = Admin(context: context)
                } else {
                    admin = result.first
                }
                let newTasks = NSMutableSet()
                for task in tasks {
                    let adminStatTask = AdminStatTask(context: context)
                    adminStatTask.failed = Int16(task.failed ?? 0)
                    adminStatTask.succeded = Int16(task.succeded ?? 0)
                    adminStatTask.name = task.name
                    adminStatTask.theme = task.theme
                    newTasks.add(adminStatTask)
                }
                admin?.tasks = newTasks
                admin?.tasksLevels = TasksLevelsObject(tasksLevels: tasksLevel)
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getThemesNumber() -> Int {
        return numberOfCells
    }
    
    func getTaskName(for index: Int) -> String {
        return cellLabels[index].uppercased()
    }
    
    func getTaskPercentage(for index: Int) -> Int {
        return cellPercantage[index]
    }
    
    func changeDescending() {
        descending = !descending
    }
    
    func changeToSort(_ sort: AdminStatsSortType) {
        self.sort = sort
    }
    
    func prepareDataForReload(completion: (Bool) -> ()) {
        cellLabels = []
        cellPercantage = []
        numberOfCells = getThemesNumber(forSort: sort)
        fullfillCellParameters(forSort: sort)
        completion(true)
    }
    
    func getTasksData(for index: Int, completion: @escaping (String, Data) -> ()) {
        let (taskName, taskNumber) = getTaskLocation(taskName: cellLabels[index])
        trainerReference.document(taskName).collection("tasks").document("task\(taskNumber)").getDocument { (document, error) in
            guard error == nil else {
                print("Error reading task info: \(String(describing: error?.localizedDescription))")
                completion("", Data())
                return
            }
            if let wrightAnswer = document?.data()?["wrightAnswer"] as? Double {
                self.downloadTaskPhoto(for: self.cellLabels[index]) { (imageData) in
                    completion("\(wrightAnswer)", imageData)
                }
            } else if let stringAnswer = document?.data()?["stringAnswer"] as? String {
                self.downloadTaskPhoto(for: self.cellLabels[index]) { (imageData) in
                    completion(stringAnswer, imageData)
                }
            }
        }
    }
    
    func downloadTaskPhoto(for taskName: String, completion: @escaping (Data) -> ()) {
        let (taskName, taskNumber) = getTaskLocation(taskName: taskName)
        let imageRef = Storage.storage().reference().child("trainer/\(taskName)/task\(taskNumber).png")
        imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            guard error == nil else {
                print("Error downloading images: \(String(describing: error?.localizedDescription))")
                return
            }
            if let data = data {
                completion(data)
            }
        }
    }
    
    func fullfillCellParameters(forSort: AdminStatsSortType) {
        switch sort {
        case .all:
            fullfillAll()
        case .difficulty:
            fullfillByDifficulty()
        case .task:
            fullfillTasks()
        case .theme:
            fullfillThemes()
        }
    }
    
    func fullfillTasks() {
        var tasksStats = [String:Int]()
        var numberOfTasksInTheme = [String:Int]()
        for task in tasks {
            if let taskName = task.name,
                let failures = task.failed,
                let successes = task.succeded {
                let percentage = Int(Double(failures)/Double(failures + successes) * 100.0)
                let (themeName, _) = getTaskLocation(taskName: taskName)
                if tasksStats[themeName] == nil {
                    tasksStats[themeName] = percentage
                } else {
                    tasksStats[themeName]! += percentage
                }
                if numberOfTasksInTheme[themeName] == nil {
                    numberOfTasksInTheme[themeName] = 1
                } else {
                    numberOfTasksInTheme[themeName]! += 1
                }
            }
        }
        for pair in tasksStats {
            tasksStats[pair.key] = Int(Double(tasksStats[pair.key] ?? 0)/Double(numberOfTasksInTheme[pair.key] ?? 1))
        }
        let taskStatsArray = descending ? tasksStats.sorted(by: { $0.value > $1.value }) : tasksStats.sorted(by: { $0.value < $1.value })
        for pair in taskStatsArray {
            cellLabels.append(pair.key)
            cellPercantage.append(pair.value)
        }
    }
    
    func fullfillThemes() {
        var tasksStats = [String:Int]()
        var numberOfTasksInTheme = [String:Int]()
        for task in tasks {
            if let allTaskThemes = task.theme,
                let failures = task.failed,
                let successes = task.succeded {
                let taskThemesArray = ThemeParser.parseTaskThemes(allTaskThemes)
                for taskTheme in taskThemesArray {
                    let percentage = Int(Double(failures)/Double(failures + successes) * 100.0)
                    if tasksStats[taskTheme] == nil {
                        tasksStats[taskTheme] = percentage
                    } else {
                        tasksStats[taskTheme]! += percentage
                    }
                    if numberOfTasksInTheme[taskTheme] == nil {
                        numberOfTasksInTheme[taskTheme] = 1
                    } else {
                        numberOfTasksInTheme[taskTheme]! += 1
                    }
                }
            }
        }
        for pair in tasksStats {
            tasksStats[pair.key] = Int(Double(tasksStats[pair.key] ?? 0)/Double(numberOfTasksInTheme[pair.key] ?? 1))
        }
        let taskStatsArray = descending ? tasksStats.sorted(by: { $0.value > $1.value }) : tasksStats.sorted(by: { $0.value < $1.value })
        for pair in taskStatsArray {
            cellLabels.append(pair.key)
            cellPercantage.append(pair.value)
        }
    }
    
    func fullfillByDifficulty() {
        var tasksStats = [String:Int]()
        var numberOfTasksInTheme = [String:Int]()
        for task in tasks {
            if let failures = task.failed,
                let successes = task.succeded {
                var taskTheme = ""
                for levelPair in tasksLevel {
                    let (taskName, _) = getTaskLocation(taskName: task.name ?? "")
                    if levelPair.value.contains(taskName) {
                        taskTheme = levelPair.key
                        break
                    }
                }
                let percentage = Int(Double(failures)/Double(failures + successes) * 100.0)
                if tasksStats[taskTheme] == nil {
                    tasksStats[taskTheme] = percentage
                } else {
                    tasksStats[taskTheme]! += percentage
                }
                if numberOfTasksInTheme[taskTheme] == nil {
                    numberOfTasksInTheme[taskTheme] = 1
                } else {
                    numberOfTasksInTheme[taskTheme]! += 1
                }
            }
        }
        for pair in tasksStats {
            tasksStats[pair.key] = Int(Double(tasksStats[pair.key] ?? 0)/Double(numberOfTasksInTheme[pair.key] ?? 1))
        }
        let taskStatsArray = descending ? tasksStats.sorted(by: { $0.value > $1.value }) : tasksStats.sorted(by: { $0.value < $1.value })
        for pair in taskStatsArray {
            cellLabels.append(pair.key)
            cellPercantage.append(pair.value)
        }
    }
    
    func fullfillAll() {
        var tasksStats = [String:Int]()
        for task in tasks {
            if let taskName = task.name,
                let failures = task.failed,
                let successes = task.succeded {
                let percentage = Int(Double(failures)/Double(failures + successes) * 100.0)
                tasksStats[taskName] = percentage
            }
        }
        let taskStatsArray = descending ? tasksStats.sorted(by: { $0.value > $1.value }) : tasksStats.sorted(by: { $0.value < $1.value })
        for pair in taskStatsArray {
            cellLabels.append(pair.key)
            cellPercantage.append(pair.value)
        }
    }
    
    func getThemesNumber(forSort sort: AdminStatsSortType) -> Int {
        switch sort {
        case .all:
            return tasks.count
        case .difficulty:
            return getDifficultyCount()
        case .task:
            return getTasksCount()
        case .theme:
            return getThemesCount()
        }
    }
    
    func getDifficultyCount() -> Int {
        var tasksNames = [String]()
        for task in tasks {
            var taskTheme = ""
            for levelPair in tasksLevel {
                let (taskName, _) = getTaskLocation(taskName: task.name ?? "")
                if levelPair.value.contains(taskName) {
                    taskTheme = levelPair.key
                    break
                }
            }
            if !tasksNames.contains(taskTheme) {
                tasksNames.append(taskTheme)
            }
        }
        return tasksNames.count
    }
        
    func getTasksCount() -> Int {
        var tasksNames = [String]()
        for task in tasks {
            let (taskName, _) = getTaskLocation(taskName: task.name ?? "")
            if !tasksNames.contains(taskName) {
                tasksNames.append(taskName)
            }
        }
        return tasksNames.count
    }
    
    func getThemesCount() -> Int {
        var themeNames = [String]()
        for task in tasks {
            let allTaskThemes = ThemeParser.parseTaskThemes(task.theme ?? "")
            for taskTheme in allTaskThemes {
                if !themeNames.contains(taskTheme) {
                    themeNames.append(taskTheme)
                }
            }
        }
        return themeNames.count
    }
    
    func transportData(to viewModel: TasksDetailViewModel, for index: Int) {
        viewModel.sortTypeName = sort.rawValue
        switch sort {
        case .task:
            viewModel.tasks = prepareByTasksForTransportation(for: index)
        case .theme:
            viewModel.tasks = prepareByThemesForTransportation(for: index)
        case .difficulty:
            viewModel.tasks = prepareByDifficultyForTransportation(for: index)
        default:
            print("")
        }
    }
    
    func prepareByTasksForTransportation(for index: Int) -> [AdminStatsModel] {
        var searchingTasks = [AdminStatsModel]()
        for task in tasks {
            let (taskName, _) = getTaskLocation(taskName: task.name ?? "")
            if taskName == cellLabels[index] {
                searchingTasks.append(task)
            }
        }
        return searchingTasks
    }
    
    func prepareByThemesForTransportation(for index: Int) -> [AdminStatsModel] {
        var searchingTasks = [AdminStatsModel]()
        for task in tasks {
            let allTaskThemes = ThemeParser.parseTaskThemes(task.theme ?? "")
            for taskTheme in allTaskThemes {
                if taskTheme == cellLabels[index] {
                    searchingTasks.append(task)
                }
            }
        }
        return searchingTasks
    }
    
    func prepareByDifficultyForTransportation(for index: Int) -> [AdminStatsModel] {
        var searchingTasks = [AdminStatsModel]()
        for task in tasks {
            let (taskName, _) = getTaskLocation(taskName: task.name ?? "")
            if tasksLevel[cellLabels[index]]?.contains(taskName) ?? false {
                searchingTasks.append(task)
            }
        }
        return searchingTasks
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
}
