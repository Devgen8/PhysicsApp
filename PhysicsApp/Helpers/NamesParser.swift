//
//  NamesParser.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 03.07.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation

class NamesParser {
    
    static func getTaskLocation(taskName: String) -> (String, String) {
        var themeNameSet = [Character]()
        var taskNumberSet = [Character]()
        var isDotFound = false
        for letter in taskName {
            if letter == "." {
                isDotFound = true
                continue
            }
            if isDotFound {
                taskNumberSet.append(letter)
            } else {
                themeNameSet.append(letter)
            }
        }
        let themeName = String(themeNameSet)
        let taskNumber = String(taskNumberSet)
        return (themeName, taskNumber)
    }
    
    static func isTestCustom(_ name: String) -> Bool {
        if name.count < 3 {
            return false
        } else {
            var charsArray = [Character]()
            var index = 0
            for letter in name {
                charsArray.append(letter)
                index += 1
                if index == 3 {
                    break
                }
            }
            if String(charsArray) == "Мой" {
                return true
            } else {
                return false
            }
        }
    }
}
