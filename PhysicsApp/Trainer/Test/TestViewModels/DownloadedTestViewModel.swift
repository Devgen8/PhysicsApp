//
//  TestViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 16.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CoreData

class DownloadedTestViewModel: TestViewModel {
    
    //MARK: Fields
    
    private var tasks = [TaskModel]()
    private let userReference = Firestore.firestore().collection("users")
    private var timeTillEnd = 14100
    private var wrightAnswers = [String:(String?, Bool?)]()
    private var tasksImages = [String:UIImage]()
    private var tasksDescriptions = [String:UIImage]()
    private var isTestCleared = false
    
    var name = ""
    var testAnswers = [String:String]()
    
    //MARK: Interface
    
    func getTestTasks(completion: @escaping (Bool) -> ()) {
        completion(true)
    }
    
    func isTestFinished() -> Bool {
        let finishedTests = UserDefaults.standard.value(forKey: "finishedTests") as? [String] ?? []
        return finishedTests.contains(name)
    }
    
    func saveUsersProgress(with time: Int) {
        saveProgressToCoreData(with: isTestCleared ? 14100 : time)
        if let userId = Auth.auth().currentUser?.uid, !NamesParser.isTestCustom(name) {
            userReference.document(userId).collection("tests").document(name).setData(["answers":testAnswers,
                                                                                       "time":time])
        }
    }
    
    func getTestName() -> String {
        return name
    }
    
    func getPhotoForTask(_ index: Int) -> UIImage {
        return tasksImages[tasks[index].name ?? ""] ?? UIImage()
    }
    
    func getTasksNumber() -> Int {
        return tasks.count
    }
    
    func writeAnswerForTask(_ index: Int, with answer: String) {
        testAnswers[tasks[index].name ?? ""] = answer
    }
    
    func getNextTaskIndex(after index: Int) -> Int {
        return index + 1
    }
    
    func getUsersAnswer(for taskIndex: Int) -> String {
        return testAnswers[tasks[taskIndex].name ?? ""] ?? ""
    }
    
    func getTimeTillEnd() -> Double {
        return Double(timeTillEnd)
    }
    
    func getFirstQuestionAnswer() -> String? {
        return testAnswers[tasks[0].name ?? ""]
    }
    
    func getMaxRatio() -> CGFloat {
        var maxRatio: CGFloat = 0
        for task in tasks {
            if (task.image?.size.height ?? 0) / (task.image?.size.width ?? 1) > maxRatio {
                maxRatio = (task.image?.size.height ?? 0) / (task.image?.size.width ?? 1)
            }
        }
        return maxRatio
    }
    
    func getTimeString(from allSeconds: Int) -> String {
        var hours = "\(allSeconds / 3600)"
        if hours.count == 1 {
            hours = "0" + hours
        }
        var minutes = "\((allSeconds % 3600) / 60)"
        if minutes.count == 1 {
            minutes = "0" + minutes
        }
        var seconds = "\((allSeconds % 3600) % 60)"
        if seconds.count == 1 {
            seconds = "0" + seconds
        }
        return "\(hours) : \(minutes) : \(seconds)"
    }
    
    func setTasks(_ newTasks: [TaskModel]) {
        tasks = newTasks
    }
    
    func setTimeTillEnd(_ newTime: Int) {
        timeTillEnd = newTime
    }
    
    func setWrightAnswers(_ newWrightAnswers: [String:(String?, Bool?)]) {
        wrightAnswers = newWrightAnswers
    }
    
    func setTaskImages(_ newTaskImages: [String:UIImage]) {
        tasksImages = newTaskImages
    }
    
    func setTaskDescriptions(_ newTaskDescriptions: [String:UIImage]) {
        tasksDescriptions = newTaskDescriptions
    }
    
    func setTestName(_ newName: String) {
        name = newName
    }
    
    func setTestAnswers(_ newTestAnswers: [String:String]) {
        testAnswers = newTestAnswers
    }
    
    func transportData(to viewModel: CPartTestViewModel, with time: Int) {
        viewModel.setTimeTillEnd(time)
        viewModel.setwrightAnswers(wrightAnswers)
        viewModel.setTestAnswers(testAnswers)
        viewModel.setTasksImages(tasksImages)
        viewModel.setName(name)
        viewModel.testAnswersUpdater = self
        viewModel.setTasks(tasks)
        viewModel.setTasksDescriptions(tasksDescriptions)
    }
    
    //MARK: Private section
    
    // Firestore and Storage
    
    private func getTasksFromFirestore(completion: @escaping (Bool) -> ()) {
        Firestore.firestore().collection("tests").document(name).collection("tasks").order(by: "serialNumber", descending: false).getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                print("Error reading test tasks: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            for document in documents {
                let task = TaskModel()
                task.serialNumber = document.data()[Task.serialNumber.rawValue] as? Int
                task.wrightAnswer = document.data()[Task.wrightAnswer.rawValue] as? String
                task.alternativeAnswer = document.data()[Task.alternativeAnswer.rawValue] as? Bool
                task.succeded = document.data()[Task.succeded.rawValue] as? Int
                task.failed = document.data()[Task.failed.rawValue] as? Int
                task.name = "Задание №\(task.serialNumber ?? 1)"
                self.testAnswers[task.name ?? ""] = ""
                self.wrightAnswers[task.name ?? ""] = (task.wrightAnswer, task.alternativeAnswer)
                self.tasks.append(task)
            }
            self.getUsersProgress { (isReady) in
                completion(isReady)
            }
        }
    }
    
    private func getUsersProgress(completion: @escaping (Bool) -> ()) {
        if let userId = Auth.auth().currentUser?.uid {
            userReference.document(userId).collection("tests").document(name).getDocument { [weak self] (document, error) in
                guard let `self` = self, error == nil else {
                    print("Error reading test tasks: \(String(describing: error?.localizedDescription))")
                    completion(false)
                    return
                }
                if let usersAnswers = document?.data()?["answers"] as? [String:String] {
                    self.testAnswers = usersAnswers
                }
                self.timeTillEnd = document?.data()?["time"] as? Int ?? 14100
                self.downloadPhotos { (isReady) in
                    completion(isReady)
                }
            }
        } else {
            self.downloadPhotos { (isReady) in
                completion(isReady)
            }
        }
    }
    
    private func downloadPhotos(completion: @escaping (Bool) -> ()) {
        var count = 0
        for index in stride(from: 0, to: tasks.count, by: 1) {
            let imageRef = Storage.storage().reference().child("tests/\(name)/task\(index + 1).png")
            imageRef.getData(maxSize: 4 * 2048 * 2048) { [weak self] data, error in
                guard let `self` = self, error == nil else {
                    print("Error downloading images: \(String(describing: error?.localizedDescription))")
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    let taskName = "Задание №\(index + 1)"
                    self.tasksImages[taskName] = image
                    self.tasks.first(where: { $0.name == taskName })?.image = image
                }
                count += 1
                if count == self.tasks.count {
                    self.downloadDesciptions { (isReady) in
                        completion(isReady)
                    }
                }
            }
        }
    }
    
    private func downloadDesciptions(completion: @escaping (Bool) -> ()) {
        var count = 0
        for index in stride(from: 0, to: tasks.count, by: 1) {
            let imageRef = Storage.storage().reference().child("tests/\(name)/task\(index + 1)description.png")
            imageRef.getData(maxSize: 4 * 2048 * 2048) { [weak self] data, error in
                guard let `self` = self, error == nil else {
                    print("Error downloading descriptions: \(String(describing: error?.localizedDescription))")
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    let taskName = "Задание №\(index + 1)"
                    self.tasksDescriptions[taskName] = image
                    self.tasks.first(where: { $0.name == taskName })?.taskDescription = image
                }
                count += 1
                if count == self.tasks.count {
                    self.updateKeysInfo()
                    self.saveTasksToCoreData()
                    completion(true)
                }
            }
        }
    }
    
    // Core Data
    
    private func getTasksFromCoreData(completion: @escaping (Bool) -> ()) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
            
            do {
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                if let currentTest = trainer?.tests?.first(where: { ($0 as! Test).name == name }) as? Test {
                    if let testObject = currentTest.testObject as? TestObject {
                        tasks = testObject.testTasks
                        testAnswers = testObject.usersAnswers
                        timeTillEnd = Int(currentTest.time)
                        for task in tasks {
                            wrightAnswers[task.name ?? ""] = (task.wrightAnswer, task.alternativeAnswer)
                            tasksImages[task.name ?? ""] = task.image
                            tasksDescriptions[task.name ?? ""] = task.taskDescription
                        }
                    }
                }
                
                completion(true)
                
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func saveTasksToCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                let isAnon = Auth.auth().currentUser == nil ? true : false
                (trainer?.tests?.first(where: { ($0 as! Test).name == name }) as! Test).time = isAnon ? 14100 : Int64(timeTillEnd)
                if isAnon {
                    for task in tasks {
                        testAnswers[task.name ?? ""] = ""
                    }
                }
                (trainer?.tests?.first(where: { ($0 as! Test).name == name }) as! Test).testObject = TestObject(testTasks: tasks, usersAnswers: testAnswers)
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func saveProgressToCoreData(with time: Int) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                if trainer?.tests?.first(where: { ($0 as! Test).name == name }) != nil {
                    (trainer?.tests?.first(where: { ($0 as! Test).name == name }) as! Test).time = Int64(time)
                    (trainer?.tests?.first(where: { ($0 as! Test).name == name }) as! Test).testObject = TestObject(testTasks: tasks, usersAnswers: testAnswers)
                    
                    try context.save()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateKeysInfo() {
        if let notUpdatedTests = UserDefaults.standard.value(forKey: "notUpdatedTests") as? [String] {
            let leftTests = notUpdatedTests.filter({ $0 != name })
            UserDefaults.standard.set(leftTests, forKey: "notUpdatedTests")
        }
    }
    
    private func deleteData() {
        var newAnswers = [String:String]()
        for index in 1...32 {
            newAnswers["Задание №\(index)"] = ""
        }
        testAnswers = newAnswers
        timeTillEnd = 14100
        isTestCleared = true
    }
    
    // unused methods
    func getCompletion() -> Float { return 0 }
}

extension DownloadedTestViewModel: TestAnswersUpdater {
    func deleteTestsAnswers() {
        deleteData()
    }
}
