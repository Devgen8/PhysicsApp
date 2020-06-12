//
//  AdminMessageModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 30.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation

class AdminMessageModel {
    var name: String?
    var theme: String?
    var text: String?
    var vkId: String?
    var date: Date?
}

enum MessageSortTypes {
    case profile
    case tasks
    case all
}
