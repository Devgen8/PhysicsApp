//
//  userStatsCounter.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 08.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserStatsCounter {
    
    let userReference = Firestore.firestore().collection("users")
    let trainerReference = Firestore.firestore().collection("trainer")
    let egeReference = Firestore.firestore().collection("EGE")
    var srEGE = 0
    var nextValue = 0
    static let shared = UserStatsCounter()
    
    private init() {
        
    }
    
    func calculateSrEGE() {
        getUserTasksPercentage { [weak self] (solvedTasks, unsolvedTasks, themes) in
            guard let `self` = self else {
                return
            }
            self.getMarkSystem { (primarySystem, hundredSystem) in
                var srEge = 0.0
                for theme in themes {
                    var accuracy = 0.0
                    if let solved = solvedTasks[theme]?.count,
                        let unsolved = unsolvedTasks[theme]?.count,
                        (unsolved != 0 || solved != 0) {
                        accuracy = Double(solved) / Double(solved + unsolved)
                    }
                    if let taskPoints = primarySystem[theme] {
                        srEge += Double(taskPoints) * accuracy
                    }
                }
                UserStatsCounter.shared.srEGE = hundredSystem["\(Int(srEge))"] ?? 0
                UserStatsCounter.shared.nextValue = hundredSystem["\(Int(srEge + 1))"] ?? 0
            }
        }
    }
    
    func getUserTasksPercentage(completion: @escaping ([String:[String]], [String:[String]], [String]) -> ()) {
        if let userId = Auth.auth().currentUser?.uid {
            userReference.document(userId).getDocument { [weak self] (document, error) in
                guard let `self` = self, error == nil else {
                    print("error reading solvedTasks: \(String(describing: error?.localizedDescription))")
                    return
                }
                let solvedTasks = document?.data()?["solvedTasks"] as? [String:[String]]
                let unsolvedTasks = document?.data()?["unsolvedTasks"] as? [String:[String]]
                self.getThemes { (themes) in
                    if let solvedTasks = solvedTasks, let unsolvedTasks = unsolvedTasks {
                        completion(solvedTasks, unsolvedTasks, themes)
                    }
                }
            }
        }
    }
    
    func getThemes(completion: @escaping ([String]) -> ()) {
        trainerReference.getDocuments { (snapshot, error) in
            guard error == nil, let documents = snapshot?.documents else {
                print("error reading themes: \(String(describing: error?.localizedDescription))")
                return
            }
            var themes = [String]()
            for document in documents {
                if let theme = document.data()["name"] as? String {
                    themes.append(theme)
                }
            }
            completion(themes)
        }
    }
    
    func getMarkSystem(completion: @escaping ([String:Int], [String:Int]) -> ()) {
        egeReference.document("scales").getDocument { (document, error) in
            guard error == nil else {
                print("error reading mark systems: \(String(describing: error?.localizedDescription))")
                return
            }
            if let primarySystem = document?.data()?["primarySystem"] as? [String:Int],
                let hundredSystem = document?.data()?["hundredSystem"] as? [String:Int] {
                completion(primarySystem, hundredSystem)
            }
        }
    }
}
