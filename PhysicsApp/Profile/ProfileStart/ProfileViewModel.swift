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
import VK_ios_sdk

class ProfileViewModel {
    
    //MARK: Fields
    
    private let usersReference = Firestore.firestore().collection("users")
    private var user = UserProfile()
    private var userPhoto: UIImage?
    private var isNewUser = true
    
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
                let user = result.first ?? User(context: context)
                user.solvedTasks = StatusTasks(solvedTasks: [:], unsolvedTasks: [:], firstTryTasks: [])
                
                let trainerFetchRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let trainerResult = try context.fetch(trainerFetchRequest)
                for trainer in trainerResult {
                    context.delete(trainer)
                }
                
                let testsHistoryFetchRequest: NSFetchRequest<TestsHistory> = TestsHistory.fetchRequest()
                let testsHistoryResults = try context.fetch(testsHistoryFetchRequest)
                let userTestsHistory = testsHistoryResults.first ?? TestsHistory(context: context)
                userTestsHistory.tests = NSOrderedSet()
                
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
    
    func saveUsersName(_ newName: String, completion: @escaping (Bool) -> ()) {
        if let userId = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("usersDevices").document(userId).getDocument { (document, error) in
                guard error == nil else {
                    print(error?.localizedDescription as Any)
                    completion(true)
                    return
                }
                if document?.data()?["lastDevice"] == nil, newName != "" {
                    Firestore.firestore().collection("users").document(userId).setData(["name":newName])
                    self.setUsersDataAfterRegistrationInFirestore { (isReady) in
                        completion(true)
                    }
                } else {
                    UserDefaults.standard.set(nil, forKey: "taskTypeUpdateDate")
                    completion(true)
                }
            }
        }
    }
    
    // authorizationVK
    
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
                        UserDefaults.standard.set(nil, forKey: "taskTypeUpdateDate")
                        completion(nil, isAdmin)
                        return
                    }
                    return
                }
                self.setUsersDataAfterRegistrationInFirestore { (isReady) in
                    completion(nil, isAdmin)
                }
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
    
    private func setUsersDataAfterRegistrationInFirestore(completion: @escaping (Bool) -> ()) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<User> = User.fetchRequest()
                let result = try context.fetch(fechRequest)
                if let user = result.first {
                    let solvedTasks = (user.solvedTasks as! StatusTasks).solvedTasks
                    let firstTryTasks = (user.solvedTasks as! StatusTasks).firstTryTasks
                    let unsolvedTasks = (user.solvedTasks as! StatusTasks).unsolvedTasks
                    if let userId = Auth.auth().currentUser?.uid {
                        usersReference.document(userId).updateData(["firstTryTasks":firstTryTasks,
                                                                    "solvedTasks":solvedTasks,
                                                                    "unsolvedTasks":unsolvedTasks])
                    }
                }
                
                guard let userId = Auth.auth().currentUser?.uid else {
                    completion(false)
                    return
                }
                
                let testHistoryFechRequest: NSFetchRequest<TestsHistory> = TestsHistory.fetchRequest()
                let testsResult = try context.fetch(testHistoryFechRequest)
                let testsHistory = testsResult.first ?? TestsHistory(context: context)
                var testsCopy = NSOrderedSet()
                if testsHistory.tests != nil {
                    testsCopy = testsHistory.tests?.mutableCopy() as! NSOrderedSet
                }
                for coreTest in testsCopy {
                    let testName = (coreTest as! TestsResults).name ?? ""
                    let wrightAnswerNumber = Int((coreTest as! TestsResults).wrightAnswerNumber)
                    let semiWrightAnswerNumber = Int((coreTest as! TestsResults).semiWrightAnswerNumber)
                    let points = Int((coreTest as! TestsResults).points)
                    let timeTillEnd = Int((coreTest as! TestsResults).timeTillEnd)
                    let resultsObject = (coreTest as! TestsResults).testResultObject as! TestsResultsObject
                    let userAnswers = resultsObject.userAnswers
                    let answersCorrection = resultsObject.answersCorrection
                    let wrightAnswers = resultsObject.wrightAnswers
                    let primaryPoints = resultsObject.primaryPoints
                    let tasksNames = resultsObject.tasksNames
                    usersReference.document(userId).collection("testsHistory").document(testName).setData(["answersCorrection":answersCorrection,
                                                "name":testName,
                                                "points":points,
                                                "primaryPoints":primaryPoints,
                                                "semiWrightAnswerNumber":semiWrightAnswerNumber,
                                                "tasksNames":tasksNames,
                                                "timeTillEnd":timeTillEnd,
                                                "userAnswers":userAnswers,
                                                "wrightAnswerNumber":wrightAnswerNumber,
                                                "wrightAnswers":wrightAnswers
                    ])
                }
                
                Firestore.firestore().collection("usersDevices").document(userId).setData(["lastDevice":UIDevice.modelName])
                
                completion(true)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    // authorizationVK
    
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
                completion(nil)
            }
        }
    }
    
    // Core Data
    
    private func getUsersDataFromCoreData(completion: @escaping (UserProfile?) -> ()) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
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
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
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
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
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
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
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
