//
//  ChooseSubjectViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 31.08.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import CoreData

class ChooseSubjectViewModel {
    
    // MARK: Fields
    
    private var adverts = [Advert]()
    private let advertsReference = Firestore.firestore().collection("adverts")
    private let usersReference = Firestore.firestore().collection("users")
    private let devicesReference = Firestore.firestore().collection("usersDevices")
    
    // MARK: Interface
    
    //Firestore
    
    func getAdverts(completion: @escaping (Bool) -> ()) {
        advertsReference.order(by: "date", descending: true).getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                print(error?.localizedDescription ?? "Error with adverts reading")
                completion(false)
                return
            }
            for document in documents {
                var newAdvert = Advert()
                newAdvert.name = document.data()["name"] as? String
                newAdvert.describingText = document.data()["describingText"] as? String
                newAdvert.urlString = document.data()["urlString"] as? String
                self.adverts.append(newAdvert)
            }
            self.downloadPhotos { (isReady) in
                if isReady {
                    completion(true)
                }
            }
        }
    }
    
    func getAdvertsNumber() -> Int {
        return adverts.count
    }
    
    func getAdvertImage(for index: Int) -> UIImage {
        return adverts[index].image ?? UIImage()
    }
    
    func getAdvert(for index: Int) -> Advert {
        return adverts[index]
    }
    
    // MARK: Private section
    
    // Firestore
    
    private func getLastUsersDevice(completion: @escaping (Bool) -> ()) {
        if let userId = Auth.auth().currentUser?.uid {
            devicesReference.document(userId).getDocument { (snapshot, error) in
                guard error == nil else {
                    print("Error reading unsolved tasks: \(String(describing: error?.localizedDescription))")
                    completion(false)
                    return
                }
                if let lastDevice = snapshot?.data()?["lastDevice"] as? String {
                    if lastDevice != UIDevice.modelName {
                        self.devicesReference.document(userId).updateData(["lastDevice" : UIDevice.modelName])
                        self.updateUsersInfo { (isReady) in
                            completion(isReady)
                        }
                    } else {
                        completion(true)
                    }
                } else {
                    self.devicesReference.document(userId).setData(["lastDevice" : UIDevice.modelName])
                    completion(true)
                }
            }
        } else {
            completion(true)
        }
    }
    
    func updateUsersInfo(completion: @escaping (Bool) -> ()) {
        if let userId = Auth.auth().currentUser?.uid {
            usersReference.document(userId).getDocument { (document, error) in
                guard error == nil, let document = document else {
                    print("Error reading unsolved tasks: \(String(describing: error?.localizedDescription))")
                    completion(false)
                    return
                }
                let mistakeTasks = document.data()?["unsolvedTasks"] as? [String : [String]] ?? [String:[String]]()
                let wrightTasks = document.data()?["solvedTasks"] as? [String : [String]] ?? [String:[String]]()
                let firstTryTasks = document.data()?["firstTryTasks"] as? [String] ?? [String]()
                if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                    do {
                        //filling trainer
                        let fechRequest: NSFetchRequest<User> = User.fetchRequest()
                        let result = try context.fetch(fechRequest)
                        let user = result.first ?? User(context: context)
                        let statusTasks = StatusTasks(solvedTasks: wrightTasks,
                                                      unsolvedTasks: mistakeTasks,
                                                      firstTryTasks: firstTryTasks)
                        user.solvedTasks = statusTasks
                        try context.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                completion(true)
            }
        } else {
            completion(true)
        }
    }
    
    // Storage
    
    private func downloadPhotos(completion: @escaping (Bool) -> ()) {
        var count = 0
        for index in stride(from: 0, to: adverts.count, by: 1) {
            let imageRef = Storage.storage().reference().child("adverts/\(adverts[index].name ?? "").png")
            imageRef.getData(maxSize: 4 * 2048 * 2048) { [weak self] data, error in
                guard let `self` = self, error == nil else {
                    print("Error downloading images: \(String(describing: error?.localizedDescription))")
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    self.adverts[index].image = image
                }
                count += 1
                if count == self.adverts.count {
                    self.getLastUsersDevice { (isReady) in
                        completion(true)
                    }
                }
            }
        }
    }
}
