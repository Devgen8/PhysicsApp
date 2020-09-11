//
//  TestsHistoryResultsViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 14.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CoreData
import FirebaseStorage

class TestsHistoryResultsViewModel: GeneralTestResultsViewModel {
    
    //MARK: Fields
    
    private var tasksImages = [String:UIImage]()
    private var tasksDescriptions = [String:UIImage]()
    private var realWrightAnswers = [String]()
    private var tasks = [String]()
    private var wrightAnswerNumber = 0
    private var answersCorrection = [Int]()
    private var points = 0
    private var semiWrightAnswerNumber = 0
    private var primaryPoints = [Int]()
    
    var timeTillEnd = 0
    var wrightAnswers = [String : (String?, Bool?)]()
    var userAnswers = [String : String]()
    var taskImages = [String : UIImage]()
    var testName = ""
    var cPartPoints = [Int]()
    var openedCells = [Int]()
    var testAnswersUpdater: TestAnswersUpdater?
    
    //MARK: Interface
    
    func checkUserAnswers(completion: @escaping (Bool) -> ()) {
        downloadPhotos { (isReady) in
            completion(isReady)
        }
    }
    
    func isCellOpened(index: Int) -> Bool {
        return openedCells.contains(index)
    }
    
    func closeCell(for index: Int) {
        openedCells = openedCells.filter( { $0 != index } )
    }
    
    func openCell(for index: Int) {
        openedCells.append(index)
    }
    
    func setAnswersCorrection(_ newAnswers: [Int]) {
        answersCorrection = newAnswers
    }
    
    func setPoints(_ newPoints: Int) {
        points = newPoints
    }
    
    func setSemiWrightAnswers(_ newAnswers: Int) {
        semiWrightAnswerNumber = newAnswers
    }
    
    func setWrightAnswers(_ newAnswers: Int) {
        wrightAnswerNumber = newAnswers
    }
    
    func setTasks(_ newTasks: [String]) {
        tasks = newTasks
    }
    
    func setRealWrightAnswers(_ newAnswers: [String]) {
        realWrightAnswers = newAnswers
    }
    
    func setPrimaryPoints(_ newPoints: [Int]) {
        primaryPoints = newPoints
    }
    
    func getTestDurationString() -> String {
        let allSeconds = 14100 - timeTillEnd
        var hours = "\(allSeconds / 3600)"
        if hours.count == 1 {
            hours = "0" + hours
        }
        var minutes = "\((allSeconds % 3600) / 60)"
        if minutes.count == 1 {
            minutes = "0" + minutes
        }
        var seconds = "\((allSeconds % 3600) % 60)"
        if seconds.count == 1 {
            seconds = "0" + seconds
        }
        return "\(hours) : \(minutes) : \(seconds)"
    }
    
    func getWrightAnswersNumberString() -> String {
        return "\(wrightAnswerNumber)"
    }
    
    func getImage(for taskName: String) -> UIImage? {
        let taskNumber = getTaskPosition(taskName: taskName)
        return tasksImages[tasks[taskNumber - 1]]
    }
    
    func getDescription(for taskName: String) -> UIImage? {
        let taskNumber = getTaskPosition(taskName: taskName)
        return tasksDescriptions[tasks[taskNumber - 1]]
    }
    
    func getUsersAnswer(for taskName: String) -> String? {
        let taskNumber = getTaskPosition(taskName: taskName)
        return userAnswers[tasks[taskNumber - 1]]
    }
    
    func getTaskCorrection(for index: Int) -> Int {
        return answersCorrection[index]
    }
    
    func getUsersFinalPoints() -> Int {
        return points
    }
    
    func getUserPoints(for taskNumber: Int) -> String {
        return "\(primaryPoints[taskNumber])"
    }
    
    func getColorPercentage() -> (Float, Float) {
        let greenPercentage = Float(wrightAnswerNumber) / Float(32)
        let yellowPercentage = Float(semiWrightAnswerNumber) / Float(32) + greenPercentage
        return (greenPercentage, yellowPercentage)
    }
    
    func getWrightAnswer(for index: Int) -> String {
        return realWrightAnswers[index - 1]
    }
    
    func getCompletion() -> Float {
        return Float(tasksImages.count + tasksDescriptions.count) / Float(EGEInfo.egeSystemTasks.count)
    }
    
    //MARK: Private section
    
    // Firestore and Storage
    
    private func downloadPhotos(completion: @escaping (Bool) -> ()) {
        var count = 0
        for taskName in tasks {
            if NamesParser.isTestCustom(testName) {
                if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                    do {
                        let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                        let result = try context.fetch(fechRequest)
                        let trainer = result.first
                        let (themeName, _) = NamesParser.getTaskLocation(taskName: taskName)
                        let taskData = ((trainer?.egeTasks?.first(where: { ($0 as! EgeTask).name == themeName}) as! EgeTask).tasks?.first(where: {(($0 as! TaskData).name == taskName)}) as? TaskData)
                        if let taskImageData = taskData?.image {
                            tasksImages[taskName] = UIImage(data: taskImageData)
                            tasksDescriptions[taskName] = UIImage(data: taskData?.taskDescription ?? Data())
                            count += 1
                            if count == self.realWrightAnswers.count {
                                completion(true)
                            }
                        } else {
                            downloadImage(taskName) { (isReady) in
                                count += 1
                                if isReady && count == self.realWrightAnswers.count {
                                    completion(true)
                                }
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } else {
                if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                    let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                    
                    do {
                        let result = try context.fetch(fechRequest)
                        let trainer = result.first
                        if let currentTest = trainer?.tests?.first(where: { ($0 as! Test).name == testName }) as? Test {
                            if let testObject = currentTest.testObject as? TestObject {
                                let taskData = testObject.testTasks.first(where: { $0.name == taskName })
                                if let taskImageData = taskData?.image {
                                    tasksImages[taskName] = taskImageData
                                    tasksDescriptions[taskName] = taskData?.taskDescription ?? UIImage()
                                    count += 1
                                    if count == self.realWrightAnswers.count {
                                        completion(true)
                                    }
                                } else {
                                    downloadImage(taskName) { (isReady) in
                                        count += 1
                                        if isReady && count == self.realWrightAnswers.count {
                                            completion(true)
                                        }
                                    }
                                }
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func downloadImage(_ taskName: String, completion: @escaping (Bool) -> ()) {
        var imageRef = StorageReference()
        if NamesParser.isTestCustom(testName) {
            let (themeName, taskNumber) = NamesParser.getTaskLocation(taskName: taskName)
            imageRef = Storage.storage().reference().child("trainer/\(themeName)/task\(taskNumber).png")
        } else {
            let taskNumber = getTaskPosition(taskName: taskName)
            imageRef = Storage.storage().reference().child("tests/\(testName)/task\(taskNumber).png")
        }
        imageRef.getData(maxSize: 4 * 2048 * 2048) { [weak self] data, error in
            guard let `self` = self, error == nil else {
                print("Error downloading images: \(String(describing: error?.localizedDescription))")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                self.tasksImages[taskName] = image
                self.downloadDesciptions(taskName) { (isReady) in
                    completion(isReady)
                }
            }
        }
    }
    
    private func downloadDesciptions(_ taskName: String, completion: @escaping (Bool) -> ()) {
        var imageRef = StorageReference()
        if NamesParser.isTestCustom(testName) {
            let (themeName, taskNumber) = NamesParser.getTaskLocation(taskName: taskName)
            imageRef = Storage.storage().reference().child("trainer/\(themeName)/task\(taskNumber)description.png")
        } else {
            let taskNumber = getTaskPosition(taskName: taskName)
            imageRef = Storage.storage().reference().child("tests/\(testName)/task\(taskNumber)description.png")
        }
        imageRef.getData(maxSize: 4 * 2048 * 2048) { [weak self] data, error in
            guard let `self` = self, error == nil else {
                print("Error downloading descriptions: \(String(describing: error?.localizedDescription))")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                self.tasksDescriptions[taskName] = image
                completion(true)
            }
        }
    }
    
    private func getTaskPosition(taskName: String) -> Int {
        let (themeName, _) = NamesParser.getTaskLocation(taskName: taskName)
        if let range = themeName.range(of: "№") {
            let numberString = String(themeName[range.upperBound...])
            return Int(numberString) ?? 0
        }
        return 0
    }
    
    //MARK: Unused required method
    
    func updateTestDataAsDone() {
        
    }
    
}
