//
//  AdminStatsViewModel.swift
//  PhysicsApp
//
//  Created by мак on 04/04/2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation
import FirebaseFirestore

class AdminStatsViewModel {
    let trainerReference = Firestore.firestore().collection("trainer")
    var themes = [String]()
    var percentageStruct = [String :[String:Int]]()
    var tasksInTheme = [String:[String]]()
    
    func getThemes(completion: @escaping (Bool) -> ()) {
        trainerReference.order(by: "themeNumber", descending: false).getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                completion(false)
                return
            }
            var allThemes = [String]()
            for document in documents {
                if let themeName = document.data()[Theme.name.rawValue] as? String {
                    allThemes.append(themeName)
                }
            }
            self.themes = allThemes
            self.getThemesTasks { (isReady) in
                completion(isReady)
            }
        }
    }
    
    func getThemesTasks(completion: @escaping (Bool) -> ()) {
        var i = 0
        for themeName in themes {
            trainerReference.document(themeName).collection("tasks").getDocuments { [weak self] (snapshot, error) in
                guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                    completion(false)
                    return
                }
                self.tasksInTheme[themeName] = [String]()
                self.percentageStruct[themeName] = [String:Int]()
                for document in documents {
                    if let serialNumber = document.data()["serialNumber"] as? Int {
                        let name = "Задача №\(serialNumber)"
                        self.tasksInTheme[themeName]?.append(name)
                        let succeded: Int = document.data()["succeded"] as? Int ?? 0
                        let failed: Int = document.data()["failed"] as? Int ?? 0
                        if succeded != 0 || failed != 0 {
                            var part = 0.0
                            part = Double(succeded) / Double(succeded + failed)
                            let percentage = Int(part * 100)
                            self.percentageStruct[themeName]?[name] = percentage
                        }
                    }
                }
                i += 1
                if i == self.themes.count {
                    completion(true)
                }
            }
        }
    }
    
    func getThemesNumber() -> Int {
        return themes.count
    }
    
    func getThemePercentage(for index: Int) -> Int {
        var overallPercentage = 0
        if let tasksWithPercentage = percentageStruct[themes[index]] {
            for percentage in tasksWithPercentage.values {
                overallPercentage += percentage
            }
            if tasksWithPercentage.count == 0 {
                return 0
            } else {
                overallPercentage /= tasksWithPercentage.count
            }
        } else {
            return 0
        }
        return 100 - overallPercentage
    }
}
