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
        var nbOfReminders = numberOfReminders.integerValue
        nbOfReminders += 1
        numberOfReminders = NSNumber(integer: nbOfReminders)
    }
    
    func increaseNbOfCompletedReminders() {
        var nbOfCompletedReminders = numberOfCompletedReminders.integerValue
        nbOfCompletedReminders += 1
        numberOfCompletedReminders = NSNumber(integer: nbOfCompletedReminders)
    }
    
    func increaseNumberOfRemindersCompletedBeforeDueDate() {
        var nbOfRemindersCompletedBeforeDueDate = numberOfRemindersCompletedBeforeDueDate.integerValue
        nbOfRemindersCompletedBeforeDueDate += 1
        numberOfRemindersCompletedBeforeDueDate = NSNumber(integer: nbOfRemindersCompletedBeforeDueDate)
    }
    
    func increaseTotalTimesSnoozed() {
        var nbOfTimesSnoozed = totalTimesSnoozed.integerValue
        nbOfTimesSnoozed += 1
        totalTimesSnoozed = NSNumber(integer: nbOfTimesSnoozed)
    }
    
    func addDifferenceBetweenDates(difference: Int) {
        var differenceToModify = differenceBetweenDueCompletionDate.integerValue
        differenceToModify += difference
        differenceBetweenDueCompletionDate = NSNumber(integer: differenceToModify)
    }
}
