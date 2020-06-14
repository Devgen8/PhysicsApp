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
    
    let testReference = Firestore.firestore().collection("tests")
    var taskNumber = ""
    var searchedTask = TaskModel()
    var testName = ""
    var doesTaskExist = false
    var allTests = [String]()
    var wrightAnswer = ""
    var inverseState = false
    var stringState = false
    
    func updateTaskNumber(with number: String) {
        taskNumber = number
    }
    
    func clearOldData() {
        taskNumber = ""
        inverseState = false
        stringState = false
        searchedTask = TaskModel()
        doesTaskExist = false
        wrightAnswer = ""
        testName = allTests.first ?? ""
    }
    
    func searchTask(completion: @escaping (TaskModel?) -> ()) {
        searchedTask = TaskModel()
        Firestore.firestore().collection("tests").document(testName).collection("tasks").document("task" + taskNumber).getDocument { [weak self] (document, error) in
            guard let `self` = self, error == nil else {
                print("Could not find this task")
                completion(nil)
                return
            }
            self.searchedTask.alternativeAnswer = document?.data()?["alternativeAnswer"] as? Double
            self.searchedTask.serialNumber = Int(self.taskNumber)
            self.searchedTask.stringAnswer = document?.data()?["stringAnswer"] as? String
            self.searchedTask.wrightAnswer = document?.data()?["wrightAnswer"] as? Double
            self.getTaskImage { (task) in
                if task != nil {
                    self.doesTaskExist = true
                }
                completion(task)
            }
        }
    }
    
    func getTaskImage(completion: @escaping (TaskModel?) -> ()) {
        let imageRef = Storage.storage().reference().child("tests/\(testName)/task\(taskNumber).png")
        imageRef.getData(maxSize: 1 * 2048 * 2048) { [weak self] data, error in
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
    
    func getTaskDescription(completion: @escaping (TaskModel?) -> ()) {
        let imageRef = Storage.storage().reference().child("tests/\(testName)/task\(taskNumber)description.png")
        imageRef.getData(maxSize: 1 * 2048 * 2048) { [weak self] data, error in
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
    
    func updateWrightAnswer(with text: String) {
        wrightAnswer = text
    }

    func getTasksNumber() -> Int {
        return allTests.count
    }

    func getTask(for index: Int) -> String {
        return allTests[index]
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

    func updateStringState(to bool: Bool) {
        stringState = bool
    }

    func uploadNewTaskToTest(_ testName: String, completion: @escaping (Bool) -> ()) {
        if doesTaskExist, isAbleToUpload() {
            wrightAnswer = wrightAnswer.replacingOccurrences(of: ",", with: ".")
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
    
    func isAbleToUpload() -> Bool {
        guard
            searchedTask.image != nil, searchedTask.taskDescription != nil,
            wrightAnswer != "", taskNumber != "", testName != "" else {
                return false
        }
        return true
    }
    
    func uploadTaskImage(path: String) {
        if let data = searchedTask.image?.pngData() {
            Storage.storage().reference().child(path).putData(data)
        }
    }
    
    func uploadTaskDescription(path: String) {
        if let data = searchedTask.taskDescription?.pngData() {
            Storage.storage().reference().child(path).putData(data)
        }
    }
    
    func getKeyValuesForTask() -> [String : Any] {
        var taskData = [String : Any]()
        if stringState == true {
            taskData["stringAnswer"] = wrightAnswer
        } else {
            taskData["wrightAnswer"] = Double(wrightAnswer)
            if inverseState == true {
                let charactersArray = [Character](wrightAnswer)
                taskData["alternativeAnswer"] = Double(String([charactersArray[1], charactersArray[0]]))
            }
        }
        taskData["serialNumber"] = Int(taskNumber) ?? 1
        return taskData
    }

    func updateSelectedTask(with index: Int) {
        testName = allTests[index]
    }
    
    //we don't need this funcs here
    func uploadNewTaskToTrainer(completion: @escaping (Bool) -> ()) { }
    func updateSelectedTheme(with index: Int) { }
    func getSelectedTheme() -> String { return "" }
}
