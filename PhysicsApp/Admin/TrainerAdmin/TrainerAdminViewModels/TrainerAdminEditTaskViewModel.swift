//
//  TrainerAdminEditTaskViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 13.06.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class TrainerAdminEditTaskViewModel: TrainerAdminViewModel {
    
    let trainerReference = Firestore.firestore().collection("trainer")
    var tasks = [String]()
    var taskNumber = "1"
    var themes = [String]()
    var selectedTask = ""
    var inverseState = false
    var stringState = false
    var themesOfSearchedTask = [String]()
    var searchedTask = TaskModel()
    var doesTaskExist = false
    var wrightAnswer = ""
    
    func getTrainerData(completion: @escaping (Bool) -> ()) {
        tasks = EGEInfo.egeSystemTasks
        selectedTask = tasks[0]
        themes = EGEInfo.egeSystemThemes
        completion(true)
    }

    func updateWrightAnswer(with text: String) {
        wrightAnswer = text
    }

    func getTasksNumber() -> Int {
        return tasks.count
    }

    func getTask(for index: Int) -> String {
        return tasks[index]
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
    
    func updateTaskNumber(with number: String) {
        taskNumber = number
    }
    
    func uploadNewTaskToTrainer(completion: @escaping (Bool) -> ()) {
        if doesTaskExist {
            wrightAnswer = wrightAnswer.replacingOccurrences(of: ",", with: ".")
            wrightAnswer = wrightAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
            let newTheme = searchedTask.theme ?? ""
            themesOfSearchedTask[(Int(taskNumber) ?? 1) - 1] = newTheme
            trainerReference.document(selectedTask).updateData(["numberOfTasks" : themesOfSearchedTask.count,
                                                                          "themes" : themesOfSearchedTask])
            let newKeyValuePairs = getKeyValuesForTask()
            trainerReference.document(selectedTask).collection("tasks").document("task\(Int(taskNumber) ?? 1)").setData(newKeyValuePairs)
            uploadTaskImage(path: "trainer/\(selectedTask)/task\(Int(taskNumber) ?? 1).png")
            uploadTaskDescription(path: "trainer/\(selectedTask)/task\(Int(taskNumber) ?? 1)description.png")
            completion(true)
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
    
    func searchTask(completion: @escaping (TaskModel?) -> ()) {
        searchedTask = TaskModel()
        Firestore.firestore().collection("trainer").document(selectedTask).getDocument { [weak self] (document, error) in
            guard let `self` = self, error == nil else {
                print("Could not find this task")
                completion(nil)
                return
            }
            self.themesOfSearchedTask = document?.data()?["themes"] as? [String] ?? []
            if self.themesOfSearchedTask.count < (Int(self.taskNumber) ?? 0) || (Int(self.taskNumber) ?? 0) <= 0 {
                completion(nil)
                return
            }
            self.searchedTask.theme = self.themesOfSearchedTask[(Int(self.taskNumber) ?? 1) - 1]
            self.searchParticularTask { (task) in
                if task != nil {
                    self.doesTaskExist = true
                }
                completion(task)
            }
        }
    }
    
    func searchParticularTask(completion: @escaping (TaskModel?) -> ()) {
        Firestore.firestore().collection("trainer").document(selectedTask).collection("tasks").whereField("serialNumber", isEqualTo: Int(taskNumber) ?? 0).getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil, let document = snapshot?.documents.first else {
                print("Could not find this task")
                completion(nil)
                return
            }
            self.searchedTask.name = self.selectedTask + "." + self.taskNumber
            self.searchedTask.alternativeAnswer = document.data()["alternativeAnswer"] as? Double
            self.searchedTask.serialNumber = Int(self.taskNumber)
            self.searchedTask.stringAnswer = document.data()["stringAnswer"] as? String
            self.searchedTask.wrightAnswer = document.data()["wrightAnswer"] as? Double
            self.getTaskImage { (task) in
                completion(task)
            }
        }
    }
    
    func getTaskImage(completion: @escaping (TaskModel?) -> ()) {
        let imageRef = Storage.storage().reference().child("trainer/\(selectedTask)/task\(taskNumber).png")
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
        let imageRef = Storage.storage().reference().child("trainer/\(selectedTask)/task\(taskNumber)description.png")
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

    func updateSelectedTask(with index: Int) {
        selectedTask = tasks[index]
    }

    func updateSelectedTheme(with index: Int) {
        searchedTask.theme = themes[index]
    }

    func getSelectedTheme() -> String {
        return searchedTask.theme ?? ""
    }
    
    // we don't need it here
    func uploadNewTaskToTest(_ testName: String, completion: @escaping (Bool) -> ()) {
        
    }
}

extension TrainerAdminEditTaskViewModel: SelectedThemesUpdater {
    func updateTheme(with theme: String) {
        searchedTask.theme = theme
    }
}
