//
//  AdvertDetailViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 31.08.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class AdvertDetailViewModel {
    
    private var advert = Advert()
    
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
}
