//
//  WelcomeModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 12.06.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation

struct SearchResponse: Decodable {
    var response: [FoundUsers]?
}

struct FoundUsers: Decodable {
    var first_name: String?
}
