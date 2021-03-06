//
//  TrainerViewModel.swift
//  TrainingApp
//
//  Created by мак on 18/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreData

class TrainerViewModel: TrainerViewModelProvider {
    
    //MARK: Fields
    
    private let tasksReference = Firestore.firestore().collection("trainer")
    private let usersReference = Firestore.firestore().collection("users")
    private var unsolvedTasks = [String:[String]]()
    private var solvedTasks = [String:[String]]()
    private var firstTryTasks = [String]()
    private var themes = [String]()
    private var numberOfTasksIn = [String:Int]()
    private var isFirstTimeReading = false
    private var egeTasksThemes = [String:[String]]()
    
    //MARK: Interface
    
    func getThemes(completion: @escaping (Bool) -> ()) {
        if let lastUpdateDate = UserDefaults.standard.value(forKey: "taskTypeUpdateDate") as? Date {
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
            isFirstTimeReading = true
            getThemesFromFirestore { (isReady) in
                completion(isReady)
            }
        }
    }
    
    func transportDataTo(_ viewModel: TasksListViewModel, at index: Int) {
        viewModel.setTheme(themes[index])
        viewModel.setUnsolvedTasks(unsolvedTasks)
        viewModel.unsolvedTaskUpdater = self
        viewModel.setSortType(.tasks)
    }
    
    func getTasksProgress(for index: Int) -> (Float, Float) {
        if let numberOfTasks = numberOfTasksIn[themes[index]] {
            let successProgress = Float(solvedTasks[themes[index]]?.count ?? 0) / Float(numberOfTasks)
            let mistakesProgress = successProgress + Float(unsolvedTasks[themes[index]]?.count ?? 0) / Float(numberOfTasks)
            return (successProgress, mistakesProgress)
        }
        return (0.0, 0.0)
    }
    
    func getThemesCount() -> Int {
        return themes.count
    }
    
    func getTheme(for index: Int) -> String {
        return themes[index]
    }
    
    func getUnsolvedTasks() -> [String : [String]] {
        return unsolvedTasks
    }
    
    func getUnsolvedTasksCount() -> Int {
        var tasksCount = 0
        for theme in unsolvedTasks.keys {
            tasksCount += unsolvedTasks[theme]?.count ?? 0
        }
        return tasksCount
    }
    
    //MARK: Private section
    
    // Firestore
    
    private func getThemesFromFirestore(completion: @escaping (Bool) -> ()) {
        tasksReference.order(by: "themeNumber", descending: false).getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                completion(false)
                return
            }
            var allThemes = [String]()
            var tasksThemes = [String:[String]]()
            for document in documents {
                if let themeName = document.data()[Theme.name.rawValue] as? String {
                    allThemes.append(themeName)
                    tasksThemes[themeName] = document.data()["themes"] as? [String] ?? []
                    if let numberOfTasks = document.data()["numberOfTasks"] as? Int {
                        self.numberOfTasksIn[themeName] = numberOfTasks
                    }
                }
            }
            self.themes = allThemes
            self.egeTasksThemes = tasksThemes
            if self.isFirstTimeReading {
                self.getUnsolvedTasks { (isReady) in
                    completion(isReady)
                }
            } else {
                self.updateKeysInfo()
                self.saveTasksInCoreData()
                self.getThemesFromCoreData { (isReady) in
                    completion(isReady)
                }
            }
        }
    }
    
    private func getUnsolvedTasks(completion: @escaping (Bool) -> ()) {
        if let userId = Auth.auth().currentUser?.uid {
            usersReference.document(userId).getDocument { [weak self] (document, error) in
                guard let `self` = self, error == nil, let document = document else {
                    print("Error reading unsolved tasks: \(String(describing: error?.localizedDescription))")
                    completion(false)
                    return
                }
                let mistakeTasks = document.data()?["unsolvedTasks"] as? [String : [String]]
                let wrightTasks = document.data()?["solvedTasks"] as? [String : [String]]
                let firstTryTasks = document.data()?["firstTryTasks"] as? [String]
                self.unsolvedTasks = mistakeTasks ?? [String:[String]]()
                self.solvedTasks = wrightTasks ?? [String:[String]]()
                self.firstTryTasks = firstTryTasks ?? [String]()
                self.saveTasksInCoreData()
                self.updateKeysInfo()
                completion(true)
            }
        } else {
            self.saveTasksInCoreData()
            self.updateKeysInfo()
            completion(true)
        }
    }
    
    // Core Data
    
    private func saveTasksInCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                //filling trainer
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                var trainer: Trainer?
                if result.isEmpty {
                    trainer = Trainer(context: context)
                } else {
                    trainer = result.first
                }
                let egeTasks = NSMutableSet()
                var index = 1
                for theme in themes {
                    let newTask = EgeTask(context: context)
                    newTask.name = theme
                    newTask.themeNumber = Int16(index)
                    if let tasksNumbers = numberOfTasksIn[theme] {
                        newTask.numberOfTasks = Int16(tasksNumbers)
                    }
                    newTask.themes = ThemesInEgeTask(egeTaskThemes: egeTasksThemes[theme] ?? [])
                    egeTasks.add(newTask)
                    index += 1
                }
                trainer?.egeTasks = egeTasks
                
                //filling user
                if isFirstTimeReading {
                    let userFechRequest: NSFetchRequest<User> = User.fetchRequest()
                    let userResult = try context.fetch(userFechRequest)
                    let newUser = userResult.first ?? User(context: context)
                    let statusTasks = StatusTasks(solvedTasks: solvedTasks,
                                                  unsolvedTasks: unsolvedTasks,
                                                  firstTryTasks: firstTryTasks)
                    let newStatusTasks: NSObject = statusTasks
                    newUser.solvedTasks = newStatusTasks
                }
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func getThemesFromCoreData(completion: @escaping (Bool) -> ()) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
            
            do {
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                if let egetasks = trainer?.egeTasks {
                    let sortedEgeTasks = egetasks.sorted { ($0 as! EgeTask).themeNumber < ($1 as! EgeTask).themeNumber }
                    themes = []
                    for egetask in sortedEgeTasks {
                        let task = (egetask as! EgeTask)
                        themes.append(task.name ?? "")
                        numberOfTasksIn[task.name ?? ""] = Int(task.numberOfTasks)
                    }
                }
                
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
    
    private func updateKeysInfo() {
        UserDefaults.standard.set(Date(), forKey: "taskTypeUpdateDate")
        UserDefaults.standard.set(themes, forKey: "notUpdatedTasks")
        UserDefaults.standard.set(themes, forKey: "notUpdatedUnsolvedTasks")
    }
}

extension TrainerViewModel: UnsolvedTaskUpdater {
    func updateUnsolvedTasks(with unsolvedTasks: [String : [String]], and solvedTasks: [String : [String]]?) {
        self.unsolvedTasks = unsolvedTasks
    }
}
