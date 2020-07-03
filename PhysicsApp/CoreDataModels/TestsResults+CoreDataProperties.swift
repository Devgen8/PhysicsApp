//
//  TestsResults+CoreDataProperties.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 18.06.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//
//

import Foundation
import CoreData


extension TestsResults {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TestsResults> {
        return NSFetchRequest<TestsResults>(entityName: "TestsResults")
    }

    @NSManaged public var name: String?
    @NSManaged public var points: Int16
    @NSManaged public var semiWrightAnswerNumber: Int16
    @NSManaged public var testResultObject: NSObject?
    @NSManaged public var timeTillEnd: Int16
    @NSManaged public var wrightAnswerNumber: Int16
    @NSManaged public var testsHistory: TestsHistory?

}
