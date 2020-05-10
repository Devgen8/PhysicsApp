//
//  Test+CoreDataProperties.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 10.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//
//

import Foundation
import CoreData


extension Test {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Test> {
        return NSFetchRequest<Test>(entityName: "Test")
    }

    @NSManaged public var name: String?
    @NSManaged public var numberOfWrightAnswers: Int16
    @NSManaged public var testObject: NSObject?
    @NSManaged public var time: Int64
    @NSManaged public var points: Int16
    @NSManaged public var numberOfSemiWrightAnswers: Int16
    @NSManaged public var trainer: Trainer?

}
