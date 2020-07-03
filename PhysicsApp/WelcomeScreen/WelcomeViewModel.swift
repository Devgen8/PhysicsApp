//
//  WelcomeViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 07.06.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation
import VK_ios_sdk
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class WelcomeViewModel {
    
    //MARK: Fields
    
    private var isNewUser = true
    
    //MARK: Interface
    
    func authUser(with result: VKAuthorizationResult, completion: @escaping (String?, Bool) -> ()) {
        checkUserAdminPermission(userId: result.token.userId) { [weak self] (isAdmin) in
            guard let `self` = self else { return }
            UserDefaults.standard.set(isAdmin, forKey: "isAdmin")
            let email = result.token.userId + "@gmail.com"
            self.createUser(email: email) { (error) in
                guard error == nil else {
                    let password = self.getUsersPassword(from: email)
                    self.authorizeUser(email: email, password: password) { (email) in
                        guard email != nil else {
                            completion("Не удалось авторизоваться", isAdmin)
                            return
                        }
                        self.isNewUser = false
                        completion(nil, isAdmin)
                        return
                    }
                    return
                }
                completion(nil, isAdmin)
            }
        }
    }
    
    func checkUserAdminPermission(userId: String, completion: @escaping (Bool) -> ()) {
        Firestore.firestore().collection("admin").getDocuments { (snapshot, error) in
            guard error == nil, let documents = snapshot?.documents else {
                print(error?.localizedDescription as Any)
                completion(false)
                return
            }
            for document in documents {
                if let adminId = document.data()["id"] as? String, adminId == userId {
                    completion(true)
                    return
                }
            }
            completion(false)
        }
    }
    
    func saveUsersDataInFirestore(_ result: VKAuthorizationResult) {
        if let userId = Auth.auth().currentUser?.uid, isNewUser {
            getUsersName(id: result.token.userId, token: result.token.accessToken) { (name) in
                let userName = name == nil ? result.token.localUser.first_name : name
                Firestore.firestore().collection("users").document(userId).setData(["name":userName ?? ""])
            }
            if let photoUrl = URL(string: result.token.localUser.photo_200) {
                URLSession.shared.dataTask(with: photoUrl) { (data, response, error) in
                    guard
                        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                        let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                        let data = data, error == nil else { return }
                    Storage.storage().reference().child("users/\(userId)").putData(data)
                }.resume()
            }
        }
    }
    
    //MARK: Private section
    
    // Firestore
    
    private func getUsersName(id: String, token: String, completion: @escaping (String?) -> ()) {
        NetworkService.fetchData(urlString: "https://api.vk.com/method/users.get?user_ids=\(id)&fields=bdate&access_token=\(token)&v=5.107") { (user) in
            completion(user?.response?.first?.first_name)
        }
    }
    
    private func getUsersPassword(from email: String) -> String {
        var letters = [Character]()
        for letter in email {
            if letter != "@" {
                letters.append(letter)
            } else {
                break
            }
        }
        while letters.count < 10 {
            letters.append("1")
        }
        return String(letters)
    }
    
    private func authorizeUser(email: String, password: String, completion: @escaping (String?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                completion(nil)
            } else {
                completion(email)
            }
        }
    }
    
    private func createUser(email: String?,
                    completion: @escaping (String?) -> ()) {
        guard let email = email, email.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            completion("Не удалось авторизоваться")
            return
        }
        let password = getUsersPassword(from: email)
        Auth.auth().createUser(withEmail: email, password: password) { (_, error) in
            if error != nil {
                completion("Проверьте свое интернет соединение")
            } else {
                self.updateTextFile()
                completion(nil)
            }
        }
    }
    
    private func updateTextFile() {
        if Auth.auth().currentUser?.uid != nil {
            let docRef = Storage.storage().reference().child("vkIds.txt")
            docRef.getData(maxSize: 4 * 2048 * 2048) { data, error in
                guard error == nil else {
                    if let errorDescription = error?.localizedDescription,
                        errorDescription == "Object vkIds.txt does not exist." {
                        self.uploadEditedFile(with: "")
                    }
                    return
                }
                if let data = data {
                    self.uploadEditedFile(with: String(data: data, encoding: .utf8) ?? "")
                }
            }
        }
    }
    
    private func uploadEditedFile(with previousInfo: String) {
        let userId = VKSdk.accessToken()?.userId ?? ""
        if previousInfo == "" {
            Storage.storage().reference().child("vkIds.txt").putData(userId.data(using: .utf8) ?? Data())
        } else {
            let newInfo = previousInfo + "\n\(userId)"
            Storage.storage().reference().child("vkIds.txt").putData(newInfo.data(using: .utf8) ?? Data())
        }
    }
}
