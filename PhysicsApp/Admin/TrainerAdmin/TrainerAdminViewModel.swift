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

class TrainerAdminViewModel {
    
    let trainerReference = Firestore.firestore().collection("trainer")
    let testReference = Firestore.firestore().collection("tests")
    var tasks = [String]()
    var themes = [String]()
    var imageData: Data?
    var descriptionImageData: Data?
    var selectedTask: String?
    var selectedTheme = ""
    var inverseState = false
    var stringState = false
    var tasksNumber = 0
    var taskThemes = [String]()
    var wrightAnswer = ""
    
    func getTrainerData(completion: @escaping (Bool) -> ()) {
        tasks = EGEInfo.egeSystemTasks
        selectedTask = tasks[0]
        themes = EGEInfo.egeSystemThemes
        completion(true)
    }
    
    func uploadNewTaskToTest(_ testName: String, completion: @escaping (Bool) -> ()) {
        wrightAnswer = wrightAnswer.replacingOccurrences(of: ",", with: ".")
        wrightAnswer = wrightAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        testReference.document(testName).setData(["name":testName])
        let taskNumber = getSelectedTaskNumber()
        var newKeyValuePairs = self.getKeyValuesForTask()
        newKeyValuePairs["serialNumber"] = taskNumber
        testReference.document(testName).collection("tasks").document("task\(taskNumber)").setData(newKeyValuePairs)
        uploadTaskImage(path: "tests/\(testName)/task\(taskNumber).png")
        uploadTaskDescription(path: "tests/\(testName)/task\(taskNumber)description.png")
        completion(true)
    }
    
    func getSelectedTaskNumber() -> Int {
        var index = 1
        for task in tasks {
            if task == selectedTask {
                break
            }
            index += 1
        }
        return index
    }
    
    func uploadNewTaskToTrainer(completion: @escaping (Bool) -> ()) {
        wrightAnswer = wrightAnswer.replacingOccurrences(of: ",", with: ".")
        wrightAnswer = wrightAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
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
        taskData["serialNumber"] = tasksNumber + 1
        return taskData
    }
    
    func getSelectedTaskInfo(completion: @escaping (Bool) -> ()) {
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
    
    func uploadTaskImage(path: String) {
        if let data = imageData {
            Storage.storage().reference().child(path).putData(data)
        }
    }
    
    func uploadTaskDescription(path: String) {
        if let data = descriptionImageData {
            Storage.storage().reference().child(path).putData(data)
        }
    }
}

extension TrainerAdminViewModel: SelectedThemesUpdater {
    func updateTheme(with theme: String) {
        selectedTheme = theme
    }
}
