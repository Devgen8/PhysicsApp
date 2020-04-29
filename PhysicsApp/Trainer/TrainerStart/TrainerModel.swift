//
//  TrainerModel.swift
//  TrainingApp
//
//  Created by мак on 18/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation

enum Theme: String {
    case name = "name"
    case tasksCount = "tasksCount"
}

public class StatusTasks: NSObject, NSCoding {
    
    public var solvedTasks = [String:[String]]()
    public var unsolvedTasks = [String:[String]]()
    
    public func encode(with coder: NSCoder) {
        coder.encode(solvedTasks, forKey: "solvedTasks")
        coder.encode(unsolvedTasks, forKey: "unsolvedTasks")
    }
    
    public override init() {
        super.init()
    }
    
    init(solvedTasks: [String:[String]], unsolvedTasks: [String:[String]]) {
        self.solvedTasks = solvedTasks
        self.unsolvedTasks = unsolvedTasks
    }
    
    public required convenience init?(coder: NSCoder) {
        let solved = coder.decodeObject(forKey: "solvedTasks") as! [String:[String]]
        let unsolved = coder.decodeObject(forKey: "unsolvedTasks") as! [String:[String]]
        self.init(solvedTasks: solved, unsolvedTasks: unsolved)
    }
}

public class ThemeTasksSafe: NSObject, NSCoding {
    
    public var tasks = [String:[String]]()
    
    public func encode(with coder: NSCoder) {
        coder.encode(tasks, forKey: "tasks")
    }
    
    public override init() {
        super.init()
    }
    
    init(tasks: [String:[String]]) {
        self.tasks = tasks
    }
    
    public required convenience init?(coder: NSCoder) {
        let decodedTasks = coder.decodeObject(forKey: "tasks") as! [String:[String]]
        self.init(tasks: decodedTasks)
    }
}

public class TestObject: NSObject, NSCoding {
    
    var testTasks = [TaskModel]()
    var usersAnswers = [String : String]()
    
    public func encode(with coder: NSCoder) {
        coder.encode(testTasks, forKey: "testTasks")
        coder.encode(usersAnswers, forKey: "usersAnswers")
    }
    
    public override init() {
        super.init()
    }
    
    init(testTasks: [TaskModel], usersAnswers: [String : String]) {
        self.testTasks = testTasks
        self.usersAnswers = usersAnswers
    }
    
    public required convenience init?(coder: NSCoder) {
        let decodedTasks = coder.decodeObject(forKey: "testTasks") as! [TaskModel]
        let decodedAnswers = coder.decodeObject(forKey: "usersAnswers") as! [String : String]
        self.init(testTasks: decodedTasks, usersAnswers: decodedAnswers)
    }
}

