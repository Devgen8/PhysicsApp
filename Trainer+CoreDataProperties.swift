//
//  Trainer+CoreDataProperties.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 01.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//
//

import Foundation
import CoreData


extension Trainer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Trainer> {
        return NSFetchRequest<Trainer>(entityName: "Trainer")
    }

    @NSManaged public var themeTasksSafe: NSObject?
    @NSManaged public var testParameters: NSObject?
    @NSManaged public var egeTasks: NSSet?
    @NSManaged public var egeThemes: NSSet?
    @NSManaged public var tests: NSSet?

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

// MARK: Generated accessors for egeThemes
extension Trainer {

    @objc(addEgeThemesObject:)
    @NSManaged public func addToEgeThemes(_ value: EgeTheme)

    @objc(removeEgeThemesObject:)
    @NSManaged public func removeFromEgeThemes(_ value: EgeTheme)

    @objc(addEgeThemes:)
    @NSManaged public func addToEgeThemes(_ values: NSSet)

    @objc(removeEgeThemes:)
    @NSManaged public func removeFromEgeThemes(_ values: NSSet)

}

// MARK: Generated accessors for tests
extension Trainer {

    @objc(addTestsObject:)
    @NSManaged public func addToTests(_ value: Test)

    @objc(removeTestsObject:)
    @NSManaged public func removeFromTests(_ value: Test)

    @objc(addTests:)
    @NSManaged public func addToTests(_ values: NSSet)

    @objc(removeTests:)
    @NSManaged public func removeFromTests(_ values: NSSet)

}
