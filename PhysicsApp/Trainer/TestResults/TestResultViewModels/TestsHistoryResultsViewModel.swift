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
    
    var timeTillEnd = 0
    var wrightAnswers = [String : (Double?, Double?, String?)]()
    var userAnswers = [String : String]()
    var taskImages = [String : UIImage]()
    var testName = ""
    var cPartPoints = [Int]()
    var openedCells = [Int]()
    var testAnswersUpdater: TestAnswersUpdater?
    var tasksImages = [String:UIImage]()
    var tasksDescriptions = [String:UIImage]()
    var realWrightAnswers = [String]()
    var tasks = [String]()
    var wrightAnswerNumber = 0
    var answersCorrection = [Int]()
    var points = 0
    var semiWrightAnswerNumber = 0
    var primaryPoints = [Int]()
    
    func checkUserAnswers(completion: @escaping (Bool) -> ()) {
        downloadPhotos { (isReady) in
            completion(isReady)
        }
    }
    
    func isTestCustom() -> Bool {
        if testName.count < 7 {
            return false
        } else {
            var charsArray = [Character]()
            var index = 0
            for letter in testName {
                charsArray.append(letter)
                index += 1
                if index == 7 {
                    break
                }
            }
            if String(charsArray) == "Пробник" {
                return true
            } else {
                return false
            }
        }
    }
    
    func downloadPhotos(completion: @escaping (Bool) -> ()) {
        var count = 0
        for taskName in tasks {
            var imageRef = StorageReference()
            if isTestCustom() {
                let (themeName, taskNumber) = getTaskLocation(taskName: taskName)
                imageRef = Storage.storage().reference().child("trainer/\(themeName)/task\(taskNumber).png")
            } else {
                let taskNumber = getTaskPosition(taskName: taskName)
                imageRef = Storage.storage().reference().child("tests/\(testName)/task\(taskNumber).png")
            }
            imageRef.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in
                guard let `self` = self, error == nil else {
                    print("Error downloading images: \(String(describing: error?.localizedDescription))")
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    self.tasksImages[taskName] = image
                }
                count += 1
                if count == self.realWrightAnswers.count {
                    self.downloadDesciptions { (isReady) in
                        completion(isReady)
                    }
                }
            }
        }
    }
    
    func downloadDesciptions(completion: @escaping (Bool) -> ()) {
        var count = 0
        for taskName in tasks {
            var imageRef = StorageReference()
            if isTestCustom() {
                let (themeName, taskNumber) = getTaskLocation(taskName: taskName)
                imageRef = Storage.storage().reference().child("trainer/\(themeName)/task\(taskNumber)description.png")
            } else {
                let taskNumber = getTaskPosition(taskName: taskName)
                imageRef = Storage.storage().reference().child("tests/\(testName)/task\(taskNumber)description.png")
            }
            imageRef.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in
                guard let `self` = self, error == nil else {
                    print("Error downloading descriptions: \(String(describing: error?.localizedDescription))")
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    self.tasksDescriptions[taskName] = image
                }
                count += 1
                if count == self.realWrightAnswers.count {
                    completion(true)
                }
            }
        }
    }
    
    func getTaskPosition(taskName: String) -> Int {
        let (themeName, _) = getTaskLocation(taskName: taskName)
        if let range = themeName.range(of: "№") {
            let numberString = String(themeName[range.upperBound...])
            return Int(numberString) ?? 0
        }
        return 0
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
    
    func isCellOpened(index: Int) -> Bool {
        return openedCells.contains(index)
    }
    
    func closeCell(for index: Int) {
        openedCells = openedCells.filter( { $0 != index } )
    }
    
    func openCell(for index: Int) {
        openedCells.append(index)
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
    
    
    // do not need these funcs for that view model
    
    func updateTestDataAsDone() {
        
    }
    
}
