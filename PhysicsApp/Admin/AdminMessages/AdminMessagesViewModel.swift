//
//  AdminMessagesViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 30.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation
import FirebaseFirestore

class AdminMessagesViewModel {
    let messagesReference = Firestore.firestore().collection("messages")
    var messages = [AdminMessageModel]()
    
    func getMessages(completion: @escaping (Bool) -> ()) {
        messagesReference.order(by: "date", descending: true).getDocuments { (snapshot, error) in
            guard error == nil, let documents = snapshot?.documents else {
                print("Error reading messages: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            self.messages = []
            for document in documents {
                let newMessage = AdminMessageModel()
                newMessage.date = document.data()["date"] as? Date
                newMessage.email = document.data()["email"] as? String
                newMessage.name = document.data()["messageName"] as? String
                newMessage.text = document.data()["text"] as? String
                newMessage.theme = document.data()["theme"] as? String
                self.messages.append(newMessage)
            }
            completion(true)
        }
    }
    
    func deleteMessage(for index: Int) {
        messagesReference.document(messages[index].name ?? "").delete()
        messages.remove(at: index)
    }
    
    func getNumberOfMessages() -> Int {
        return messages.count
    }
    
    func getUsersEmail(for index: Int) -> String? {
        return messages[index].email
    }
    
    func getMessageText(for index: Int) -> String? {
        return messages[index].text
    }
    
    func getMessageTheme(for index: Int) -> String? {
        return messages[index].theme
    }
}
