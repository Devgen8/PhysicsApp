//
//  TaskData+CoreDataProperties.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 28.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//
//

import Foundation
import CoreData


extension TaskData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskData> {
        return NSFetchRequest<TaskData>(entityName: "TaskData")
    }

    @NSManaged public var alternativeAnswer: Double
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var serialNumber: Int16
    @NSManaged public var stringAnswer: String?
    @NSManaged public var wrightAnswer: Double
    @NSManaged public var egeTask: EgeTask?
    @NSManaged public var egeTheme: EgeTheme?

}
