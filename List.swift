//
//  List.swift
//  remindMe
//
//  Created by Duane Stoltz on 23/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import CoreData


class List: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    func increaseNbOfReminders() {
        var nbOfReminders = numberOfReminders.intValue
        nbOfReminders += 1
        numberOfReminders = NSNumber(value: nbOfReminders as Int)
    }
    
    func increaseNbOfCompletedReminders() {
        var nbOfCompletedReminders = numberOfCompletedReminders.intValue
        nbOfCompletedReminders += 1
        numberOfCompletedReminders = NSNumber(value: nbOfCompletedReminders as Int)
    }
    
    func increaseNumberOfRemindersCompletedBeforeDueDate() {
        var nbOfRemindersCompletedBeforeDueDate = numberOfRemindersCompletedBeforeDueDate.intValue
        nbOfRemindersCompletedBeforeDueDate += 1
        numberOfRemindersCompletedBeforeDueDate = NSNumber(value: nbOfRemindersCompletedBeforeDueDate as Int)
    }
    
    func increaseTotalTimesSnoozedBeforeCompletion(_ nbOfTimes: Int) {
        var nbOfTimesSnoozed = totalTimesSnoozed.intValue
        nbOfTimesSnoozed += nbOfTimes
        totalTimesSnoozed = NSNumber(value: nbOfTimesSnoozed as Int)
    }
    
    func addDifferenceBetweenDates(_ difference: Int) {
        var differenceToModify = differenceBetweenDueCompletionDate.intValue
        differenceToModify += difference
        differenceBetweenDueCompletionDate = NSNumber(value: differenceToModify as Int)
    }
    
    func increaseNbOfSnoozedReminders() {
        var nbOfRemindersSnoozed = numberOfSnoozedReminders.intValue
        nbOfRemindersSnoozed += 1
        numberOfSnoozedReminders = NSNumber(value: nbOfRemindersSnoozed as Int)
    }
}
