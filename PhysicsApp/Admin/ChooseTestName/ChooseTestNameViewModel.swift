//
//  ChooseTestNameViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 04.09.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation
import FirebaseFirestore

class ChooseTestNameViewModel {
    
    var testNames = [String]()
    let testsReference = Firestore.firestore().collection("tests")
    
    func getTestNames(completion: @escaping (Bool) -> ()) {
        testsReference.getDocuments { [weak self] (snapshot, error) in
            guard error == nil, let `self` = self, let documents = snapshot?.documents else {
                print(String(describing: error?.localizedDescription))
                completion(false)
                return
            }
            for document in documents {
                if let testName = document.data()["name"] as? String {
                    self.testNames.append(testName)
                }
            }
            completion(true)
        }
    }
    
    func getTestsNumber() -> Int {
        return testNames.count
    }
    
    func getTestName(for index: Int) -> String {
        return testNames[index]
    }
}
