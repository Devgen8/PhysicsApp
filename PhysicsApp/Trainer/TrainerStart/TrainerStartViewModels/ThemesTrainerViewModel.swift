//
//  ThemesTrainerViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 15.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreData

class ThemesTrainerViewModel: TrainerViewModelProvider {
    
    let trainerReference = Firestore.firestore().collection("trainer")
    let usersReference = Firestore.firestore().collection("users")
    var themes = [String]()
    var unsolvedTasks = [String : [String]]()
    var solvedTasks = [String : [String]]()
    var tasks = [String:[String]]()
    var numberOfUnsolvedTasks = 0
    
    func getThemes(completion: @escaping (Bool) -> ()) {
        if let lastUpdateDate = UserDefaults.standard.value(forKey: "themeTypeUpdateDate") as? Date {
            if DateWorker.checkForUpdate(from: lastUpdateDate) {
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
    
    func getThemesFromFirestore(completion: @escaping (Bool) -> ()) {
        themes = EGEInfo.egeSystemThemes
        getThemeTasks { (isReady) in
            completion(isReady)
        }
    }
    
    func saveTasksInCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                let egeThemes = NSMutableSet()
                for theme in themes {
                    let newTask = EgeTheme(context: context)
                    newTask.name = theme
                    egeThemes.add(newTask)
                }
                trainer?.egeThemes = egeThemes
                trainer?.themeTasksSafe = ThemeTasksSafe(tasks: tasks)
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func getThemesFromCoreData(completion: @escaping (Bool) -> ()) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
            
            do {
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                if let egeThemes = trainer?.egeThemes {
                    let sortedEgeThemes = egeThemes.sorted { (firstTheme, secondTheme) in
                        if let firstName = (firstTheme as! EgeTheme).name,
                            let secondName = (secondTheme as! EgeTheme).name {
                            return firstName > secondName
                        }
                        return true
                    }
                    themes = []
                    for egeTheme in sortedEgeThemes {
                        let theme = (egeTheme as! EgeTheme)
                        themes.append(theme.name ?? "")
                    }
                }
                tasks = (trainer?.themeTasksSafe as! ThemeTasksSafe).tasks
                
                if let user = try context.fetch(userFetchRequest).first {
                    let statusTasks = user.solvedTasks as! StatusTasks
                    unsolvedTasks = statusTasks.unsolvedTasks
                    solvedTasks = statusTasks.solvedTasks
                }
                completion(true)
                
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateKeysInfo() {
        UserDefaults.standard.set(Date(), forKey: "themeTypeUpdateDate")
        UserDefaults.standard.set(themes, forKey: "notUpdatedThemes")
        UserDefaults.standard.set(themes, forKey: "notUpdatedUnsolvedThemes")
    }
    
    func getThemeTasks(completion: @escaping (Bool) -> ()) {
        for themeName in themes {
            tasks[themeName] = [String]()
        }
        trainerReference.getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                print("Error reading tasks for themes trainer: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            for document in documents {
                if let egeThemes = document.data()["themes"] as? [String],
                    let taskName = document.data()["name"] as? String {
                    var index = 1
                    for themeName in egeThemes {
                        let allThemesInTask = ThemeParser.parseTaskThemes(themeName)
                        for taskTheme in allThemesInTask {
                            if self.tasks[taskTheme] != nil {
                                self.tasks[taskTheme]?.append(taskName + "." + "\(index)")
                            } else {
                                self.tasks[taskTheme] = [taskName + "." + "\(index)"]
                            }
                        }
                        index += 1
                    }
                }
            }
            self.saveTasksInCoreData()
            self.updateKeysInfo()
            self.getThemesFromCoreData { (isReady) in
                completion(isReady)
            }
        }
    }
    
//    func getUnsolvedTasks(completion: @escaping (Bool) -> ()) {
//        if let userId = Auth.auth().currentUser?.uid {
//            usersReference.document(userId).getDocument { [weak self] (document, error) in
//                guard let `self` = self, error == nil, let document = document else {
//                    print("Error reading unsolved tasks: \(String(describing: error?.localizedDescription))")
//                    completion(false)
//                    return
//                }
//                let mistakeTasks = document.data()?["unsolvedTasks"] as? [String : [String]]
//                let wrightTasks = document.data()?["solvedTasks"] as? [String : [String]]
//                self.unsolvedTasks = mistakeTasks ?? [String:[String]]()
//                self.solvedTasks = wrightTasks ?? [String:[String]]()
//                completion(true)
//            }
//        }
//    }
    
    func getThemesCount() -> Int {
        return themes.count
    }
    
    func getTheme(for index: Int) -> String {
        return themes[index].uppercased()
    }
    
    func getTasksProgress(for index: Int) -> (Float, Float) {
        var successCount = 0
        var mistakesCount = 0
        for unsolvedArray in unsolvedTasks.values {
            if let themeTasks = tasks[themes[index]] {
                for taskName in themeTasks {
                    if unsolvedArray.contains(taskName) {
                        mistakesCount += 1
                    }
                }
            }
        }
        for solvedArray in solvedTasks.values {
            if let themeTasks = tasks[themes[index]] {
                for taskName in themeTasks {
                    if solvedArray.contains(taskName) {
                        successCount += 1
                    }
                }
            }
        }
        numberOfUnsolvedTasks = mistakesCount
        if successCount != 0 || mistakesCount != 0, let numberOfTasks = tasks[themes[index]]?.count, numberOfTasks != 0 {
            let successProgress = Float(successCount) / Float(numberOfTasks)
            let mistakesProgress = successProgress + Float(mistakesCount) / Float(numberOfTasks)
            return (successProgress, mistakesProgress)
        }
        return (0.0, 0.0)
    }
    
    func getUnsolvedTasksCount() -> Int {
        var tasksCount = 0
        for theme in unsolvedTasks.keys {
            tasksCount += unsolvedTasks[theme]?.count ?? 0
        }
        return tasksCount
    }
    
    func getUnsolvedTasks() -> [String : [String]] {
        var themesUnsolvedTasks = [String : [String]]()
        for themeName in themes {
            themesUnsolvedTasks[themeName] = [String]()
        }
        for unsolvedArray in unsolvedTasks.values {
            for unsolvedTask in unsolvedArray {
                for themeName in themes {
                    if tasks[themeName]?.contains(unsolvedTask) ?? false {
                        themesUnsolvedTasks[themeName]?.append(unsolvedTask)
                    }
                }
            }
        }
        return themesUnsolvedTasks
    }
    
    func transportDataTo(_ viewModel: TasksListViewModel, at index: Int) {
        viewModel.theme = themes[index]
        viewModel.unsolvedTasks = unsolvedTasks
        viewModel.unsolvedTaskUpdater = self
        viewModel.sortType = .themes
        viewModel.themeTasks = tasks[themes[index]] ?? []
        viewModel.usersSolvedTasks = solvedTasks
    }
}

extension ThemesTrainerViewModel: UnsolvedTaskUpdater {
    func updateUnsolvedTasks(with unsolvedTasks: [String : [String]], and solvedTasks: [String : [String]]?) {
        self.unsolvedTasks = unsolvedTasks
    }
}
