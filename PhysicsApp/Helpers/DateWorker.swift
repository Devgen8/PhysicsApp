//
//  DateWorker.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 14.06.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation

class DateWorker {
    
    // Checking the time of update
    static func checkForUpdate(from lastUpdateDate: Date) -> Bool {
        var needUpdate = false
        if let weeksDifference = Calendar.current.dateComponents([.weekOfMonth], from: Date(), to: lastUpdateDate).weekOfMonth {
            if weeksDifference >= 1 {
                needUpdate = true
            } else {
                let formater = DateFormatter()
                let daysDifference = Calendar.current.dateComponents([.day], from: Date(), to: lastUpdateDate).day ?? 0
                var weekdays = [String]()
                for index in 0..<abs(daysDifference) {
                    let day = 60 * 60 * 24
                    let weekday = formater.weekdaySymbols[Calendar.current.component(.weekday, from: Date() - TimeInterval(index * day)) - 1]
                    weekdays.append(weekday)
                }
                if weekdays.contains("Monday") {
                    needUpdate = true
                }
            }
        }
        return needUpdate
    }
}
