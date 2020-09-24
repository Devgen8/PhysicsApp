//
//  FormSheetViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 30.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FormSheetViewModel {
    
    //MARK: Fields
    
    private var taskName: String?
    
    //MARK: Interface
    
    func getTaskName() -> String? {
        return taskName
    }
    
    func setTaskName(_ name: String?) {
        taskName = name
    }
    
    func sendMessage(theme: String, text: String) {
        let symbolsString = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
        let symbolsArray = [Character](symbolsString)
        var uid = ""
        for _ in symbolsString {
            uid += String(symbolsArray[Int.random(in: 0..<symbolsString.count)])
            if uid.count == 30 {
                break
            }
        }
        let userEmail = Auth.auth().currentUser?.email ?? "Анонимный пользователь"
        let vkId = userEmail.components(separatedBy: "@").first ?? "Анонимный пользователь"
        Firestore.firestore().collection("messages").document("message" + uid).setData(["theme" : theme,
                                                                                        "text" : text,
                                                                                        "vkId" : vkId,
                                                                                        "date" : Date(),
                                                                                        "messageName" : "message" + uid])
    }
}
