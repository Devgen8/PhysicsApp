//
//  AwardsViewModel.swift
//  PhysicsApp
//
//  Created by мак on 26/03/2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class AwardsViewModel {
    
    var awards = [AwardModel]()
    var awardsImages = [String:UIImage]()
    let awardReference = Firestore.firestore().collection("awards")
    let usersReference = Firestore.firestore().collection("users")
    var usersProgress = [String:Int]()
    var usersAwards = [String]()
    
    func getUsersAwardsData() {
        if let userId = Auth.auth().currentUser?.uid {
            usersReference.document(userId).getDocument { [weak self] (document, error) in
                guard let `self` = self, error == nil else {
                    print("Error reading users progress: \(String(describing: error?.localizedDescription))")
                    return
                }
                var progress = [String:Int]()
                progress["trainerSolutions"] = document?.data()?["trainerSolutions"] as? Int ?? 0
                progress["battleWins"] = document?.data()?["battleWins"] as? Int ?? 0
                progress["topMonth"] = document?.data()?["topMonth"] as? Int ?? 0
                self.usersAwards = document?.data()?["awards"] as? [String] ?? []
                self.usersProgress = progress
            }
        }
    }
    
    func getAwards(completion: @escaping (Bool) -> ()) {
        awardReference.getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                print("Error reading awards: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            var awardsNames = [String]()
            for document in documents {
                var award = AwardModel()
                award.name = document.data()["name"] as? String
                award.awardLimit = document.data()["awardLimit"] as? Int
                award.description = document.data()["description"] as? String
                award.sphere = document.data()["sphere"] as? String
                self.awards.append(award)
                awardsNames.append(award.name ?? "")
            }
            self.getAwardsImages(awardsNames: awardsNames) { (isReady) in
                if isReady {
                    completion(true)
                }
            }
        }
    }
    
    func getAwardsImages(awardsNames: [String], completion: @escaping (Bool) -> ()) {
        for award in awardsNames {
            let imageRef = Storage.storage().reference().child("awards/\(award).png")
            imageRef.getData(maxSize: 1 * 2048 * 2048) { [weak self] data, error in
                guard let `self` = self, error == nil else {
                    print("Error downloading award images: \(String(describing: error?.localizedDescription))")
                    completion(false)
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    self.awardsImages[award] = image
                }
                if self.awardsImages.count == self.awards.count {
                    completion(true)
                }
            }
        }
    }
    
    func checkAwardAccess(_ award: String) -> Bool {
        return usersAwards.contains(award)
    }
    
    func transportData(to viewModel: AwardDetailViewModel, from index: Int) {
        viewModel.award = awards[index]
        viewModel.awardImage = awardsImages[awards[index].name ?? ""]
        viewModel.usersProgress = usersProgress[awards[index].sphere ?? ""]
    }
}
