//
//  BattleViewModel.swift
//  TrainingApp
//
//  Created by мак on 22/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class BattleViewModel {
    
    let battleReference = Firestore.firestore().collection("battle")
    let userReference = Firestore.firestore().collection("users")
    let names = ["Екатерина", "Петр", "Анна", "Анастасия", "Евгений", "Алла", "Василиса", "Игорь", "Олег", "Никита", "Виктория", "Павел", "Алексей", "Стефан"]
    var theme: String?
    var questions = [BattleModel]()
    var opponentsName: String?
    var numberOfPlays: Int?
    
    init() {
        getNumberOfPlays()
    }
    
    func getTheme(completion: @escaping (String?, UIImage?) -> ()) {
        battleReference.getDocuments { [weak self] (snapshot, error) in
            guard let `self` = self, error == nil else {
                print("Error reading themes: \(String(describing: error?.localizedDescription))")
                completion(nil, nil)
                return
            }
            if let documents = snapshot?.documents {
                var themes = [String]()
                for document in documents {
                    themes.append(document.data()["name"] as? String ?? "")
                }
                self.theme = themes[Int.random(in: 0..<themes.count)]
                self.getQuestions()
                self.downloadPhoto { [weak self] (image) in
                    completion(self?.theme, image)
                }
            } else {
                completion(nil, nil)
            }
        }
    }
    
    func getQuestions() {
        if let battleTheme = theme {
            Firestore.firestore().collection("battle").document(battleTheme).collection("tasks").getDocuments { [weak self] (snapshot, error) in
                guard let `self` = self, error == nil, let documents = snapshot?.documents else {
                    print("Error reading questions: \(String(describing: error?.localizedDescription))")
                    return
                }
                var allQuestions = [BattleModel]()
                for document in documents {
                    var question = BattleModel()
                    question.serialNumber = document.data()["serialNumber"] as? Int
                    question.possibility = document.data()["possibility"] as? Int
                    question.answers = document.data()["answers"] as? [Float]
                    question.wrightAnswer = document.data()["wrightAnswer"] as? Float
                    question.name = "task\(question.serialNumber ?? 0)"
                    allQuestions.append(question)
                }
                var randomQuestions = [BattleModel]()
                for _ in stride(from: 0, to: min(5, allQuestions.count), by: 1) {
                    randomQuestions.append(allQuestions.remove(at: Int.random(in: 0..<allQuestions.count)))
                }
                self.questions = randomQuestions
                self.getQuestionsPhotos { [weak self] (questionImages) in
                    guard let `self` = self else { return }
                    if let questionImages = questionImages {
                        for index in stride(from: 0, to: self.questions.count, by: 1) {
                            self.questions[index].image = questionImages[index]
                        }
                    }
                }
            }
        }
    }
    
    func getQuestionsPhotos(completion: @escaping ([Int:UIImage]?) -> ()) {
        var index = 0
        var questionsImages = [Int:UIImage]()
        for question in questions {
            let imageRef = Storage.storage().reference().child("battle/\(theme ?? "")/\(question.name ?? "").png")
            imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                guard error == nil else {
                    print("Error downloading images: \(String(describing: error?.localizedDescription))")
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    questionsImages[index] = image
                }
                if questionsImages.count == self.questions.count {
                    completion(questionsImages)
                }
                index += 1
            }
        }
    }
    
    func getNumberOfPlays() {
        if let userId = Auth.auth().currentUser?.uid {
            userReference.document(userId).getDocument { [weak self] (document, error) in
                guard let `self` = self, error == nil else {
                    print("Error reading number of plays: \(String(describing: error?.localizedDescription))")
                    return
                }
                var gamesNumber = document?.data()?["numberOfPlays"] as? Int
                let lastGame = document?.data()?["lastBattleTime"] as? String
                let todaysDate = self.getTodayDateString()
                if todaysDate != lastGame {
                    gamesNumber = 3
                }
                self.numberOfPlays = gamesNumber
            }
        }
    }
    
    func checkPermissionToPlay() -> Bool {
        return numberOfPlays != 0 ? true : false
    }
    
    func getName() -> String {
        opponentsName = names[Int.random(in: 0..<names.count)]
        return opponentsName ?? ""
    }
    
    func downloadPhoto(completion: @escaping (UIImage?) -> ()) {
        let imageRef = Storage.storage().reference().child("battle/\(theme ?? "").jpg")
        imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            guard error == nil else {
                print("Error downloading images: \(String(describing: error?.localizedDescription))")
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
    
    func transportDataTo(viewModel: AnswerChooserViewModel) {
        viewModel.questions = questions
        viewModel.opponentsName = opponentsName
        decreaseNumberOfPlays()
        viewModel.numberOfPlays = numberOfPlays
    }
    
    func decreaseNumberOfPlays() {
        if numberOfPlays != nil {
            numberOfPlays! -= 1
        } else {
            numberOfPlays = 2
        }
        writeNumberOfPlays()
    }
    
    func getTodayDateString() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
    func writeNumberOfPlays() {
        if let userId = Auth.auth().currentUser?.uid {
            let todaysDate = getTodayDateString()
            userReference.document(userId).updateData(["numberOfPlays" : numberOfPlays ?? 0, "lastBattleTime" : todaysDate])
        }
    }
}
