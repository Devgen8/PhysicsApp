//
//  AdminSettingViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 13.06.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation
import FirebaseFirestore

class AdminSettingViewModel {
    
    //MARK: Fields
    
    private var adminIds = [String]()
    
    //MARK: Interface
    
    func getAdminsList(completion: @escaping (Bool) -> ()) {
        Firestore.firestore().collection("admin").getDocuments { (snapshot, error) in
            guard error == nil, let documents = snapshot?.documents else {
                print(error?.localizedDescription as Any)
                completion(false)
                return
            }
            var ids = [String]()
            for document in documents {
                if let adminId = document.data()["id"] as? String {
                    ids.append(adminId)
                }
            }
            self.adminIds = ids
            completion(true)
        }
    }
    
    func getIdsNumbers() -> Int {
        return adminIds.count
    }
    
    func getId(for index: Int) -> String {
        return "vk.com/id\(adminIds[index])"
    }
    
    func deleteId(for index: Int) {
        let deletedId = adminIds.remove(at: index)
        Firestore.firestore().collection("admin").document(deletedId).delete()
    }
    
    func addId(_ id: String) {
        adminIds.append(id)
        Firestore.firestore().collection("admin").document(id).setData(["id":id])
    }
}
