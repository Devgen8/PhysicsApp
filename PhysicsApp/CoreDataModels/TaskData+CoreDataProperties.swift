//
//  TaskData+CoreDataProperties.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 04.08.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//
//

import Foundation
import CoreData


extension TaskData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskData> {
        return NSFetchRequest<TaskData>(entityName: "TaskData")
    }

    @NSManaged public var alternativeAnswer: Bool
    @NSManaged public var image: Data?
    @NSManaged public var name: String?
    @NSManaged public var serialNumber: Int16
    @NSManaged public var taskDescription: Data?
    @NSManaged public var wrightAnswer: String?
    @NSManaged public var egeTask: EgeTask?
    @NSManaged public var egeTheme: EgeTheme?

}
