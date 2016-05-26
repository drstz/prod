//
//  Reminder+CoreDataProperties.swift
//  remindMe
//
//  Created by Duane Stoltz on 18/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Reminder {

    @NSManaged var dueDate: NSDate
    @NSManaged var nextDueDate: NSDate?
    
    @NSManaged var name: String
    @NSManaged var typeOfInterval: String?
    
    @NSManaged var everyAmount: NSNumber?
    
    @NSManaged var idNumber: NSNumber
    
    @NSManaged var isEnabled: NSNumber
    @NSManaged var isComplete: NSNumber 
    @NSManaged var isRecurring: NSNumber
 
    @NSManaged var list: List

}
