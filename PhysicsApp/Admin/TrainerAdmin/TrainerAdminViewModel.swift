//
//  TrainerAdminViewModel.swift
//  TrainingApp
//
//  Created by мак on 24/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class TrainerAdminViewModel {
    let trainerReference = Firestore.firestore().collection("trainer")
    var themes = [String]()
    var imageData: Data?
    var selectedTheme: String?
    
    func getThemes(completion: @escaping (Bool) -> ()) {
        trainerReference.getDocuments { [weak self] (snapshot, error) in
            guard error == nil, let documents = snapshot?.documents else {
                print("Error reading themes in admin: \(String(describing: error?.localizedDescription))")
                completion(false)
                return
            }
            var newThemes = [String]()
            for document in documents {
                if let theme = document.data()["name"] as? String {
                    newThemes.append(theme)
                }
            }
            self?.themes = newThemes
            self?.selectedTheme = newThemes.first
            completion(true)
        }
    }
    
    func getThemesNumber() -> Int {
        return themes.count
    }
    
    func getTheme(for index: Int) -> String {
        return index < themes.count ? themes[index] : ""
    }
    
    func updatePhotoData(with data: Data) {
        imageData = data
    }
    
    func uploadTaskImage() {
        if let data = imageData {
            Storage.storage().reference().child("trainer/\(selectedTheme ?? "")/").putData(data)
        }
    }
}
