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

class ChooseSubjectViewModel {
    
    // MARK: Fields
    
    private var adverts = [Advert]()
    private let advertsReference = Firestore.firestore().collection("adverts")
    
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
                    completion(true)
                }
            }
        }
    }
}
