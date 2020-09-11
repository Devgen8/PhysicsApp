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
    
    //MARK: Fields
    
    private let trainerReference = Firestore.firestore().collection("trainer")
    private var tasks = [String]()
    private var taskNumber = ""
    private var themes = [String]()
    private var selectedTask = ""
    private var inverseState = false
    private var themesOfSearchedTask = [String]()
    private var searchedTask = TaskModel()
    private var doesTaskExist = false
    private var wrightAnswer = ""
    
    //MARK: Interface
    
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
    
    func uploadNewTaskToTrainer(completion: @escaping (Bool) -> ()) {
        if doesTaskExist, isAbleToUpload() {
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
        } else {
            completion(false)
        }
    }
    
    func getTrainerData(completion: @escaping (Bool) -> ()) {
        tasks = EGEInfo.egeSystemTasks
        selectedTask = tasks[0]
        themes = EGEInfo.egeSystemThemes
        completion(true)
    }
    
    func clearOldData() {
        taskNumber = ""
        inverseState = false
        themesOfSearchedTask = [String]()
        searchedTask = TaskModel()
        doesTaskExist = false
        wrightAnswer = ""
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
    
    func updateTaskNumber(with number: String) {
        taskNumber = number
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
    
    func updateSearchedTask(_ model: TaskModel) {
        searchedTask = model
    }
    
    func updateTaskExistension(_ bool: Bool) {
        doesTaskExist = bool
    }
    
    func updateThemes(_ newThemes: [String]) {
        themesOfSearchedTask = newThemes
    }
    
    //MARK: Private section
    
    private func isAbleToUpload() -> Bool {
        guard
            searchedTask.image != nil, searchedTask.taskDescription != nil,
            searchedTask.theme != "", searchedTask.theme != nil,
            wrightAnswer != "", taskNumber != "" else {
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
    
    // Firestore and Storage
    
    private func searchParticularTask(completion: @escaping (TaskModel?) -> ()) {
        Firestore.firestore().collection("trainer").document(selectedTask).collection("tasks").whereField("serialNumber", isEqualTo: Int(taskNumber) ?? 0).getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil, let document = snapshot?.documents.first else {
                print("Could not find this task")
                completion(nil)
                return
            }
            self.searchedTask.name = self.selectedTask + "." + self.taskNumber
            self.searchedTask.alternativeAnswer = document.data()["alternativeAnswer"] as? Bool
            self.searchedTask.serialNumber = Int(self.taskNumber)
            self.searchedTask.wrightAnswer = document.data()["wrightAnswer"] as? String
            self.getTaskImage { (task) in
                completion(task)
            }
        }
    }
    
    private func getTaskImage(completion: @escaping (TaskModel?) -> ()) {
        let imageRef = Storage.storage().reference().child("trainer/\(selectedTask)/task\(taskNumber).png")
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
        let imageRef = Storage.storage().reference().child("trainer/\(selectedTask)/task\(taskNumber)description.png")
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
    
    //MARK: Unused required methods
    
    func uploadNewTaskToTest(_ testName: String, completion: @escaping (Bool) -> ()) {}
}

extension TrainerAdminEditTaskViewModel: SelectedThemesUpdater {
    func updateTheme(with theme: String) {
        searchedTask.theme = theme
    }
}
