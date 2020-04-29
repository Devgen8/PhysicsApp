//
//  DayMixViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 09.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class DayMixViewModel: MixViewModel {
    
    let userReference = Firestore.firestore().collection("users")
    let trainerReference = Firestore.firestore().collection("trainer")
    let egeReference = Firestore.firestore().collection("EGE")
    var taskNames = [String]()
    var tasks = [String:TaskModel]()
    var taskImages = [String:UIImage]()
    var unsolvedTasks = [String : [String]]()
    var solvedTasks = [String : [String]]()
    var numberOfTasksIn = [String : Int]()
    var baseTasks = [String]()
    var advancedTasks = [String]()
    var masterTasks = [String]()
    var mixName: String?
    
    func getNumberOfTasks() -> Int {
        return tasks.count
    }
    
    func getUsersName(completion: @escaping (String?) -> ()) {
        if let userId = Auth.auth().currentUser?.uid {
            userReference.document(userId).getDocument { (document, error) in
                guard error == nil else {
                    print("error reading users name: \(String(describing: error?.localizedDescription))")
                    return
                }
                completion(document?.data()?["name"] as? String)
            }
        }
    }
    
    func prepareUserTasks(completion: @escaping (Bool) -> ()) {
        if let userId = Auth.auth().currentUser?.uid {
            userReference.document(userId).getDocument { [weak self] (document, error) in
                guard error == nil else {
                    print("error reading solved and unsolved tasks: \(String(describing: error?.localizedDescription))")
                    return
                }
                if let mistakeTasks = document?.data()?["unsolvedTasks"] as? [String : [String]],
                    let wrightTasks = document?.data()?["solvedTasks"] as? [String : [String]] {
                    self?.solvedTasks = wrightTasks
                    self?.unsolvedTasks = mistakeTasks
                }
                self?.checkMixExistance { [weak self] (mixTasks) in
                    if let mixTasks = mixTasks {
                        self?.getTasksDifficulty(needRegulation: false, completion: { (_) in })
                        self?.taskNames = mixTasks
                        self?.prepareTaskModels(for: mixTasks, completion: { (isReady) in
                            completion(isReady)
                        })
                    } else {
                        self?.formDayMix(completion: { (isReady) in
                            completion(isReady)
                        })
                    }
                }
            }
        }
    }
    
    func checkMixExistance(completion: @escaping ([String]?) -> ()) {
        if let userId = Auth.auth().currentUser?.uid {
            userReference.document(userId).collection("mixes").document("dayMix").getDocument { (document, error) in
                guard error == nil else {
                    print("error reading day mix: \(String(describing: error?.localizedDescription))")
                    completion(nil)
                    return
                }
                let tasksFromDB = document?.data()?["tasks"] as? [String]
                if let dateStringFromDB = document?.data()?["date"] as? String {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd.MM.yyyy"
                    let dateString = dateFormatter.string(from: Date())
                    if dateString == dateStringFromDB {
                        completion(tasksFromDB)
                    } else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func prepareTaskModels(for mixTasks: [String], completion: @escaping (Bool) -> ()) {
        for mixTask in mixTasks {
            let (themeName, taskNumber) = getTaskLocation(taskName: mixTask)
            let taskName = "task" + taskNumber
            downloadPhoto(mixTask: mixTask, theme: themeName, taskName: taskName)
            downloadTask(mixTask: mixTask, theme: themeName, taskName: taskName) { (isReady) in
                completion(true)
            }
        }
    }
    
    func downloadTask(mixTask: String, theme: String, taskName: String, completion: @escaping (Bool) -> ()) {
        trainerReference.document(theme).collection("tasks").document(taskName).getDocument { [weak self] (document, error) in
            guard let `self` = self, error == nil else {
                print("error reading task for day mix: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            var task = TaskModel()
            task.alternativeAnswer = document?.data()?["alternativeAnswer"] as? Double
            task.failed = document?.data()?["failed"] as? Int
            task.name = document?.data()?["name"] as? String
            let serialNumber = document?.data()?["serialNumber"] as? Int
            task.serialNumber = serialNumber
            if let serialNumber = serialNumber {
                task.name = "Задача №\(serialNumber)"
            }
            task.stringAnswer = document?.data()?["stringAnswer"] as? String
            task.succeded = document?.data()?["succeded"] as? Int
            task.wrightAnswer = document?.data()?["wrightAnswer"] as? Double
            self.tasks[mixTask] = task
            if self.tasks.count == self.taskNames.count {
                completion(true)
            }
        }
    }
    
    func downloadPhoto(mixTask: String, theme: String, taskName: String) {
        let imageRef = Storage.storage().reference().child("trainer/\(theme)/\(taskName).png")
        imageRef.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in
            guard let `self` = self, error == nil else {
                print("Error downloading images: \(String(describing: error?.localizedDescription))")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                self.taskImages[mixTask] = image
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
    
    func getTaskName(for index: Int) -> String {
        return taskNames[index]
    }
    
    func transportData(for viewModel: TaskViewModel, at index: Int) {
        viewModel.numberOfTasks = taskNames.count
        viewModel.taskNumber = index + 1
        let (theme, _) = getTaskLocation(taskName: taskNames[index])
        viewModel.theme = theme
        tasks[taskNames[index]]?.image = taskImages[taskNames[index]]
        viewModel.task = tasks[taskNames[index]]
        viewModel.unsolvedTasks = unsolvedTasks
        viewModel.solvedTasks = solvedTasks
        viewModel.unsolvedTasksUpdater = self
    }
    
    func isTaskSolved(for index: Int) -> Bool {
        let (theme, taskNumber) = getTaskLocation(taskName: taskNames[index])
        let taskName = "Задача №" + taskNumber
        let isSolved = solvedTasks[theme]?.filter({ $0 == taskName }).count ?? 0 > 0
        return isSolved
    }
    
    func formDayMix(completion: @escaping (Bool) -> ()) {
        trainerReference.order(by: "themeNumber", descending: false).getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                print("Error reading themes info: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            var numberOfTasksInTheme = [String:Int]()
            for document in documents {
                if let themeName = document.data()["name"] as? String {
                    let numberOfTasks = document.data()["numberOfTasks"] as? Int
                    numberOfTasksInTheme[themeName] = numberOfTasks ?? 0
                }
            }
            self.numberOfTasksIn = numberOfTasksInTheme
            self.getTasksDifficulty(needRegulation: true) { (isReady) in
                completion(isReady)
            }
        }
    }
    
    func getTasksDifficulty(needRegulation: Bool, completion: @escaping (Bool) -> ()) {
        egeReference.document("scales").getDocument { [weak self] (document, error) in
            guard let `self` = self, error == nil else {
                print("Error reading ege tasks difficulty info: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            if let base = document?.data()?["baseTasks"] as? [String] {
                self.baseTasks = base
            }
            if let advanced = document?.data()?["advancedTasks"] as? [String] {
                self.advancedTasks = advanced
            }
            if let master = document?.data()?["masterTasks"] as? [String] {
                self.masterTasks = master
            }
            if needRegulation {
                self.regulateDifficulty { (isReady) in
                    completion(isReady)
                }
            }
        }
    }
    
    func regulateDifficulty(completion: @escaping (Bool) -> ()) {
        let srEge = UserStatsCounter.shared.srEGE
        if srEge >= 0 && srEge < 55 {
            createStarterPack { (isReady) in
                completion(isReady)
            }
        } else if srEge >= 55 && srEge < 65 {
            createMiddlePack { (isReady) in
                completion(isReady)
            }
        } else if srEge >= 65 && srEge < 75 {
            createAdvancedPack { (isReady) in
                completion(isReady)
            }
        } else {
            createMasterPack { (isReady) in
                completion(isReady)
            }
        }
    }
    
    func createStarterPack(completion: @escaping (Bool) -> ()) {
        let basePoints = getTasks(numberOfMistakeTasks: 8, numberOfNewTasks: 5, difficulty: .base)
        fullfillTasks(with: basePoints) { (isReady) in
            completion(isReady)
        }
    }
    
    func fullfillTasks(with points: Int, completion: @escaping (Bool) -> ()) {
        var restPoints = points
        let baseUnsolvedTasks = getSpecialTask(amountOfTasks: max(restPoints, 0), difficulty: .base, status: .unsolved)
        restPoints -= baseUnsolvedTasks.count
        let baseNewTasks = getSpecialTask(amountOfTasks: max(restPoints, 0), difficulty: .base, status: .new)
        restPoints -= baseNewTasks.count
        let advancedUnsolvedTasks = getSpecialTask(amountOfTasks: max(restPoints, 0) / 2, difficulty: .advanced, status: .unsolved)
        restPoints -= advancedUnsolvedTasks.count
        let advancedNewTasks = getSpecialTask(amountOfTasks: max(restPoints, 0) / 2, difficulty: .advanced, status: .new)
        restPoints -= advancedNewTasks.count
        let masterUnsolvedTasks = getSpecialTask(amountOfTasks: max(restPoints, 0) / 3, difficulty: .master, status: .unsolved)
        restPoints -= masterUnsolvedTasks.count
        let masterNewTasks = getSpecialTask(amountOfTasks: max(restPoints, 0) / 3, difficulty: .master, status: .new)
        restPoints -= masterNewTasks.count
        putMixToDataBase()
        prepareTaskModels(for: taskNames) { (isReady) in
            completion(isReady)
        }
    }
    
    func putMixToDataBase() {
        if let userId = Auth.auth().currentUser?.uid {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            let dateString = dateFormatter.string(from: Date())
            userReference.document(userId).collection("mixes").document("dayMix").updateData(["tasks" : taskNames,
                                                                                              "date" : dateString])
        }
    }
    
    func createMiddlePack(completion: @escaping (Bool) -> ()) {
        let basePoints = getTasks(numberOfMistakeTasks: 5, numberOfNewTasks: 3, difficulty: .base)
        
        let advancedPoints = getTasks(numberOfMistakeTasks: 5, numberOfNewTasks: 3, difficulty: .advanced)
        
        let points = basePoints + advancedPoints * 2
        fullfillTasks(with: points) { (isReady) in
            completion(isReady)
        }
    }
    
    func createAdvancedPack(completion: @escaping (Bool) -> ()) {
        let basePoints = getTasks(numberOfMistakeTasks: 2, numberOfNewTasks: 2, difficulty: .base)
        let advancedPoints = getTasks(numberOfMistakeTasks: 2, numberOfNewTasks: 2, difficulty: .advanced)
        let masterPoints = getTasks(numberOfMistakeTasks: 1, numberOfNewTasks: 1, difficulty: .master)
        
        let points = basePoints + advancedPoints * 2 + masterPoints * 3
        fullfillTasks(with: points) { (isReady) in
            completion(isReady)
        }
    }
    
    func createMasterPack(completion: @escaping (Bool) -> ()) {
        let basePoints = getTasks(numberOfMistakeTasks: 2, numberOfNewTasks: 2, difficulty: .base)
        let advancedPoints = getTasks(numberOfMistakeTasks: 2, numberOfNewTasks: 2, difficulty: .advanced)
        var masterPoints = getTasks(numberOfMistakeTasks: 1, numberOfNewTasks: 1, difficulty: .master)
        
        // get one quality task
        var qualityTasks = [String]()
        let theme = "Задание №27"
        if let numberOfQualityTasks = numberOfTasksIn[theme] {
            for taskNumber in 0..<numberOfQualityTasks {
                let taskName = "Задача №\(taskNumber + 1)"
                if !(solvedTasks[theme]?.contains(taskName) ?? false) {
                    qualityTasks.append(theme + "." + "\(taskNumber + 1)")
                }
            }
        }
        var foundTasks = [String]()
        if qualityTasks.count != 0 {
            let newTask = qualityTasks.remove(at: Int.random(in: 0..<qualityTasks.count))
            if !taskNames.contains(newTask) {
                foundTasks.append(newTask)
            }
        }
        taskNames += foundTasks
        if foundTasks.count == 1 {
            masterPoints -= 3
        }
        
        let points = basePoints + advancedPoints * 2 + masterPoints * 3
        fullfillTasks(with: points) { (isReady) in
            completion(isReady)
        }
    }
    
    func getTasks(numberOfMistakeTasks: Int, numberOfNewTasks: Int, difficulty: Difficulty) -> Int {
        var tasksWithMistake = getSpecialTask(amountOfTasks: numberOfMistakeTasks, difficulty: difficulty, status: .unsolved)
        var newTasks = getSpecialTask(amountOfTasks: numberOfNewTasks, difficulty: difficulty, status: .new)
        var numberOfAllTasks = tasksWithMistake.count + newTasks.count
        let expectedNumberOfTasks = numberOfMistakeTasks + numberOfNewTasks
        if numberOfAllTasks < expectedNumberOfTasks {
            let difference = expectedNumberOfTasks - numberOfAllTasks
            tasksWithMistake += getSpecialTask(amountOfTasks: difference, difficulty: difficulty, status: .unsolved)
        }
        numberOfAllTasks = tasksWithMistake.count + newTasks.count
        if numberOfAllTasks < expectedNumberOfTasks {
            let difference = expectedNumberOfTasks - numberOfAllTasks
            newTasks += getSpecialTask(amountOfTasks: difference, difficulty: difficulty, status: .new)
        }
        numberOfAllTasks = tasksWithMistake.count + newTasks.count
        return expectedNumberOfTasks - numberOfAllTasks
    }
    
    func getSpecialTask(amountOfTasks: Int, difficulty: Difficulty, status: TaskStatus) -> [String] {
        var difficultyLevelTasks = [String]()
        switch difficulty {
        case .base: difficultyLevelTasks = baseTasks
        case .advanced: difficultyLevelTasks = advancedTasks
        case .master: difficultyLevelTasks = masterTasks
        }
        var allLookingTasks = [String]()
        for themeName in difficultyLevelTasks {
            if let lastTaskNumber = numberOfTasksIn[themeName] {
                for taskNumber in 0..<lastTaskNumber {
                    let taskName = "Задача №\(taskNumber + 1)"
                    if !(solvedTasks[themeName]?.contains(taskName) ?? false),
                        ((status == .unsolved && (unsolvedTasks[themeName]?.contains(taskName) ?? false)) || (status == .new && !(unsolvedTasks[themeName]?.contains(taskName) ?? false))) {
                        allLookingTasks.append(themeName + "." + "\(taskNumber + 1)")
                    }
                }
            }
        }
        var foundTasks = [String]()
        for _ in 0..<amountOfTasks {
            if allLookingTasks.count != 0 && foundTasks.count != amountOfTasks {
                let newTask = allLookingTasks.remove(at: Int.random(in: 0..<allLookingTasks.count))
                if !taskNames.contains(newTask) {
                    foundTasks.append(newTask)
                }
            } else {
                break
            }
        }
        taskNames += foundTasks
        return foundTasks
    }
}

extension DayMixViewModel: UnsolvedTaskUpdater {
    func updateUnsolvedTasks(with unsolvedTasks: [String : [String]], and solvedTasks: [String : [String]]?) {
        self.unsolvedTasks = unsolvedTasks
        if let solvedTasks = solvedTasks {
             self.solvedTasks = solvedTasks
        }
    }
}
