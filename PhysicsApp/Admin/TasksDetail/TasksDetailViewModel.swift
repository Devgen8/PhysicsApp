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
    
    //MARK: Fields
    
    private let trainerReference = Firestore.firestore().collection("trainer")
    private var sortTypeName = ""
    private var tasks = [AdminStatsModel]()
    private var descending = true
    private var cellLabels = [String]()
    private var cellPercentage = [Int]()
    
    //MARK: Interface
    
    func getTasksData(for index: Int, completion: @escaping (String, Data) -> ()) {
        let (taskName, taskNumber) = NamesParser.getTaskLocation(taskName: cellLabels[index])
        trainerReference.document(taskName).collection("tasks").document("task\(taskNumber)").getDocument { (document, error) in
            guard error == nil else {
                print("Error reading task info: \(String(describing: error?.localizedDescription))")
                completion("", Data())
                return
            }
            if let wrightAnswer = document?.data()?["wrightAnswer"] as? String {
                self.downloadTaskPhoto(for: self.cellLabels[index]) { (imageData) in
                    completion("\(wrightAnswer)", imageData)
                }
            }
        }
    }
    
    func setSortType(_ newSortType: String) {
        sortTypeName = newSortType
    }
    
    func setTasks(_ newTasks: [AdminStatsModel]) {
        tasks = newTasks
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
    
    func changeDescending() {
        descending = !descending
    }
    
    func getSortTypeName() -> String {
        return sortTypeName
    }
    
    //MARK: Private section
    
    private func downloadTaskPhoto(for taskName: String, completion: @escaping (Data) -> ()) {
        let (taskName, taskNumber) = NamesParser.getTaskLocation(taskName: taskName)
        let imageRef = Storage.storage().reference().child("trainer/\(taskName)/task\(taskNumber).png")
        imageRef.getData(maxSize: 4 * 2048 * 2048) { (data, error) in
            guard error == nil else {
                print("Error downloading images: \(String(describing: error?.localizedDescription))")
                return
            }
            if let data = data {
                completion(data)
            }
        }
    }
    
    private func fullfillAll() {
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
}
