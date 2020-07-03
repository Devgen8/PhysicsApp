//
//  EgeTheme+CoreDataProperties.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 18.06.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//
//

import Foundation
import CoreData


extension EgeTheme {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EgeTheme> {
        return NSFetchRequest<EgeTheme>(entityName: "EgeTheme")
    }

    @NSManaged public var name: String?
    @NSManaged public var tasks: NSOrderedSet?
    @NSManaged public var trainer: Trainer?

}

// MARK: Generated accessors for tasks
extension EgeTheme {

    @objc(insertObject:inTasksAtIndex:)
    @NSManaged public func insertIntoTasks(_ value: TaskData, at idx: Int)

    @objc(removeObjectFromTasksAtIndex:)
    @NSManaged public func removeFromTasks(at idx: Int)

    @objc(insertTasks:atIndexes:)
    @NSManaged public func insertIntoTasks(_ values: [TaskData], at indexes: NSIndexSet)

    @objc(removeTasksAtIndexes:)
    @NSManaged public func removeFromTasks(at indexes: NSIndexSet)

    @objc(replaceObjectInTasksAtIndex:withObject:)
    @NSManaged public func replaceTasks(at idx: Int, with value: TaskData)

    @objc(replaceTasksAtIndexes:withTasks:)
    @NSManaged public func replaceTasks(at indexes: NSIndexSet, with values: [TaskData])

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: TaskData)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: TaskData)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSOrderedSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSOrderedSet)

}