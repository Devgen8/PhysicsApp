//
//  TaskImagesViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 05.08.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class TaskImagesViewModel {
    
    private var taskName = ""
    private var numberOfTasks = 0
    private var taskImages = [Int:UIImage]()
    private var taskDownloader: TaskDownloader?
    private var searchedTask = TaskModel()
    private var taskNumber = 0
    private var themes = [String]()
    private var currentMode: TrainerAdminMode!
    private var testTasks = [TaskModel]()
    
    func getTasksQuantity(completion: @escaping (Bool)->()) {
        if currentMode == TrainerAdminMode.editTask {
            getTasksNumberForTask { (isReady) in
                completion(isReady)
            }
        }
        if currentMode == TrainerAdminMode.editTest {
            getTasksNumberForTest { (isReady) in
                completion(isReady)
            }
        }
    }
    
    private func getTasksNumberForTask(completion: @escaping (Bool)->()) {
        Firestore.firestore().collection("trainer").document(taskName).getDocument { [weak self] (document, error) in
            guard let `self` = self, error == nil else {
                print("Problem with doc reading: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            self.numberOfTasks = document?.data()?["numberOfTasks"] as? Int ?? 0
            self.getTaskImage { (isReady) in
                completion(isReady)
            }
        }
    }
    
    private func getTasksNumberForTest(completion: @escaping (Bool)->()) {
        Firestore.firestore().collection("tests").document(taskName).collection("tasks").order(by: "serialNumber", descending: false).getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                print("Problem with doc reading: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            self.numberOfTasks = documents.count
            for document in documents {
                let newTask = TaskModel()
                newTask.alternativeAnswer = document.data()["alternativeAnswer"] as? Bool
                newTask.serialNumber = document.data()["serialNumber"] as? Int
                newTask.name = "task" + "\(newTask.serialNumber ?? 1)"
                newTask.theme = ""
                newTask.wrightAnswer = document.data()["wrightAnswer"] as? String
                self.testTasks.append(newTask)
            }
            self.downloadTestImages { (isReady) in
                completion(isReady)
            }
        }
    }
    
    private func downloadTestImages(completion: @escaping (Bool)->()) {
        var count = 0
        for taskNumber in 0..<numberOfTasks {
            let currentSerialNumber = self.testTasks[taskNumber].serialNumber ?? 1
            let imageRef = Storage.storage().reference().child("tests/\(taskName)/task\(currentSerialNumber).png")
            imageRef.getData(maxSize: 4 * 2048 * 2048) { [weak self] data, error in
                guard let `self` = self, error == nil else {
                    print("Error downloading descriptions: \(String(describing: error?.localizedDescription))")
                    completion(false)
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    self.testTasks[taskNumber].image = image
                    count += 1
                    if count == self.numberOfTasks {
                        completion(true)
                    }
                }
            }
        }
    }
    
    func getTaskName() -> String {
        return taskName
    }
    
    func setTaskName(_ name: String) {
        taskName = name
    }
    
    func getNumberOfTasks() -> Int {
        return numberOfTasks
    }
    
    func getImage(for index: Int) -> UIImage {
        if currentMode == TrainerAdminMode.editTest {
            return testTasks[index - 1].image ?? UIImage()
        }
        return taskImages[index] ?? UIImage()
    }
    
    func getSerialNumber(for index: Int) -> Int {
        return testTasks[index].serialNumber ?? 0
    }
    
    func getCurrentMode() -> TrainerAdminMode {
        return currentMode
    }
    
    func setTaskDownloader(_ loader: TaskDownloader) {
        taskDownloader = loader
    }
    
    func setCurrentMode(_ newMode: TrainerAdminMode) {
        currentMode = newMode
    }
    
    func downloadTask(_ number: Int, completion: @escaping (Bool)->()) {
        if currentMode == TrainerAdminMode.editTask {
            downloadTaskForTasks(number) { (isReady) in
                completion(isReady)
            }
        }
        if currentMode == TrainerAdminMode.editTest {
            downloadTaskForTests(number) { (isReady) in
                completion(isReady)
            }
        }
    }
    
    private func downloadTaskForTests(_ number: Int, completion: @escaping (Bool)->()) {
        searchedTask = testTasks[number - 1]
        getTaskDescription { (isReady) in
            completion(isReady)
        }
    }
    
    private func downloadTaskForTasks(_ number: Int, completion: @escaping (Bool)->()) {
        searchedTask = TaskModel()
        taskNumber = number
        Firestore.firestore().collection("trainer").document(taskName).getDocument { [weak self] (document, error) in
            guard let `self` = self, error == nil else {
                print("Could not find this task")
                completion(false)
                return
            }
            let themesOfSearchedTask = document?.data()?["themes"] as? [String] ?? []
            self.themes = themesOfSearchedTask
            self.searchedTask.theme = themesOfSearchedTask[number - 1]
            self.searchParticularTask { (isReady) in
                completion(isReady)
            }
        }
    }
    
    private func searchParticularTask(completion: @escaping (Bool) -> ()) {
        Firestore.firestore().collection("trainer").document(taskName).collection("tasks").whereField("serialNumber", isEqualTo: taskNumber).getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil, let document = snapshot?.documents.first else {
                print("Could not find this task")
                completion(false)
                return
            }
            self.searchedTask.name = self.taskName + "." + "\(self.taskNumber)"
            self.searchedTask.alternativeAnswer = document.data()["alternativeAnswer"] as? Bool
            self.searchedTask.serialNumber = self.taskNumber
            self.searchedTask.wrightAnswer = document.data()["wrightAnswer"] as? String
            self.searchedTask.image = self.taskImages[self.taskNumber]
            self.getTaskDescription { (isReady) in
                completion(isReady)
            }
        }
    }
    
    private func getTaskDescription(completion: @escaping (Bool) -> ()) {
        var path = ""
        if currentMode == TrainerAdminMode.editTask {
            path = "trainer/\(taskName)/task\(taskNumber)description.png"
        }
        if currentMode == TrainerAdminMode.editTest {
            path = "tests/\(taskName)/task\(searchedTask.serialNumber ?? 1)description.png"
        }
        let imageRef = Storage.storage().reference().child(path)
        imageRef.getData(maxSize: 4 * 2048 * 2048) { [weak self] data, error in
            guard let `self` = self, error == nil else {
                print("Error downloading descriptions: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            if let data = data, let image = UIImage(data: data) {
                self.searchedTask.taskDescription = image
                self.taskDownloader?.updateTaskModel(themes: self.themes, model: self.searchedTask)
                completion(true)
            }
        }
    }
    
    private func getTaskImage(completion: @escaping (Bool) -> ()) {
        var count = 0
        for taskNumber in 1...numberOfTasks {
            let imageRef = Storage.storage().reference().child("trainer/\(taskName)/task\(taskNumber).png")
            imageRef.getData(maxSize: 4 * 2048 * 2048) { [weak self] data, error in
                guard let `self` = self, error == nil else {
                    print("Error downloading descriptions: \(String(describing: error?.localizedDescription))")
                    completion(false)
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    self.taskImages[taskNumber] = image
                    count += 1
                    if count == self.numberOfTasks {
                        completion(true)
                    }
                }
            }
        }
    }
}
