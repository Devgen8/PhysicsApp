//
//  AwardDetailViewModel.swift
//  PhysicsApp
//
//  Created by мак on 26/03/2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class AwardDetailViewModel {
    var award: AwardModel?
    var awardImage: UIImage?
    var usersProgress: Int?
    
    func getName() -> String? {
        return award?.name
    }
    
    func getImage() -> UIImage? {
        return awardImage
    }
    
    func getDescription() -> String? {
        return award?.description
    }
    
    func getAwardLimit() -> Int {
        return award?.awardLimit ?? 10
    }
}
