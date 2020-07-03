//
//  ThemeParser.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 20.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class ThemeParser {
    private static let themesImages = ["Электродинамика" : #imageLiteral(resourceName: "technology"),
                        "Механика" : #imageLiteral(resourceName: "cogwheel"),
                        "Мкт" : #imageLiteral(resourceName: "food-and-restaurant"),
                        "Квантовая физика" : #imageLiteral(resourceName: "science")]
    
    // convert theme string to theme array
    static func parseTaskThemes(_ themes: String) -> [String] {
        var themesArray = [String]()
        var currentTheme = [Character]()
        for letter in themes {
            if ("А"..."Я").contains(letter), currentTheme.count != 0 {
                themesArray.append(String(currentTheme))
                currentTheme = []
            }
            currentTheme.append(letter)
        }
        themesArray.append(String(currentTheme))
        return themesArray
    }
    
    // Get images array for array of theme strings
    static func getImageArray(forTaskThemes themes: [String]) -> [UIImage] {
        var imagesForTask = [UIImage]()
        for theme in themes {
            if let image = themesImages[theme] {
                imagesForTask.append(image)
            }
        }
        return imagesForTask
    }
}
