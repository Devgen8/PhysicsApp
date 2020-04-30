//
//  UserStatsViewModel.swift
//  PhysicsApp
//
//  Created by мак on 03/04/2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserStatsViewModel {
    var mistakes = [String:Int]()
    var themes = [String]()
    var numberOfTasksIn = [String:Int]()
    var solvedTasks = [String:[String]]()
    var unsolvedTasks = [String:[String]]()
    let userReference = Firestore.firestore().collection("users")
    let trainerReference = Firestore.firestore().collection("trainer")
    
    func getTasksNames(completion: @escaping (Bool) -> ()) {
        trainerReference.order(by: "themeNumber", descending: false).getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                print("Error reading task names: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            var downloadedThemes = [String]()
            var numberOfTasks = [String:Int]()
            for document in documents {
                let name = document.data()["name"] as? String
                let number = document.data()["numberOfTasks"] as? Int
                downloadedThemes.append(name ?? "")
                if let name = name, let number = number {
                    numberOfTasks[name] = number
                }
            }
            self.themes = downloadedThemes
            self.numberOfTasksIn = numberOfTasks
            self.getUserMistakes { (isReady) in
                if isReady {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func getUserMistakes(completion: @escaping (Bool) -> ()) {
        if let userId = Auth.auth().currentUser?.uid {
            userReference.document(userId).getDocument { [weak self] (document, error) in
                guard let `self` = self, error == nil else {
                    print("Error reading user mistakes: \(String(describing: error?.localizedDescription))")
                    completion(false)
                    return
                }
                let downloadedMistakes = document?.data()?["mistakes"] as? [String:Int] ?? [:]
                let newSolvedTasks = document?.data()?["solvedTasks"] as? [String:[String]] ?? [:]
                let newUnsolvedTasks = document?.data()?["unsolvedTasks"] as? [String:[String]] ?? [:]
                self.mistakes = downloadedMistakes
                self.solvedTasks = newSolvedTasks
                self.unsolvedTasks = newUnsolvedTasks
                completion(true)
            }
        }
    }
    
    func getThemesNumber() -> Int {
        return themes.count
    }
    
    func getDoneTasksNumber(for index: Int) -> Int {
        return (solvedTasks[themes[index]]?.count ?? 0) + (unsolvedTasks[themes[index]]?.count ?? 0)
    }
    
    func getSolvedNumbersString(for index: Int) -> String {
        let doneTasks = getDoneTasksNumber(for: index)
        return "\(doneTasks)/\(numberOfTasksIn[themes[index]] ?? 0)"
    }
    
    func getAccuracyString(for index: Int) -> String {
        let mistake = mistakes[themes[index]]
        let solvedNumber = solvedTasks[themes[index]]?.count
        var percentage : Float = 0.0
        if let mistake = mistake, let solvedNumber = solvedNumber {
            let sum = mistake + solvedNumber
            let part = Float(solvedNumber) / Float(sum)
            percentage = part * 100.0
        }
        return "\(Int(percentage))%"
    }
    
    func getOverallPercentage(for index: Int) -> Float {
        return Float(getDoneTasksNumber(for: index)) / Float(numberOfTasksIn[themes[index]] ?? 1)
    }
    
    func getColorForProgressBar(for index: Int) -> UIColor {
        let mistake = mistakes[themes[index]]
        let solvedNumber = solvedTasks[themes[index]]?.count
        var percentage : Float = 0.0
        if let mistake = mistake, let solvedNumber = solvedNumber {
            let sum = mistake + solvedNumber
            percentage = Float(solvedNumber) / Float(sum)
        }
        let red = CGFloat(1.0 - percentage)
        let green = CGFloat(percentage)
        return UIColor(displayP3Red: red,
                       green: green,
                       blue: 0,
                       alpha: 1)
    }
}
