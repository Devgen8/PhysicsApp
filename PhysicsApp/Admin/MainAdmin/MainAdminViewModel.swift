//
//  MainAdminViewModel.swift
//  TrainingApp
//
//  Created by мак on 24/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation
import FirebaseAuth

class MainAdminViewModel {
    func logOut() {
        do {
           try Auth.auth().signOut()
        } catch {
            print("Error signing out")
        }
    }
}
