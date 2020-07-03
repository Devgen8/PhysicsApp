//
//  TrainerAdminViewModel.swift
//  TrainingApp
//
//  Created by мак on 24/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class TrainerAdminAddViewModel: TrainerAdminViewModel {
    
    //MARK: Fields
    
    private let trainerReference = Firestore.firestore().collection("trainer")
    private let testReference = Firestore.firestore().collection("tests")
    private var tasks = [String]()
    private var themes = [String]()
    private var imageData: Data?
    private var descriptionImageData: Data?
    private var selectedTask: String?
    private var selectedTheme = ""
    private var inverseState = false
    private var stringState = false
    private var tasksNumber = 0
    private var taskThemes = [String]()
    private var wrightAnswer = ""
    
    //MARK: Interface
    
    func getTrainerData(completion: @escaping (Bool) -> ()) {
        tasks = EGEInfo.egeSystemTasks
        selectedTask = tasks[0]
        themes = EGEInfo.egeSystemThemes
        completion(true)
    }
    
    func clearOldData() {
        imageData = nil
        descriptionImageData = nil
        selectedTask = tasks.first
        selectedTheme = ""
        inverseState = false
        stringState = false
        wrightAnswer = ""
    }
    
    func uploadNewTaskToTest(_ testName: String, completion: @escaping (Bool) -> ()) {
        wrightAnswer = wrightAnswer.replacingOccurrences(of: ",", with: ".")
        wrightAnswer = wrightAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard testName != "", isAbleToUpload() else {
            completion(false)
            return
        }
        testReference.document(testName).setData(["name":testName])
        let taskNumber = getSelectedTaskNumber()
        var newKeyValuePairs = self.getKeyValuesForTask()
        newKeyValuePairs["serialNumber"] = taskNumber
        testReference.document(testName).collection("tasks").document("task\(taskNumber)").setData(newKeyValuePairs)
        uploadTaskImage(path: "tests/\(testName)/task\(taskNumber).png")
        uploadTaskDescription(path: "tests/\(testName)/task\(taskNumber)description.png")
        completion(true)
    }
    
    func uploadNewTaskToTrainer(completion: @escaping (Bool) -> ()) {
        wrightAnswer = wrightAnswer.replacingOccurrences(of: ",", with: ".")
        wrightAnswer = wrightAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isAbleToUpload() else {
            completion(false)
            return
        }
        getSelectedTaskInfo { (isReady) in
            if isReady {
                self.trainerReference.document(self.selectedTask ?? "").updateData(["numberOfTasks" : self.tasksNumber + 1,
                                                                                    "themes" : (self.taskThemes + [self.selectedTheme])])
                let newKeyValuePairs = self.getKeyValuesForTask()
                self.trainerReference.document(self.selectedTask ?? "").collection("tasks").document("task\(self.tasksNumber + 1)").setData(newKeyValuePairs)
                self.uploadTaskImage(path: "trainer/\(self.selectedTask ?? "")/task\(self.tasksNumber + 1).png")
                self.uploadTaskDescription(path: "trainer/\(self.selectedTask ?? "")/task\(self.tasksNumber + 1)description.png")
                completion(true)
            }
        }
    }
    
    func getThemesNumber() -> Int {
        return themes.count
    }
    
    func getTasksNumber() -> Int {
        return tasks.count
    }
    
    func getTheme(for index: Int) -> String {
        return index < themes.count ? themes[index] : ""
    }
    
    func getTask(for index: Int) -> String {
        return index < tasks.count ? tasks[index] : ""
    }
    
    func updatePhotoData(with data: Data) {
        imageData = data
    }
    
    func updateTaskDescription(with data: Data) {
        descriptionImageData = data
    }
    
    func updateInverseState(to bool: Bool) {
        inverseState = bool
    }
    
    func updateStringState(to bool: Bool) {
        stringState = bool
    }
    
    func updateWrightAnswer(with text: String) {
        wrightAnswer = text
    }
    
    func updateSelectedTask(with index: Int) {
        selectedTask = tasks[index]
    }
    
    func updateSelectedTheme(with index: Int) {
        selectedTheme = themes[index]
    }
    
    func getSelectedTheme() -> String {
        return selectedTheme
    }
    
    //MARK: Private section
    
    private func getSelectedTaskNumber() -> Int {
        var index = 1
        for task in tasks {
            if task == selectedTask {
                break
            }
            index += 1
        }
        return index
    }
    
    private func isAbleToUpload() -> Bool {
        guard
            imageData != nil, descriptionImageData != nil,
            selectedTheme != "", wrightAnswer != "" else {
                return false
        }
        return true
    }
    
    private func getKeyValuesForTask() -> [String : Any] {
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
        taskData["serialNumber"] = tasksNumber + 1
        return taskData
    }
    
    private func getSelectedTaskInfo(completion: @escaping (Bool) -> ()) {
        trainerReference.document(selectedTask ?? "").getDocument { [weak self] (document, error) in
            guard error == nil else {
                print("Error reading themes in admin: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            self?.tasksNumber = document?.data()?["numberOfTasks"] as? Int ?? 0
            self?.taskThemes = document?.data()?["themes"] as? [String] ?? []
            completion(true)
        }
    }
    
    // Storage
    
    private func uploadTaskImage(path: String) {
        if let data = imageData {
            Storage.storage().reference().child(path).putData(data)
        }
    }
    
    private func uploadTaskDescription(path: String) {
        if let data = descriptionImageData {
            Storage.storage().reference().child(path).putData(data)
        }
    }
    
    //MARK: Unused required methods
    
    func updateTaskNumber(with number: String) {
        
    }
    
    func searchTask(completion: @escaping (TaskModel?) -> ()) {
        
    }
}

extension TrainerAdminAddViewModel: SelectedThemesUpdater {
    func updateTheme(with theme: String) {
        selectedTheme = theme
    }
}
