//
//  User+CoreDataProperties.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 28.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var solvedTasks: NSObject?
    @NSManaged public var unsolvedTasks: NSObject?
    @NSManaged public var tasksForSolving: NSSet?

}

// MARK: Generated accessors for tasksForSolving
extension User {

    @objc(addTasksForSolvingObject:)
    @NSManaged public func addToTasksForSolving(_ value: TaskData)

    @objc(removeTasksForSolvingObject:)
    @NSManaged public func removeFromTasksForSolving(_ value: TaskData)

    @objc(addTasksForSolving:)
    @NSManaged public func addToTasksForSolving(_ values: NSSet)

    @objc(removeTasksForSolving:)
    @NSManaged public func removeFromTasksForSolving(_ values: NSSet)

}
