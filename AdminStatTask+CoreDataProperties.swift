//
//  AdminStatTask+CoreDataProperties.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 30.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//
//

import Foundation
import CoreData


extension AdminStatTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AdminStatTask> {
        return NSFetchRequest<AdminStatTask>(entityName: "AdminStatTask")
    }

    @NSManaged public var name: String?
    @NSManaged public var theme: String?
    @NSManaged public var failed: Int16
    @NSManaged public var succeded: Int16
    @NSManaged public var admin: Admin?

}
