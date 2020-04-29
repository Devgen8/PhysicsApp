//
//  Trainer+CoreDataProperties.swift
//  
//
//  Created by Evgeny Kamaev on 23.04.2020.
//
//

import Foundation
import CoreData


extension Trainer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trainer> {
        return NSFetchRequest<Trainer>(entityName: "Trainer")
    }

    @NSManaged public var egeTasks: NSSet?

}

// MARK: Generated accessors for egeTasks
extension Trainer {

    @objc(addEgeTasksObject:)
    @NSManaged public func addToEgeTasks(_ value: EgeTask)

    @objc(removeEgeTasksObject:)
    @NSManaged public func removeFromEgeTasks(_ value: EgeTask)

    @objc(addEgeTasks:)
    @NSManaged public func addToEgeTasks(_ values: NSSet)

    @objc(removeEgeTasks:)
    @NSManaged public func removeFromEgeTasks(_ values: NSSet)

}
