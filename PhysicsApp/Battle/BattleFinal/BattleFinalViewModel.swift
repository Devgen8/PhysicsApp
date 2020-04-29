//
//  BattleFinalViewModel.swift
//  TrainingApp
//
//  Created by мак on 22/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class BattleFinalViewModel {
    
    var userAnswers = [Bool]()
    var opponentsAnswers = [Bool]()
    var wonBattle: Bool?
    var opponentsName: String?
    var numberOfPlays: Int?
    var usersReference = Firestore.firestore().collection("users")
    var awards = [1 : "Новичкам везет", 30 : "Победитель"]
    var userWins = 0
    var award: AwardModel?
    var awardReference = Firestore.firestore().collection("awards")
    var awardsImages = [String : UIImage]()
    var isShown = false
    var battleVC: BattleFinalViewController?
    
    func getScore() -> String {
        var usersScore = 0
        var opponentsScore = 0
        for index in stride(from: 0, to: userAnswers.count, by: 1) {
            usersScore += userAnswers[index] ? 1 : 0
            opponentsScore += opponentsAnswers[index] ? 1 : 0
        }
        if usersScore > opponentsScore {
            wonBattle = true
        } else if usersScore < opponentsScore {
            wonBattle = false
        }
        return "\(usersScore):\(opponentsScore)"
    }
    
    func getResultPhrase() -> String {
        var change = 0
        if wonBattle == nil {
            change = 5
            updateUsersRating(with: change)
            return "Ничья +5 баллов"
        } else {
            if wonBattle == true {
                change = 10
                updateUsersRating(with: change)
                return "Победа +10 баллов"
            } else {
                change = -5
                updateUsersRating(with: change)
                return "Поражение -5 баллов"
            }
        }
    }
    
    func updateUsersRating(with change: Int) {
        if let userId = Auth.auth().currentUser?.uid {
            usersReference.document(userId).getDocument { (document, error) in
                guard error == nil else {
                    print("Error reading user rating: \(String(describing: error?.localizedDescription))")
                    return
                }
                let rating = document?.data()?["rating"] as? Int
                var battleWins = document?.data()?["battleWins"] as? Int ?? 0
                if change > 0 {
                    battleWins += 1
                    self.userWins = battleWins
                    if battleWins == 1 || battleWins == 30 {
                        //self.getAwardData()
                        let p = AwardCompletedViewController()
                        p.modalPresentationStyle = .fullScreen
                        self.battleVC?.present(p, animated: true)
                    }
                }
                var newRating = 0
                if let rating = rating {
                    newRating = rating + change
                }
                self.usersReference.document(userId).updateData(["rating" : newRating, "battleWins" : battleWins])
            }
        }
    }
    
    func getAwardData() {
        awardReference.whereField("name", isEqualTo: awards[userWins]).getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                print("Error reading awards: \(String(describing: error?.localizedDescription))")
                return
            }
            for document in documents {
                var newAward = AwardModel()
                newAward.name = document.data()["name"] as? String
                newAward.awardLimit = document.data()["awardLimit"] as? Int
                newAward.description = document.data()["description"] as? String
                newAward.sphere = document.data()["sphere"] as? String
                self.award = newAward
            }
            self.getAwardsImages(awardsName: self.award?.name ?? "", completion: { _ in })
        }
    }
    
    func getAwardsImages(awardsName: String, completion: @escaping (Bool) -> ()) {
        let imageRef = Storage.storage().reference().child("awards/\(awardsName).png")
        imageRef.getData(maxSize: 1 * 2048 * 2048) { [weak self] data, error in
            guard let `self` = self, error == nil else {
                print("Error downloading award images: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            if let data = data, let image = UIImage(data: data) {
                self.awardsImages[awardsName] = image
                completion(true)
            }
        }
    }
    
    func getOpponentsName() -> String? {
        return opponentsName
    }
    
    func checkAwardAccess() -> Bool {
        if isShown == false && ( userWins == 1 || userWins == 30) {
            return true
        } else {
            return false
        }
    }
    
    func transportData(to viewModel: AwardCompletedViewModel) {
        viewModel.award = award ?? AwardModel()
        viewModel.awardImage = awardsImages[award?.name ?? ""]
    }
}
