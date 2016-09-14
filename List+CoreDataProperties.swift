//
//  List+CoreDataProperties.swift
//  remindMe
//
//  Created by Duane Stoltz on 23/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension List {
    /// Number of created reminders. This shouldn't change
    @NSManaged var numberOfReminders: NSNumber
    @NSManaged var numberOfCompletedReminders: NSNumber
    @NSManaged var numberOfSnoozedReminders: NSNumber
    
    @NSManaged var numberOfRemindersCompletedBeforeDueDate: NSNumber
    
    @NSManaged var differenceBetweenDueCompletionDate: NSNumber
    
    @NSManaged var totalTimesSnoozed: NSNumber
    
    @NSManaged weak var reminders: NSSet?

}
