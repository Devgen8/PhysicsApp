//
//  TasksDetailViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 30.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class TasksDetailViewModel {
    
    let trainerReference = Firestore.firestore().collection("trainer")
    var sortTypeName = ""
    var tasks = [AdminStatsModel]()
    var descending = true
    var cellLabels = [String]()
    var cellPercentage = [Int]()
    
    func getTasksData(for index: Int, completion: @escaping (String, Data) -> ()) {
        let (taskName, taskNumber) = getTaskLocation(taskName: cellLabels[index])
        trainerReference.document(taskName).collection("tasks").document("task\(taskNumber)").getDocument { (document, error) in
            guard error == nil else {
                print("Error reading task info: \(String(describing: error?.localizedDescription))")
                completion("", Data())
                return
            }
            if let wrightAnswer = document?.data()?["wrightAnswer"] as? Double {
                self.downloadTaskPhoto(for: self.cellLabels[index]) { (imageData) in
                    completion("\(wrightAnswer)", imageData)
                }
            } else if let stringAnswer = document?.data()?["stringAnswer"] as? String {
                self.downloadTaskPhoto(for: self.cellLabels[index]) { (imageData) in
                    completion(stringAnswer, imageData)
                }
            }
        }
    }
    
    func downloadTaskPhoto(for taskName: String, completion: @escaping (Data) -> ()) {
        let (taskName, taskNumber) = getTaskLocation(taskName: taskName)
        let imageRef = Storage.storage().reference().child("trainer/\(taskName)/task\(taskNumber).png")
        imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            guard error == nil else {
                print("Error downloading images: \(String(describing: error?.localizedDescription))")
                return
            }
            if let data = data {
                completion(data)
            }
        }
    }
    
    func getTaskLocation(taskName: String) -> (String, String) {
        var themeNameSet = [Character]()
        var taskNumberSet = [Character]()
        var isDotFound = false
        for letter in taskName {
            if letter == "." {
                isDotFound = true
                continue
            }
            if isDotFound {
                taskNumberSet.append(letter)
            } else {
                themeNameSet.append(letter)
            }
        }
        let themeName = String(themeNameSet)
        let taskNumber = String(taskNumberSet)
        return (themeName, taskNumber)
    }
    
    func prepareDataForTableReload(completion: (Bool) -> ()) {
        cellLabels = []
        cellPercentage = []
        fullfillAll()
        completion(true)
    }
    
    func getThemesNumber() -> Int {
        return tasks.count
    }
    
    func getTaskName(for index: Int) -> String {
        return cellLabels[index]
    }
    
    func getTaskPercentage(for index: Int) -> Int {
        return cellPercentage[index]
    }
    
    func fullfillAll() {
        var tasksStats = [String:Int]()
        for task in tasks {
            if let taskName = task.name,
                let failures = task.failed,
                let successes = task.succeded {
                let percentage = Int(Double(failures)/Double(failures + successes) * 100.0)
                tasksStats[taskName] = percentage
            }
        }
        let taskStatsArray = descending ? tasksStats.sorted(by: { $0.value > $1.value }) : tasksStats.sorted(by: { $0.value < $1.value })
        for pair in taskStatsArray {
            cellLabels.append(pair.key)
            cellPercentage.append(pair.value)
        }
    }
    
    func changeDescending() {
        descending = !descending
    }
    
    func getSortTypeName() -> String {
        return sortTypeName
    }
}
