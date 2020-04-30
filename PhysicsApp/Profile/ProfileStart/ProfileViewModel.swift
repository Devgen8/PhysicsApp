//
//  ProfileViewModel.swift
//  TrainingApp
//
//  Created by мак on 23/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ProfileViewModel {
    
    let usersReference = Firestore.firestore().collection("users")
    var user = UserProfile()
    
    func getUsersData(completion: @escaping (UserProfile?) -> ()) {
        if let userId = Auth.auth().currentUser?.uid {
            usersReference.document(userId).getDocument { [weak self] (document, error) in
                guard error == nil else {
                    print("Error reading users data: \(String(describing: error?.localizedDescription))")
                    completion(nil)
                    return
                }
                let name = document?.data()?["name"] as? String
                let email = Auth.auth().currentUser?.email
                let password = document?.data()?["password"] as? String
                let userProfile = UserProfile(name: name, email: email, password: password)
                self?.user = userProfile
                completion(userProfile)
            }
        }
    }
    
    func getUsersPhoto(completion: @escaping (UIImage?) -> ()) {
        if let userId = Auth.auth().currentUser?.uid {
            let imageRef = Storage.storage().reference().child("users/\(userId)")
            imageRef.getData(maxSize: 1 * 2048 * 2048) { data, error in
                guard error == nil else {
                    print("Error downloading user image: \(String(describing: error?.localizedDescription))")
                    completion(nil)
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func getUsersRating(completion: @escaping (Int?) -> ()) {
        usersReference.order(by: "rating", descending: true).getDocuments { [weak self] (snapshot, error) in
            guard error == nil, let documents = snapshot?.documents, let userId = Auth.auth().currentUser?.uid else {
                print("Error reading user rating: \(String(describing: error?.localizedDescription))")
                completion(nil)
                return
            }
            var rating = 1
            for document in documents {
                let uid = document.data()["uid"] as? String
                if uid == userId {
                    break
                }
                rating += 1
            }
            completion(rating)
            self?.user.rating = rating
        }
    }
    
    func logOut() {
        do {
           try Auth.auth().signOut()
        } catch {
            print("Error signing out")
        }
    }
    
    func updatePhotoData(with data: Data) {
        if let userId = Auth.auth().currentUser?.uid {
            Storage.storage().reference().child("users/\(userId)").putData(data)
        }
    }
    
    func getHiddenPassword() -> String {
        var password = ""
        for _ in user.password ?? "" {
            password += "•"
        }
        return password
    }
}
