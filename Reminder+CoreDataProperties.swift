//
//  Reminder+CoreDataProperties.swift
//  remindMe
//
//  Created by Duane Stoltz on 14/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Reminder {

    @NSManaged var name: String
    @NSManaged var dueDate: NSDate

}
