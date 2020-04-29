//
//  EgeTask+CoreDataProperties.swift
//  
//
//  Created by Evgeny Kamaev on 23.04.2020.
//
//

import Foundation
import CoreData


extension EgeTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EgeTask> {
        return NSFetchRequest<EgeTask>(entityName: "EgeTask")
    }

    @NSManaged public var name: String?
    @NSManaged public var numberOfTasks: Int16
    @NSManaged public var themeNumber: Int16
    @NSManaged public var themes: NSObject?
    @NSManaged public var trainer: Trainer?

}
