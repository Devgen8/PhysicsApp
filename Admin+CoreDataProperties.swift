//
//  Admin+CoreDataProperties.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 30.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//
//

import Foundation
import CoreData


extension Admin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Admin> {
        return NSFetchRequest<Admin>(entityName: "Admin")
    }

    @NSManaged public var tasksLevels: NSObject?
    @NSManaged public var tasks: NSSet?

}

// MARK: Generated accessors for tasks
extension Admin {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: AdminStatTask)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: AdminStatTask)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}
