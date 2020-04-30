//
//  AdminStatsModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 30.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import Foundation

struct AdminStatsModel {
    var name: String?
    var theme: String?
    var failed: Int?
    var succeded: Int?
}

public class TasksLevelsObject: NSObject, NSCoding {
    
    public var tasksLevels = [String:[String]]()
    
    public func encode(with coder: NSCoder) {
        coder.encode(tasksLevels, forKey: "tasksLevels")
    }
    
    public override init() {
        super.init()
    }
    
    init(tasksLevels: [String:[String]]) {
        self.tasksLevels = tasksLevels
    }
    
    public required convenience init?(coder: NSCoder) {
        let decodedTasks = coder.decodeObject(forKey: "tasksLevels") as! [String:[String]]
        self.init(tasksLevels: decodedTasks)
    }
}

enum AdminStatsSortType: String {
    case task = "По задачам"
    case theme = "По темам"
    case difficulty = "По уровню"
    case all = "По всем задачам"
}
