//
//  TestResultsViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 19.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import CoreData

class TestResultsViewModel {
    var testName = ""
    var timeTillEnd = 0
    var wrightAnswerNumber = 0
    var wrightAnswers = [String:(Double?, Double?, String?)]()
    var userAnswers = [String:String]()
    var answersCorrection = [Bool]()
    var taskImages = [String:UIImage]()
    
    func getTestDurationString() -> String {
        let seconds = 14100 - timeTillEnd
        return "\(seconds / 3600) : \((seconds % 3600) / 60) : \((seconds % 3600) % 60)"
    }
    
    func getWrightAnswersNumberString() -> String {
        return "\(wrightAnswerNumber)"
    }
    
    func getImage(for taskName: String) -> UIImage? {
        return taskImages[taskName]
    }
    
    func getUsersAnswer(for taskName: String) -> String? {
        return userAnswers[taskName]
    }
    
    func getTaskCorrection(for index: Int) -> Bool {
        return answersCorrection[index]
    }
    
    func getWrightAnswer(for taskName: String) -> String {
        if let (wrightAnswer, alternativeAnswer, stringAnswer) = wrightAnswers[taskName] {
            if stringAnswer != nil {
                return stringAnswer ?? "0"
            }
            if alternativeAnswer != nil {
                return "\(wrightAnswer ?? 0) или \(alternativeAnswer ?? 0)"
            }
            if wrightAnswer != nil {
                return "\(wrightAnswer ?? 0)"
            }
        }
        return "0"
    }
    
    func checkUserAnswers(completion: (Bool) -> ()) {
        for index in 1...32 {
            let taskName = "Задание №\(index)"
            var isWright = false
            if let (wrightAnswer, alternativeAnswer, stringAnswer) = wrightAnswers[taskName] {
                let defaultStringAnswer = userAnswers[taskName]?.replacingOccurrences(of: ",", with: ".")
                if let wrightAnswer = wrightAnswer, let userAnswer = Double(defaultStringAnswer ?? "") {
                    if let alternativeAnswer = alternativeAnswer {
                        isWright = (wrightAnswer == userAnswer || alternativeAnswer == userAnswer)
                    } else {
                        isWright = wrightAnswer == userAnswer
                    }
                }
                if let wrightAnswer = stringAnswer, let userAnswer = defaultStringAnswer {
                    isWright = wrightAnswer == userAnswer
                }
                answersCorrection.append(isWright)
                if isWright {
                    wrightAnswerNumber += 1
                }
            }
        }
        completion(true)
    }
    
    func updateTestDataAsDone() {
        updateTestDataInCoreData()
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("users").document(userId).collection("stats").document(testName).setData(["doneTasks":wrightAnswerNumber])
        }
    }
    
    func updateTestDataInCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                (trainer?.tests?.first(where: { ($0 as! Test).name == testName }) as! Test).numberOfWrightAnswers = Int16(wrightAnswerNumber)
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
