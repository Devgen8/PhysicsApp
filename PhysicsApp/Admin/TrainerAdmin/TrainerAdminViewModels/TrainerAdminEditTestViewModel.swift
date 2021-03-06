//
//  TrainerAdminEditTestViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 13.06.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class TrainerAdminEditTestViewModel: TrainerAdminViewModel {
    
    //MARK: Fields
    
    private let testReference = Firestore.firestore().collection("tests")
    private var taskNumber = ""
    private var searchedTask = TaskModel()
    private var testName = ""
    private var doesTaskExist = false
    private var allTests = [String]()
    private var wrightAnswer = ""
    private var inverseState = false
    
    //MARK: Interface
    
    func getTrainerData(completion: @escaping (Bool) -> ()) {
        if let tests = UserDefaults.standard.value(forKey: "adminTests") as? [String] {
            allTests = tests
            if !allTests.isEmpty {
                testName = allTests.first ?? ""
            }
            completion(true)
            return
        }
        Firestore.firestore().collection("tests").getDocuments { (snapshot, error) in
            guard error == nil, let documents = snapshot?.documents else {
                print(String(describing: error?.localizedDescription))
                completion(false)
                return
            }
            var tests = [String]()
            for document in documents {
                if let test = document.data()["name"] as? String {
                    tests.append(test)
                }
            }
            self.allTests = tests
            if !tests.isEmpty {
                self.testName = tests.first ?? ""
            }
            UserDefaults.standard.set(tests, forKey: "adminTests")
            completion(true)
        }
    }
    
    func searchTask(completion: @escaping (TaskModel?) -> ()) {
        searchedTask = TaskModel()
        Firestore.firestore().collection("tests").document(testName).collection("tasks").document("task" + taskNumber).getDocument { [weak self] (document, error) in
            guard let `self` = self, error == nil else {
                print("Could not find this task")
                completion(nil)
                return
            }
            self.searchedTask.alternativeAnswer = document?.data()?["alternativeAnswer"] as? Bool
            self.searchedTask.serialNumber = Int(self.taskNumber)
            self.searchedTask.wrightAnswer = document?.data()?["wrightAnswer"] as? String
            self.getTaskImage { (task) in
                if task != nil {
                    self.doesTaskExist = true
                }
                completion(task)
            }
        }
    }
    
    func uploadNewTaskToTest(_ testName: String, completion: @escaping (Bool) -> ()) {
        if doesTaskExist, isAbleToUpload() {
            wrightAnswer = wrightAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
            let newKeyValuePairs = self.getKeyValuesForTask()
            testReference.document(self.testName).collection("tasks").document("task\(taskNumber)").setData(newKeyValuePairs)
            uploadTaskImage(path: "tests/\(self.testName)/task\(taskNumber).png")
            uploadTaskDescription(path: "tests/\(self.testName)/task\(taskNumber)description.png")
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func updateTaskNumber(with number: String) {
        taskNumber = number
    }
    
    func clearOldData() {
        taskNumber = ""
        inverseState = false
        searchedTask = TaskModel()
        doesTaskExist = false
        wrightAnswer = ""
    }
    
    func updateWrightAnswer(with text: String) {
        wrightAnswer = text
    }

    func getTasksNumber() -> Int {
        return allTests.count
    }

    func getTask(for index: Int) -> String {
        if allTests.count > index {
            return allTests[index]
        }
        return ""
    }

    func updatePhotoData(with data: Data) {
        searchedTask.image = UIImage(data: data)
    }

    func updateTaskDescription(with data: Data) {
        searchedTask.taskDescription = UIImage(data: data)
    }

    func updateInverseState(to bool: Bool) {
        inverseState = bool
    }
    
    func updateSelectedTask(with index: Int) {
        testName = allTests[index]
    }
    
    func setSearchedTask(_ newTask: TaskModel) {
        searchedTask = newTask
    }
    
    func updateTaskExistension(_ bool: Bool) {
        doesTaskExist = bool
    }
    
    //MARK: Private section
    
    private func isAbleToUpload() -> Bool {
        guard
            searchedTask.image != nil, searchedTask.taskDescription != nil,
            wrightAnswer != "", taskNumber != "", testName != "" else {
                return false
        }
        return true
    }
    
    private func getKeyValuesForTask() -> [String : Any] {
        var taskData = [String : Any]()
        taskData["wrightAnswer"] = wrightAnswer
        if inverseState == true {
            taskData["alternativeAnswer"] = true
        }
        taskData["serialNumber"] = Int(taskNumber) ?? 1
        return taskData
    }
    
    // Storage
    
    private func getTaskImage(completion: @escaping (TaskModel?) -> ()) {
        let imageRef = Storage.storage().reference().child("tests/\(testName)/task\(taskNumber).png")
        imageRef.getData(maxSize: 4 * 2048 * 2048) { [weak self] data, error in
            guard let `self` = self, error == nil else {
                print("Error downloading descriptions: \(String(describing: error?.localizedDescription))")
                completion(nil)
                return
            }
            if let data = data, let image = UIImage(data: data) {
                self.searchedTask.image = image
                self.getTaskDescription { (task) in
                    completion(task)
                }
            }
        }
    }
    
    private func getTaskDescription(completion: @escaping (TaskModel?) -> ()) {
        let imageRef = Storage.storage().reference().child("tests/\(testName)/task\(taskNumber)description.png")
        imageRef.getData(maxSize: 4 * 2048 * 2048) { [weak self] data, error in
            guard let `self` = self, error == nil else {
                print("Error downloading descriptions: \(String(describing: error?.localizedDescription))")
                completion(nil)
                return
            }
            if let data = data, let image = UIImage(data: data) {
                self.searchedTask.taskDescription = image
                completion(self.searchedTask)
            }
        }
    }
    
    private func uploadTaskImage(path: String) {
        if let data = searchedTask.image?.pngData() {
            Storage.storage().reference().child(path).putData(data)
        }
    }
    
    private func uploadTaskDescription(path: String) {
        if let data = searchedTask.taskDescription?.pngData() {
            Storage.storage().reference().child(path).putData(data)
        }
    }
    
    //MARK: Unused reqiured method
    
    func uploadNewTaskToTrainer(completion: @escaping (Bool) -> ()) { }
    func updateSelectedTheme(with index: Int) { }
    func getSelectedTheme() -> String { return "" }
}
