//
//  SignInViewModel.swift
//  TrainingApp
//
//  Created by мак on 12/02/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class SignInViewModel {
    
    let firestore = Firestore.firestore()
    
    func authorizeUser(email: String, password: String, completion: @escaping (String?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                completion(nil)
            } else {
                completion(email)
            }
        }
    }
}
