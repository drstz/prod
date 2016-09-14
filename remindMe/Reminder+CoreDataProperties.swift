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
    
    // Name
    
    @NSManaged var name: String
    @NSManaged var comment: String?
    
    // Details
    @NSManaged var creationDate: NSDate
    @NSManaged var idNumber: NSNumber
    @NSManaged var list: List
    
    @NSManaged var willAutoSnooze: NSNumber
    
    // Dates
    @NSManaged var dueDate: NSDate
    
    @NSManaged var repeats: NSNumber

    @NSManaged var usesCustomPattern: NSNumber
    @NSManaged var interval: String?
    @NSManaged var frequency: NSNumber?
    
    @NSManaged var usesDayPattern: NSNumber
    @NSManaged var selectedDays: NSMutableArray
    
    @NSManaged var isFavorite: NSNumber?
    
    @NSManaged var timesSnoozed: NSNumber
    
    // Completion
    @NSManaged var wasCompleted: NSNumber
    @NSManaged var completionDate: NSDate?
    
    // Seperate reminders into different sections
    var section: String? {
        print("Creating section")
        
        if isDue() && wasCompleted == false {
            return "Due"
        }
        
        if dueDate.isToday() {
            return "Today"
        }
        
        if dueDate.isTomorrow() {
            return "Tomorrow"
        }
        
        if dueDate.isYesterday() {
            return "Yesterday"
        }
        
        if dueDate.isPresent() {
            if dueDate.underMonths(months: 2) {
                if dueDate.underMonths(months: 1) {
                    if dueDate.underWeek(weeks: 1) {
                        if dueDate.lessThanWeekFromNow() && dueDate.isPresent() {
                            return dueDate.writtenDay()
                        } else if dueDate.isPresent() {
                            return "In over a week"
                        }
                    } else {
                        return "In over a week"
                    }
                } else {
                    return "In over a month"
                }
            } else {
                return "Later"
            }
        }
        
        
        return dueDate.writtenDayPlusMonth()
    }

}
