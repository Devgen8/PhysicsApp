//
//  ProfileDataChangeViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 14.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import CoreData

class ProfileDataChangeViewModel {
    
    let usersReference = Firestore.firestore().collection("users")
    var oldEmail = ""
    var oldName = ""
    var oldPassword = ""
    
    
    func prepareData(completion: @escaping (String, String, String) -> ()) {
        completion(oldName, oldEmail, oldPassword)
    }
    
    func changeUserData(email: String, name: String, password: String, confirmPassword: String, completion: @escaping (String?) -> ()) {
        guard
            name.trimmingCharacters(in: .whitespacesAndNewlines) != "",
            email.trimmingCharacters(in: .whitespacesAndNewlines) != "",
            password.trimmingCharacters(in: .whitespacesAndNewlines) != "",
            confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
                completion("Заполнены не все поля")
                return
        }
        if let emailChecking = checkEmail(email) {
            completion(emailChecking)
            return
        }
        if let passwordChecker = checkPassword(password: password, confirmPassword: confirmPassword) {
            completion(passwordChecker)
            return
        }
        var newValues = [String:String]()
        if oldEmail != email.trimmingCharacters(in: .whitespacesAndNewlines) {
            updateEmail(with: email.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        if oldPassword != password.trimmingCharacters(in: .whitespacesAndNewlines) {
            newValues["password"] = password.trimmingCharacters(in: .whitespacesAndNewlines)
            updatePassword(with: password.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        if oldName != name.trimmingCharacters(in: .whitespacesAndNewlines) {
            newValues["name"] = name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        updateInFirestore(with: newValues)
        completion(nil)
    }
    
    func updateEmail(with email: String) {
        Auth.auth().currentUser?.updateEmail(to: email)
    }
    
    func updatePassword(with password: String) {
        Auth.auth().currentUser?.updatePassword(to: password)
    }
    
    func updateInFirestore(with dict: [String:String]) {
        updateCoreData(with: dict)
        if let userId = Auth.auth().currentUser?.uid, dict.count > 0 {
            usersReference.document(userId).updateData(dict)
        }
    }
    
    func updateCoreData(with dict: [String:String]) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
                let result = try context.fetch(fetchRequest)
                let newUser = result.first ?? User(context: context)
                if let name = dict["name"] {
                    newUser.name = name
                }
                if let password = dict["password"] {
                    newUser.password = password
                }
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func checkEmail(_ email: String) -> String? {
        if !(email.contains("@") && email.contains(".")),
            email.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Пожалуйста, заполните почту в соответствии со следующим форматом: example@gmail.com"
        }
        return nil
    }
    
    func checkPassword(password: String, confirmPassword: String) -> String? {
        if password.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            password.count < 8 {
            return "Пароль должен быть не менее 8 символов"
        }
        if password != confirmPassword {
            return "Пароли не совпадают, попробуйте еще раз"
        }
        return nil
    }
}
