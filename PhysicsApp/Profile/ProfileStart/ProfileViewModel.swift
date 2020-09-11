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
import CoreData

class ProfileViewModel {
    
    //MARK: Fields
    
    private let usersReference = Firestore.firestore().collection("users")
    private var user = UserProfile()
    private var userPhoto: UIImage?
    
    //MARK: Interface
    
    func eraseUserDefaults() {
        UserDefaults.standard.set(nil, forKey: "isTestHistoryRead")
        UserDefaults.standard.set(nil, forKey: "taskTypeUpdateDate")
        UserDefaults.standard.set(nil, forKey: "themeTypeUpdateDate")
        UserDefaults.standard.set(nil, forKey: "testsUpdateDate")
        UserDefaults.standard.set(nil, forKey: "notUpdatedTests")
        UserDefaults.standard.set(nil, forKey: "finishedTests")
        UserDefaults.standard.set(nil, forKey: "notUpdatedTasks")
        UserDefaults.standard.set(nil, forKey: "notUpdatedThemes")
        UserDefaults.standard.set(nil, forKey: "notUpdatedUnsolvedTasks")
        UserDefaults.standard.set(nil, forKey: "notUpdatedUnsolvedThemes")
        UserDefaults.standard.set(nil, forKey: "isUserInfoDownloaded")
        UserDefaults.standard.set(nil, forKey: "isUserPhotoDownloaded")
        UserDefaults.standard.set(nil, forKey: "isUserInformedAboutAuth")
        UserDefaults.standard.set(nil, forKey: "isAdmin")
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
                let result = try context.fetch(fetchRequest)
                for user in result {
                    context.delete(user)
                }
                
                let trainerFetchRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let trainerResult = try context.fetch(trainerFetchRequest)
                for trainer in trainerResult {
                    context.delete(trainer)
                }
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getUsersData(completion: @escaping (UserProfile?) -> ()) {
        if UserDefaults.standard.value(forKey: "isUserInfoDownloaded") == nil {
            getUsersDataFromFirestore { (user) in
                completion(user)
            }
        } else {
            getUsersDataFromCoreData { (user) in
                completion(user)
            }
        }
    }
    
    func logOut() {
        do {
           try Auth.auth().signOut()
        } catch {
            print("Error signing out")
        }
    }
    
    // Managing photos
    
    func getUsersPhoto(completion: @escaping (UIImage?) -> ()) {
        if UserDefaults.standard.value(forKey: "isUserPhotoDownloaded") == nil {
            getUsersPhotoFromStorage { (photo) in
                completion(photo)
            }
        } else {
            getUserPhotoFromCoreData { (photo) in
                completion(photo)
            }
        }
    }
    
    func updatePhotoData(with data: Data) {
        userPhoto = UIImage(data: data)
        savePhotoInCoreData()
        if let userId = Auth.auth().currentUser?.uid {
            Storage.storage().reference().child("users/\(userId)").putData(data)
        }
    }
    
    //MARK: Private section
    
    // Firestore and Storage
    
    private func getUsersDataFromFirestore(completion: @escaping (UserProfile?) -> ()) {
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
                self?.updateKeys()
                self?.saveUsersDataInCoreData()
                completion(userProfile)
            }
        } else {
            completion(nil)
        }
    }
    
    private func getUsersPhotoFromStorage(completion: @escaping (UIImage?) -> ()) {
        if let userId = Auth.auth().currentUser?.uid {
            let imageRef = Storage.storage().reference().child("users/\(userId)")
            imageRef.getData(maxSize: 4 * 2048 * 2048) { data, error in
                guard error == nil else {
                    print("Error downloading user image: \(String(describing: error?.localizedDescription))")
                    completion(nil)
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    self.userPhoto = image
                    self.updateKeys()
                    self.savePhotoInCoreData()
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
    
    // Core Data
    
    private func getUsersDataFromCoreData(completion: @escaping (UserProfile?) -> ()) {
        if Auth.auth().currentUser?.uid != nil, let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
                let result = try context.fetch(fetchRequest)
                let newUser = result.first ?? User(context: context)
                var userData = UserProfile()
                userData.name = newUser.name
                userData.email = Auth.auth().currentUser?.email
                userData.password = newUser.password
                user = userData
                
                completion(userData)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func saveUsersDataInCoreData() {
        if Auth.auth().currentUser?.uid != nil, let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
                let result = try context.fetch(fetchRequest)
                let newUser = result.first ?? User(context: context)
                newUser.name = user.name
                newUser.email = user.email
                newUser.password = user.password
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func savePhotoInCoreData() {
        if Auth.auth().currentUser?.uid != nil, let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
                let result = try context.fetch(fetchRequest)
                let newUser = result.first ?? User(context: context)
                newUser.photo = userPhoto?.pngData()
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func getUserPhotoFromCoreData(completion: @escaping (UIImage?) -> ()) {
        if Auth.auth().currentUser?.uid != nil, let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
                let result = try context.fetch(fetchRequest)
                let newUser = result.first ?? User(context: context)
                let userPhoto = UIImage(data: newUser.photo ?? Data())
                
                completion(userPhoto)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateKeys() {
        UserDefaults.standard.set(true, forKey: "isUserInfoDownloaded")
        if userPhoto != nil {
            UserDefaults.standard.set(true, forKey: "isUserPhotoDownloaded")
        }
    }
}
