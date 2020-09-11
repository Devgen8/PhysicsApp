//
//  AdminAdvertDetailViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 31.08.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore

class AdminAdvertDetailViewModel {
    
    private var advert = Advert()
    private var advertReference = Firestore.firestore().collection("adverts")
    private var oldAdvertName = ""
    
    func uploadAdvert(_ newAdvert: Advert, completion: @escaping (String?) -> ()) {
        if let error = checkNewAdvert(newAdvert) {
            completion(error)
            return
        }
        let oldName = advert.name
        advert.name = newAdvert.name
        advert.describingText = newAdvert.describingText
        advert.urlString = newAdvert.urlString
        if let docName = oldName {
            editAdvertInFirestore(oldDocName: docName) { (error) in
                completion(error)
            }
        } else {
            uploadNewAdvertInFirestore { (error) in
                completion(error)
            }
        }
    }
    
    private func uploadNewAdvertInFirestore(completion: @escaping (String?) -> ()) {
        advertReference.document(advert.name ?? "").setData(["name" : advert.name ?? "",
                                                             "date" : Date(),
                                                             "describingText" : advert.describingText ?? "",
                                                             "urlString" : advert.urlString ?? ""])
        uploadNewPhoto()
        completion(nil)
    }
    
    private func uploadNewPhoto() {
        Storage.storage().reference().child("adverts/\(advert.name ?? "").png").putData(advert.image?.pngData() ?? Data())
    }
    
    private func editAdvertInFirestore(oldDocName: String, completion: @escaping (String?) -> ()) {
        if advert.name != oldDocName {
            advertReference.document(oldDocName).delete()
            Storage.storage().reference().child("adverts/\(oldDocName).png").delete { (error) in
                print(error ?? "Error deleting old advert photo")
            }
        }
        oldAdvertName = oldDocName
        uploadNewAdvertInFirestore { (error) in
            completion(error)
        }
    }
    
    func deleteAdvert(completion: @escaping (String?) -> ()) {
        advertReference.document(advert.name ?? "").delete()
        Storage.storage().reference().child("adverts/\(advert.name ?? "").png").delete { (error) in
            print(error ?? "Error deleting old advert photo")
            completion("Возникли временнные трудности")
        }
        completion(nil)
    }
    
    private func checkNewAdvert(_ newAdvert: Advert) -> String? {
        if newAdvert.name == nil || newAdvert.name == "" {
            return "Название не заполнено"
        }
        if newAdvert.describingText == nil || newAdvert.describingText == "" {
            return "Описание не заполнено"
        }
        if newAdvert.urlString == nil || newAdvert.urlString == "" {
            return "Ссылка не вставлена"
        }
        if advert.image == nil {
            return "Картинка не вставлена"
        }
        return nil
    }
    
    func downloadPhotos(completion: @escaping (Bool) -> ()) {
        let imageRef = Storage.storage().reference().child("adverts/\(advert.name ?? "").png")
        imageRef.getData(maxSize: 4 * 2048 * 2048) { [weak self] data, error in
            guard let `self` = self, error == nil else {
                print("Error downloading images: \(String(describing: error?.localizedDescription))")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                self.advert.image = image
            }
            completion(true)
        }
    }
    
    func updatePhotoData(with newData: Data) {
        advert.image = UIImage(data: newData)
    }
    
    func setAdvert(_ newAdvert: Advert) {
        advert = newAdvert
    }
    
    func getAdvertTitle() -> String? {
        return advert.name
    }
    
    func getAdvertImage() -> UIImage? {
        return advert.image
    }
    
    func getAdvertDescription() -> String? {
        return advert.describingText
    }
    
    func getAdvertUrlString() -> String? {
        return advert.urlString
    }
    
    func getAdvert() -> Advert {
        return advert
    }
    
    func getOldName() -> String {
        return oldAdvertName
    }
}
