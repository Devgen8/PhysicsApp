//
//  AdvertsListViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 31.08.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class AdvertsListViewModel {
    
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
            completion(true)
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
    
    func getAdvertName(for index: Int) -> String? {
        return adverts[index].name
    }
    
    func addAdvert(_ newAdvert: Advert) {
        adverts.append(newAdvert)
    }
    
    func editAdvert(oldName: String, newAdvert: Advert) {
        adverts = adverts.filter({ $0.name != oldName })
        adverts.append(newAdvert)
    }
    
    func deleteAdvert(_ oddAdvert: Advert) {
        adverts = adverts.filter({ $0.name != oddAdvert.name })
    }
    
    func deleteAdvert(at index: Int) {
        let deletedAdvert = adverts.remove(at: index)
        advertsReference.document(deletedAdvert.name ?? "").delete()
        Storage.storage().reference().child("adverts/\(deletedAdvert.name ?? "").png").delete { (error) in
            print(error ?? "Error deleting old advert photo")
        }
    }
}
