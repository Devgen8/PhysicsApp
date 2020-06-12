//
//  TasksListViewModel.swift
//  TrainingApp
//
//  Created by мак on 19/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CoreData

class TasksListViewModel {
    var theme: String?
    var tasks = [TaskModel]()
    var usersSolvedTasks = [String:[String]]()
    var unsolvedTasks = [String:[String]]()
    var firstTryTasks = [String]()
    let themeReference = Firestore.firestore().collection("trainer")
    let userReference = Firestore.firestore().collection("users")
    var lookingForUnsolvedTasks: Bool?
    var unsolvedTaskUpdater: UnsolvedTaskUpdater?
    var sortType: TasksSortType?
    var themeTasks = [String]()
    var themesUnsolvedTasks = [String:[String]]()
    var tasksThemes = [String:[String]]()
    
    func getTasks(completion: @escaping (Bool) -> ()) {
        getUsersSolvedTasksFromCoreData()
        getTasksThemes { [weak self] (isReady) in
            guard let `self` = self else {
                completion(false)
                return
            }
            if isReady {
                if self.lookingForUnsolvedTasks != true {
                    if let sortType = self.sortType {
                        if sortType == .tasks {
                            if let notUpdatedTasks = UserDefaults.standard.value(forKey: "notUpdatedTasks") as? [String],
                                notUpdatedTasks.contains(self.theme ?? "") {
                                self.getTasksByTasks { (isReady) in
                                    self.sortTasks()
                                    completion(isReady)
                                }
                            } else {
                                self.getTasksByTasksFromCoreData { (isReady) in
                                    self.sortTasks()
                                    completion(isReady)
                                }
                            }
                        }
                        if sortType == .themes {
                            if let notUpdatedThemes = UserDefaults.standard.value(forKey: "notUpdatedThemes") as? [String],
                                notUpdatedThemes.contains(self.theme ?? "") {
                                self.getTasksByThemes { (isReady) in
                                    self.sortTasks()
                                    completion(isReady)
                                }
                            } else {
                                self.getTasksByThemesFromCoreData { (isReady) in
                                    self.sortTasks()
                                    completion(isReady)
                                }
                            }
                        }
                    } else {
                        completion(false)
                    }
                } else {
                    if let sortType = self.sortType {
                        if sortType == .tasks {
                            if let notUpdatedTasks = UserDefaults.standard.value(forKey: "notUpdatedUnsolvedTasks") as? [String],
                                notUpdatedTasks.contains(self.theme ?? "") {
                                self.getTasksByTasks { (isReady) in
                                    self.sortTasks()
                                    completion(isReady)
                                }
                            } else {
                                self.getUnsolvedTasksFromCoreData { (isReady) in
                                    self.sortTasks()
                                    completion(isReady)
                                }
                            }
                        }
                        if sortType == .themes {
                            if let notUpdatedThemes = UserDefaults.standard.value(forKey: "notUpdatedUnsolvedThemes") as? [String],
                                notUpdatedThemes.contains(self.theme ?? "") {
                                self.getTasksByThemes { (isReady) in
                                    self.sortTasks()
                                    completion(isReady)
                                }
                            } else {
                                self.getUnsolvedTasksFromCoreData { (isReady) in
                                    self.sortTasks()
                                    completion(isReady)
                                }
                            }
                        }
                    } else {
                        completion(false)
                    }
                }
            }
        }
    }
    
    func getTasksThemes(completion: @escaping (Bool) -> ()) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
            
            do {
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                if let egetasks = trainer?.egeTasks {
                    let sortedEgeTasks = egetasks.sorted { ($0 as! EgeTask).themeNumber < ($1 as! EgeTask).themeNumber }
                    for egetask in sortedEgeTasks {
                        let task = (egetask as! EgeTask)
                        tasksThemes[task.name ?? ""] = (task.themes as? ThemesInEgeTask)?.egeTaskThemes
                    }
                }
                completion(true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getUnsolvedTasksFromCoreData(completion: @escaping (Bool) -> ()) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
            
            do {
                var searchTasks = [String]()
                if let sort = sortType {
                    if sort == .tasks, let newSearchTasks = unsolvedTasks[theme ?? ""] {
                        searchTasks = newSearchTasks
                    }
                    if sort == .themes {
                        searchTasks = themeTasks
                    }
                }
                tasks = []
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                var coreDataThemeTasks: NSOrderedSet?
                if let sort = sortType {
                    if sort == .tasks {
                        coreDataThemeTasks = (trainer?.egeTasks?.first(where: { ($0 as! EgeTask).name == theme }) as! EgeTask).tasks
                    }
                    if sort == .themes {
                        coreDataThemeTasks = (trainer?.egeThemes?.first(where: { ($0 as! EgeTheme).name == theme }) as! EgeTheme).tasks
                    }
                }
                if let newTasks = coreDataThemeTasks {
                    for task in newTasks {
                        if searchTasks.contains((task as! TaskData).name ?? "") {
                            let newTask = TaskModel()
                            newTask.alternativeAnswer = (task as! TaskData).alternativeAnswer
                            newTask.wrightAnswer = (task as! TaskData).wrightAnswer
                            newTask.serialNumber = Int((task as! TaskData).serialNumber)
                            newTask.stringAnswer = (task as! TaskData).stringAnswer
                            newTask.image = UIImage(data: (task as! TaskData).image ?? Data())
                            newTask.name = (task as! TaskData).name
                            newTask.taskDescription = UIImage(data: (task as! TaskData).taskDescription ?? Data())
                            tasks.append(newTask)
                        }
                    }
                }
                completion(true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveToCoreDataUnsolvedTasksByTasks() {
        if Auth.auth().currentUser?.uid != nil, let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                let arrayOfThemes = NSMutableOrderedSet()
                if (trainer?.egeTasks?.first(where: { ($0 as! EgeTask).name == theme}) as! EgeTask).tasks?.count == 0 {
                    for task in tasks {
                        let newTask = TaskData(context: context)
                        if let alternativeAnswer = task.alternativeAnswer {
                            newTask.alternativeAnswer = alternativeAnswer
                        }
                        if let wrightAnswer = task.wrightAnswer {
                            newTask.wrightAnswer = wrightAnswer
                        }
                        if let serialNumber = task.serialNumber {
                            newTask.serialNumber = Int16(serialNumber)
                        }
                        newTask.stringAnswer = task.stringAnswer
                        newTask.image = task.image?.pngData()
                        newTask.name = task.name
                        newTask.taskDescription = task.taskDescription?.pngData()
                        arrayOfThemes.add(newTask)
                    }
                    (trainer?.egeTasks?.first(where: { ($0 as! EgeTask).name == theme}) as! EgeTask).tasks = arrayOfThemes
                }
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveToCoreDataUnsolvedTasksByThemes() {
        if Auth.auth().currentUser?.uid != nil, let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                let arrayOfThemes = NSMutableOrderedSet()
                if (trainer?.egeThemes?.first(where: { ($0 as! EgeTheme).name == theme}) as! EgeTheme).tasks?.count == 0 {
                    for task in tasks {
                        let newTask = TaskData(context: context)
                        if let alternativeAnswer = task.alternativeAnswer {
                            newTask.alternativeAnswer = alternativeAnswer
                        }
                        if let wrightAnswer = task.wrightAnswer {
                            newTask.wrightAnswer = wrightAnswer
                        }
                        if let serialNumber = task.serialNumber {
                            newTask.serialNumber = Int16(serialNumber)
                        }
                        newTask.stringAnswer = task.stringAnswer
                        newTask.image = task.image?.pngData()
                        newTask.name = task.name
                        newTask.taskDescription = task.taskDescription?.pngData()
                        arrayOfThemes.add(newTask)
                    }
                    (trainer?.egeThemes?.first(where: { ($0 as! EgeTheme).name == theme}) as! EgeTheme).tasks = arrayOfThemes
                }
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateAreUnsolvedTasksUpdatedKey() {
        if let sort = sortType {
            if sort == .tasks {
                if let notUpdatedTasks = UserDefaults.standard.value(forKey: "notUpdatedUnsolvedTasks") as? [String] {
                    let leftTasks = notUpdatedTasks.filter({ $0 != theme })
                    UserDefaults.standard.set(leftTasks, forKey: "notUpdatedUnsolvedTasks")
                }
            }
            if sort == .themes {
                if let notUpdatedThemes = UserDefaults.standard.value(forKey: "notUpdatedUnsolvedThemes") as? [String] {
                    let leftThemes = notUpdatedThemes.filter({ $0 != theme })
                    UserDefaults.standard.set(leftThemes, forKey: "notUpdatedUnsolvedThemes")
                }
            }
        }
    }
    
    func getTasksByTasksFromCoreData(completion: @escaping (Bool) -> ()) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
            
            do {
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                let egeTask = trainer?.egeTasks?.first(where: { ($0 as! EgeTask).name == theme })
                if let newTasks = (egeTask as! EgeTask).tasks {
                    for task in newTasks {
                        let newTask = TaskModel()
                        newTask.alternativeAnswer = (task as! TaskData).alternativeAnswer
                        newTask.wrightAnswer = (task as! TaskData).wrightAnswer
                        newTask.serialNumber = Int((task as! TaskData).serialNumber)
                        newTask.stringAnswer = (task as! TaskData).stringAnswer
                        newTask.image = UIImage(data: (task as! TaskData).image ?? Data())
                        newTask.taskDescription = UIImage(data: (task as! TaskData).taskDescription ?? Data())
                        newTask.name = (task as! TaskData).name
                        tasks.append(newTask)
                    }
                }
                completion(true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func sortTasks() {
        tasks = tasks.sorted(by: {
            let (firstTheme, firstNumber) = getTaskLocation(taskName: $0.name ?? "")
            let (secondTheme, secondNumber) = getTaskLocation(taskName: $1.name ?? "")
            if getTaskPosition(taskName: firstTheme) == getTaskPosition(taskName: secondTheme) {
                return Int(firstNumber) ?? 0 < Int(secondNumber) ?? 0
            } else {
                return getTaskPosition(taskName: firstTheme) < getTaskPosition(taskName: secondTheme)
            }
        })
    }
    
    func getTasksByThemesFromCoreData(completion: @escaping (Bool) -> ()) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
            
            do {
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                let egeTheme = trainer?.egeThemes?.first(where: { ($0 as! EgeTheme).name == theme })
                if let newTasks = (egeTheme as! EgeTheme).tasks {
                    for task in newTasks {
                        let newTask = TaskModel()
                        newTask.alternativeAnswer = (task as! TaskData).alternativeAnswer
                        newTask.wrightAnswer = (task as! TaskData).wrightAnswer
                        newTask.serialNumber = Int((task as! TaskData).serialNumber)
                        newTask.stringAnswer = (task as! TaskData).stringAnswer
                        newTask.image = UIImage(data: (task as! TaskData).image ?? Data())
                        newTask.taskDescription = UIImage(data: (task as! TaskData).taskDescription ?? Data())
                        newTask.name = (task as! TaskData).name
                        tasks.append(newTask)
                    }
                }
                completion(true)
            } catch {
                print(error.localizedDescription)
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
    
    func getTaskPosition(taskName: String) -> Int {
        let (themeName, _) = getTaskLocation(taskName: taskName)
        if let range = themeName.range(of: "№") {
            let numberString = String(themeName[range.upperBound...])
            return Int(numberString) ?? 0
        }
        return 0
    }
    
    func saveTasksToCoreDataForSolved() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                let newTasks = NSMutableOrderedSet()
                for task in tasks {
                    let newTask = TaskData(context: context)
                    if let alternativeAnswer = task.alternativeAnswer {
                        newTask.alternativeAnswer = alternativeAnswer
                    }
                    if let wrightAnswer = task.wrightAnswer {
                        newTask.wrightAnswer = wrightAnswer
                    }
                    if let serialNumber = task.serialNumber {
                        newTask.serialNumber = Int16(serialNumber)
                    }
                    newTask.stringAnswer = task.stringAnswer
                    newTask.image = task.image?.pngData()
                    newTask.taskDescription = task.taskDescription?.pngData()
                    newTask.name = task.name
                    newTasks.add(newTask)
                }
                if let sort = sortType {
                    if sort == .tasks {
                        (trainer?.egeTasks?.first(where: { ($0 as! EgeTask).name == theme}) as! EgeTask).tasks = newTasks
                    }
                    if sort == .themes {
                        (trainer?.egeThemes?.first(where: { ($0 as! EgeTheme).name == theme}) as! EgeTheme).tasks = newTasks
                    }
                }
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateKeysInfoForSolved() {
        if let sort = sortType {
            if sort == .tasks {
                if let notUpdatedTasks = UserDefaults.standard.value(forKey: "notUpdatedTasks") as? [String] {
                    let leftTasks = notUpdatedTasks.filter({ $0 != theme })
                    UserDefaults.standard.set(leftTasks, forKey: "notUpdatedTasks")
                }
            }
            if sort == .themes {
                if let notUpdatedThemes = UserDefaults.standard.value(forKey: "notUpdatedThemes") as? [String] {
                    let leftThemes = notUpdatedThemes.filter({ $0 != theme })
                    UserDefaults.standard.set(leftThemes, forKey: "notUpdatedThemes")
                }
            }
        }
    }
    
    func getTasksByThemes(completion: @escaping (Bool) -> ()) {
        var goalTasks = [String:[Int]]()
        for task in themeTasks {
            let (themeName, taskNumberString) = getTaskLocation(taskName: task)
            if let taskNumber = Int(taskNumberString) {
                if goalTasks[themeName] != nil {
                    goalTasks[themeName]?.append(taskNumber)
                } else {
                    goalTasks[themeName] = [taskNumber]
                }
            }
        }
        tasks = []
        for dictKey in goalTasks.keys {
            themeReference.document(dictKey).collection("tasks").getDocuments { [weak self] (snapshot, error) in
                guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                    print("Error reading tasks in trainer list: \(String(describing: error?.localizedDescription))")
                    completion(false)
                    return
                }
                var lookingNumbers = goalTasks[dictKey]?.sorted(by: <)
                var index = 1
                for document in documents {
                    var number = 0
                    if lookingNumbers?.count != 0 {
                        number = lookingNumbers?.first ?? 0
                    }
                    if index == number {
                        let task = TaskModel()
                        task.serialNumber = document.data()[Task.serialNumber.rawValue] as? Int
                        task.wrightAnswer = document.data()[Task.wrightAnswer.rawValue] as? Double
                        task.alternativeAnswer = document.data()[Task.alternativeAnswer.rawValue] as? Double
                        task.stringAnswer = document.data()[Task.wrightAnswer.rawValue] as? String
                        task.succeded = document.data()[Task.succeded.rawValue] as? Int
                        task.failed = document.data()[Task.failed.rawValue] as? Int
                        task.name = dictKey + "." + "\(index)"
                        self.tasks.append(task)
                        lookingNumbers?.remove(at: 0)
                    }
                    index += 1
                }
                if self.themeTasks.count == self.tasks.count {
                    self.tasks = self.tasks.sorted(by: {
                        let (firstTheme, firstNumber) = self.getTaskLocation(taskName: $0.name ?? "")
                        let (secondTheme, secondNumber) = self.getTaskLocation(taskName: $1.name ?? "")
                        if self.getTaskPosition(taskName: firstTheme) == self.getTaskPosition(taskName: secondTheme) {
                            return Int(firstNumber) ?? 0 < Int(secondNumber) ?? 0
                        } else {
                            return self.getTaskPosition(taskName: firstTheme) < self.getTaskPosition(taskName: secondTheme)
                        }
                    })
                    self.downloadPhotos { (isReady) in
                        completion(isReady)
                    }
                }
            }
        }
    }
    
    func getTasksByTasks(completion: @escaping (Bool) -> ()) {
        guard let theme = theme else {
            completion(false)
            return
        }
        themeReference.document(theme).collection("tasks").getDocuments { (snapshot, error) in
            guard error == nil else {
                print("Error reading tasks: \(String(describing: error?.localizedDescription))")
                return
            }
            self.getUsersSolvedTasksFromCoreData()
            if let documents = snapshot?.documents {
                for document in documents {
                    let task = TaskModel()
                    task.serialNumber = document.data()[Task.serialNumber.rawValue] as? Int
                    task.wrightAnswer = document.data()[Task.wrightAnswer.rawValue] as? Double
                    task.alternativeAnswer = document.data()[Task.alternativeAnswer.rawValue] as? Double
                    task.stringAnswer = document.data()[Task.wrightAnswer.rawValue] as? String
                    task.succeded = document.data()[Task.succeded.rawValue] as? Int
                    task.failed = document.data()[Task.failed.rawValue] as? Int
                    task.name = theme + "." + "\(task.serialNumber ?? 0)"
                    if self.lookingForUnsolvedTasks ?? false {
                        if self.unsolvedTasks[theme]?.filter({ $0 == task.name }).count ?? 0 > 0 {
                            self.tasks.append(task)
                        }
                    } else {
                        self.tasks.append(task)
                    }
                }
                self.downloadPhotos { (isReady) in
                    completion(isReady)
                }
            }
        }
    }
    
    func getUsersSolvedTasksFromCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<User> = User.fetchRequest()
                let result = try context.fetch(fechRequest)
                if let user = result.first {
                    usersSolvedTasks = (user.solvedTasks as! StatusTasks).solvedTasks
                    firstTryTasks = (user.solvedTasks as! StatusTasks).firstTryTasks
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
//    func getUsersStats() {
//        if let userId = Auth.auth().currentUser?.uid {
//            userReference.document(userId).getDocument { [weak self] (document, error) in
//                guard let `self` = self, error == nil else { return }
//                if let solvedTasks = document?.data()?["solvedTasks"] as? [String:[String]] {
//                    self.usersSolvedTasks = solvedTasks
//                }
//            }
//        }
//    }
    
    func downloadPhotos(completion: @escaping (Bool) -> ()) {
        var count = 0
        for index in stride(from: 0, to: tasks.count, by: 1) {
            let (themeName, taskNumber) = getTaskLocation(taskName: tasks[index].name ?? "")
            let imageRef = Storage.storage().reference().child("trainer/\(themeName)/task\(taskNumber).png")
            imageRef.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in
                guard let `self` = self, error == nil else {
                    print("Error downloading images: \(String(describing: error?.localizedDescription))")
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    self.tasks[index].image = image
                    count += 1
                }
                if count == self.tasks.count {
                    self.downloadDescription { (isReady) in
                        completion(isReady)
                    }
                }
            }
        }
    }
    
    func downloadDescription(completion: @escaping (Bool) -> ()) {
        var count = 0
        for index in stride(from: 0, to: tasks.count, by: 1) {
            let (themeName, taskNumber) = getTaskLocation(taskName: tasks[index].name ?? "")
            let imageRef = Storage.storage().reference().child("trainer/\(themeName)/task\(taskNumber)description.png")
            imageRef.getData(maxSize: 1 * 2048 * 2048) { [weak self] data, error in
                guard let `self` = self, error == nil else {
                    print("Error downloading descriptions: \(String(describing: error?.localizedDescription))")
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    self.tasks[index].taskDescription = image
                    count += 1
                }
                if count == self.tasks.count {
                    if self.lookingForUnsolvedTasks != true {
                        self.updateKeysInfoForSolved()
                        self.saveTasksToCoreDataForSolved()
                    } else {
                        self.updateAreUnsolvedTasksUpdatedKey()
                        if let sort = self.sortType {
                            if sort == .tasks {
                                self.saveToCoreDataUnsolvedTasksByTasks()
                            }
                            if sort == .themes {
                                self.saveToCoreDataUnsolvedTasksByThemes()
                            }
                        }
                    }
                    completion(true)
                }
            }
        }
    }
    
    func checkIfTaskSolved(name: String) -> Bool {
        if let sort = sortType {
            if sort == .tasks {
                return usersSolvedTasks[theme ?? ""]?.filter({ $0 == name }).count ?? 0 > 0
            }
            if sort == .themes {
                for solvedArray in usersSolvedTasks.values {
                    if solvedArray.contains(name) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func checkIfTaskUnsolved(name: String) -> Bool {
        let (themeName, _) = getTaskLocation(taskName: name)
        return unsolvedTasks[themeName]?.contains(name) ?? false
    }
    
    func getDoneTasksNumber() -> Int {
        var doneTasksNumber = 0
        for task in tasks {
            if let taskName = task.name, (checkIfTaskSolved(name: taskName) || checkIfTaskUnsolved(name: taskName)) {
                doneTasksNumber += 1
            }
        }
        return doneTasksNumber
    }
    
    func getTasksNumber() -> Int {
        return tasks.count
    }
    
    func getFirstTryTasksNumber() -> Int {
        var firstTryTasksNumber = 0
        for task in tasks {
            if let taskName = task.name, firstTryTasks.contains(taskName) {
                firstTryTasksNumber += 1
            }
        }
        return firstTryTasksNumber
    }
    
    func getSolvedTasksNumber() -> Int {
        var solvedTasksNumber = 0
        for task in tasks {
            if let taskName = task.name, checkIfTaskSolved(name: taskName) {
                solvedTasksNumber += 1
            }
        }
        return solvedTasksNumber
    }
    
    func getTaskThemeImages(_ taskName: String) -> [UIImage] {
        let (task, number) = getTaskLocation(taskName: taskName)
        if let currentTaskThemes = tasksThemes[task], currentTaskThemes.count >= Int(number) ?? 1 {
            let currentTheme = currentTaskThemes[(Int(number) ?? 1) - 1]
            let allTaskThemes = ThemeParser.parseTaskThemes(currentTheme)
            return ThemeParser.getImageArray(forTaskThemes: allTaskThemes)
        }
        return [UIImage]()
    }
    
    func transportData(for viewModel: TaskViewModel, at index: Int) {
        viewModel.numberOfTasks = tasks.count
        viewModel.taskNumber = index + 1
        viewModel.theme = theme
        viewModel.task = tasks[index]
        viewModel.unsolvedTasks = unsolvedTasks
        viewModel.unsolvedTasksUpdater = self
        viewModel.solvedTasks = usersSolvedTasks
        viewModel.themesUnsolvedTasks = themesUnsolvedTasks
    }
}

extension TasksListViewModel: UnsolvedTaskUpdater {
    func updateUnsolvedTasks(with unsolvedTasks: [String : [String]], and solvedTasks: [String : [String]]?) {
        getUsersSolvedTasksFromCoreData()
        self.unsolvedTasks = unsolvedTasks
        usersSolvedTasks = solvedTasks ?? [:]
        if lookingForUnsolvedTasks ?? false {
            if let sort = sortType {
                if sort == .tasks {
                    self.tasks = self.tasks.filter({ unsolvedTasks[theme ?? ""]?.contains($0.name ?? "") ?? true })
                }
                if sort == .themes {
                    self.tasks = self.tasks.filter({ themesUnsolvedTasks[theme ?? ""]?.contains($0.name ?? "") ?? true })
                }
            }
        }
        if let taskUpdater = unsolvedTaskUpdater as? UnsolvedThemesViewModel {
            taskUpdater.themesUnsolvedTasks = themesUnsolvedTasks
        }
        unsolvedTaskUpdater?.updateUnsolvedTasks(with: unsolvedTasks, and: nil)
    }
}
