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
import CoreData

class UserStatsCounter {
    
    let userReference = Firestore.firestore().collection("users")
    let trainerReference = Firestore.firestore().collection("trainer")
    var srEGE = 0
    var nextValue = 0
    static let shared = UserStatsCounter()
    
    private init() {}
    
    func calculateSrEGE() {
        getUserTasksPercentage { (solvedTasks, unsolvedTasks, themes) in
            var srEge = 0.0
            var themeIndex = 0
            for theme in themes {
                var accuracy = 0.0
                if let solved = solvedTasks[theme]?.count,
                    let unsolved = unsolvedTasks[theme]?.count,
                    (unsolved != 0 || solved != 0) {
                    accuracy = Double(solved) / Double(solved + unsolved)
                }
                srEge += Double(EGEInfo.primarySystem[themeIndex]) * accuracy
                themeIndex += 1
            }
            UserStatsCounter.shared.srEGE = EGEInfo.hundredSystem[Int(srEge)]
            UserStatsCounter.shared.nextValue = EGEInfo.hundredSystem[Int(srEge + 1)]
        }
    }
    
    func getUserTasksPercentage(completion: @escaping ([String:[String]], [String:[String]], [String]) -> ()) {
        if let userId = Auth.auth().currentUser?.uid {
            userReference.document(userId).getDocument { (document, error) in
                guard error == nil else {
                    print("error reading solvedTasks: \(String(describing: error?.localizedDescription))")
                    return
                }
                let solvedTasks = document?.data()?["solvedTasks"] as? [String:[String]]
                let unsolvedTasks = document?.data()?["unsolvedTasks"] as? [String:[String]]
                if let solvedTasks = solvedTasks, let unsolvedTasks = unsolvedTasks {
                    completion(solvedTasks, unsolvedTasks, EGEInfo.egeSystemTasks)
                }
            }
        } else if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
            do {
                var unsolvedTasks = [String:[String]]()
                var solvedTasks = [String:[String]]()
                if let user = try context.fetch(userFetchRequest).first {
                    let statusTasks = user.solvedTasks as! StatusTasks
                    unsolvedTasks = statusTasks.unsolvedTasks
                    solvedTasks = statusTasks.solvedTasks
                }
                completion(solvedTasks, unsolvedTasks, EGEInfo.egeSystemTasks)
                
            } catch {
                print(error.localizedDescription)
            }
        } else {
            completion([String:[String]](), [String:[String]](), EGEInfo.egeSystemTasks)
        }
    }
}
