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
    func sendMessage(theme: String, text: String) {
        if let userEmail = Auth.auth().currentUser?.email {
            let symbolsString = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
            let symbolsArray = [Character](symbolsString)
            var uid = ""
            for _ in symbolsString {
                uid += String(symbolsArray[Int.random(in: 0..<symbolsString.count)])
                if uid.count == 30 {
                    break
                }
            }
            Firestore.firestore().collection("messages").document("message" + uid).setData(["theme" : theme,
                                                                                            "text" : text,
                                                                                            "email" : userEmail,
                                                                                            "date" : Date(),
                                                                                            "messageName" : "message" + uid])
        }
    }
}
