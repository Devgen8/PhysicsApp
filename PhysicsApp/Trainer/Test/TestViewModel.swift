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

class TestViewModel {
    
    var name = ""
    var tasks = [TaskModel]()
    var testAnswers = [String:String]()
    let userReference = Firestore.firestore().collection("users")
    var timeTillEnd = 14100
    var wrightAnswers = [String:(Double?, Double?, String?)]()
    var tasksImages = [String:UIImage]()
    var tasksDescriptions = [String:UIImage]()
    
    func getTestTasks(completion: @escaping (Bool) -> ()) {
        if let notUpdatedTests = UserDefaults.standard.value(forKey: "notUpdatedTests") as? [String],
            notUpdatedTests.contains(name) {
            getTasksFromFirestore { (_) in
                completion(!self.isTestFinished())
            }
        } else {
            getTasksFromCoreData { (_) in
                completion(!self.isTestFinished())
            }
        }
    }
    
    func isTestFinished() -> Bool {
        let finishedTests = UserDefaults.standard.value(forKey: "finishedTests") as? [String] ?? []
        return finishedTests.contains(name)
    }
    
    func getTasksFromCoreData(completion: @escaping (Bool) -> ()) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
            
            do {
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                if let currentTest = trainer?.tests?.first(where: { ($0 as! Test).name == name }) as? Test {
                    let testObject = currentTest.testObject as! TestObject
                    tasks = testObject.testTasks
                    testAnswers = testObject.usersAnswers
                    timeTillEnd = Int(currentTest.time)
                    for task in tasks {
                        wrightAnswers[task.name ?? ""] = (task.wrightAnswer, task.alternativeAnswer, task.stringAnswer)
                        tasksImages[task.name ?? ""] = task.image
                        tasksDescriptions[task.name ?? ""] = task.taskDescription
                    }
                }
                
                completion(true)
                
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveTasksToCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                (trainer?.tests?.first(where: { ($0 as! Test).name == name }) as! Test).time = Int64(timeTillEnd)
                (trainer?.tests?.first(where: { ($0 as! Test).name == name }) as! Test).testObject = TestObject(testTasks: tasks, usersAnswers: testAnswers)
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func updateKeysInfo() {
        if let notUpdatedTests = UserDefaults.standard.value(forKey: "notUpdatedTests") as? [String] {
            let leftTests = notUpdatedTests.filter({ $0 != name })
            UserDefaults.standard.set(leftTests, forKey: "notUpdatedTests")
        }
    }
    
    func getTasksFromFirestore(completion: @escaping (Bool) -> ()) {
        Firestore.firestore().collection("tests").document(name).collection("tasks").order(by: "serialNumber", descending: false).getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                print("Error reading test tasks: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            for document in documents {
                let task = TaskModel()
                task.serialNumber = document.data()[Task.serialNumber.rawValue] as? Int
                task.wrightAnswer = document.data()[Task.wrightAnswer.rawValue] as? Double
                task.alternativeAnswer = document.data()[Task.alternativeAnswer.rawValue] as? Double
                task.stringAnswer = document.data()[Task.wrightAnswer.rawValue] as? String
                task.succeded = document.data()[Task.succeded.rawValue] as? Int
                task.failed = document.data()[Task.failed.rawValue] as? Int
                task.name = "Задание №\(task.serialNumber ?? 1)"
                self.testAnswers[task.name ?? ""] = ""
                self.wrightAnswers[task.name ?? ""] = (task.wrightAnswer, task.alternativeAnswer, task.stringAnswer)
                self.tasks.append(task)
            }
            self.getUsersProgress { (isReady) in
                completion(isReady)
            }
        }
    }
    
    func downloadPhotos(completion: @escaping (Bool) -> ()) {
        var count = 0
        for index in stride(from: 0, to: tasks.count, by: 1) {
            let imageRef = Storage.storage().reference().child("tests/\(name)/task\(index + 1).png")
            imageRef.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in
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
    
    func downloadDesciptions(completion: @escaping (Bool) -> ()) {
        var count = 0
        for index in stride(from: 0, to: tasks.count, by: 1) {
            let imageRef = Storage.storage().reference().child("tests/\(name)/task\(index + 1)description.png")
            imageRef.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in
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
    
    func saveUsersProgress(with time: Int) {
        saveProgressToCoreData(with: time)
        if let userId = Auth.auth().currentUser?.uid {
            userReference.document(userId).collection("tests").document(name).setData(["answers":testAnswers,
                                                                                       "time":time])
        }
    }
    
    func saveProgressToCoreData(with time: Int) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                (trainer?.tests?.first(where: { ($0 as! Test).name == name }) as! Test).time = Int64(time)
                (trainer?.tests?.first(where: { ($0 as! Test).name == name }) as! Test).testObject = TestObject(testTasks: tasks, usersAnswers: testAnswers)
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getUsersProgress(completion: @escaping (Bool) -> ()) {
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
        }
    }
    
    func getPhotoForTask(_ index: Int) -> UIImage {
        return tasksImages["Задание №\(index + 1)"] ?? UIImage()
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
        return testAnswers["Задание №1"]
    }
    
    func transportData(to viewModel: CPartTestViewModel, with time: Int) {
        viewModel.timeTillEnd = time
        viewModel.wrightAnswers = wrightAnswers
        viewModel.testAnswers = testAnswers
        viewModel.tasksImages = tasksImages
        viewModel.name = name
        viewModel.testAnswersUpdater = self
        //deleteData()
    }
    
    func deleteData() {
        var newAnswers = [String:String]()
        for index in 1...32 {
            newAnswers["Задание №\(index)"] = ""
        }
        testAnswers = newAnswers
        timeTillEnd = 14100
    }
}

extension TestViewModel: TestAnswersUpdater {
    func deleteTestsAnswers() {
        deleteData()
    }
}
