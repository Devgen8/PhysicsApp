//
//  TestsHistory+CoreDataProperties.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 14.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//
//

import Foundation
import CoreData


extension TestsHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TestsHistory> {
        return NSFetchRequest<TestsHistory>(entityName: "TestsHistory")
    }

    @NSManaged public var tests: NSOrderedSet?

}

// MARK: Generated accessors for tests
extension TestsHistory {

    @objc(insertObject:inTestsAtIndex:)
    @NSManaged public func insertIntoTests(_ value: TestsResults, at idx: Int)

    @objc(removeObjectFromTestsAtIndex:)
    @NSManaged public func removeFromTests(at idx: Int)

    @objc(insertTests:atIndexes:)
    @NSManaged public func insertIntoTests(_ values: [TestsResults], at indexes: NSIndexSet)

    @objc(removeTestsAtIndexes:)
    @NSManaged public func removeFromTests(at indexes: NSIndexSet)

    @objc(replaceObjectInTestsAtIndex:withObject:)
    @NSManaged public func replaceTests(at idx: Int, with value: TestsResults)

    @objc(replaceTestsAtIndexes:withTests:)
    @NSManaged public func replaceTests(at indexes: NSIndexSet, with values: [TestsResults])

    @objc(addTestsObject:)
    @NSManaged public func addToTests(_ value: TestsResults)

    @objc(removeTestsObject:)
    @NSManaged public func removeFromTests(_ value: TestsResults)

    @objc(addTests:)
    @NSManaged public func addToTests(_ values: NSOrderedSet)

    @objc(removeTests:)
    @NSManaged public func removeFromTests(_ values: NSOrderedSet)

}
