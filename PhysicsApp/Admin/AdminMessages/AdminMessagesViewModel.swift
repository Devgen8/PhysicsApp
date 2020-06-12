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
    var sortType = MessageSortTypes.profile
    var sortedMessages = [AdminMessageModel]()
    
    func getMessages(completion: @escaping (Bool) -> ()) {
        messagesReference.order(by: "date", descending: true).getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                print("Error reading messages: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            self.messages = []
            for document in documents {
                let newMessage = AdminMessageModel()
                newMessage.date = document.data()["date"] as? Date
                newMessage.vkId = document.data()["vkId"] as? String
                newMessage.name = document.data()["messageName"] as? String
                newMessage.text = document.data()["text"] as? String
                newMessage.theme = document.data()["theme"] as? String
                self.messages.append(newMessage)
            }
            self.changeSortType(for: self.sortType) { (isReady) in
                completion(isReady)
            }
        }
    }
    
    func changeSortType(for type: MessageSortTypes, completion: @escaping (Bool) -> ()) {
        let messagesCopy = messages
        switch type {
        case .profile: sortedMessages = messagesCopy.filter({ $0.theme?.components(separatedBy: " ").first != "Ошибка" })
        case .tasks: sortedMessages = messagesCopy.filter({ $0.theme?.components(separatedBy: " ").first == "Ошибка" })
        default: sortedMessages = messagesCopy
        }
        completion(true)
    }
    
    func deleteMessage(for index: Int) {
        let deletedMessage = sortedMessages.remove(at: index)
        messagesReference.document(deletedMessage.name ?? "").delete()
        messages = messages.filter({ $0.name != deletedMessage.name })
    }
    
    func getNumberOfMessages() -> Int {
        return sortedMessages.count
    }
    
    func getUsersEmail(for index: Int) -> String? {
        return "vk.com/id\(sortedMessages[index].vkId ?? "")"
    }
    
    func getMessageText(for index: Int) -> String? {
        return sortedMessages[index].text
    }
    
    func getMessageTheme(for index: Int) -> String? {
        return sortedMessages[index].theme
    }
}
