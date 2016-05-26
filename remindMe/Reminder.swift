//
//  Reminder.swift
//  remindMe
//
//  Created by Duane Stoltz on 18/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Reminder: NSManagedObject {
    
    let notificationHandler = NotificationHandler()
    
    deinit {
        print("Reminder was deallocated")
    }
    
    func complete() {
        print("Going to complete reminder")
        isComplete = true
        
        if reminderIsRecurring() {
            let newDate = setNewDueDate()
            dueDate = newDate
            notificationHandler.scheduleNotifications(self)
        } else {
            notificationHandler.deleteReminderNotifications(self)
        }
    }
    
    func snooze() {
        print("Going to snooze reminder")
        notificationHandler.scheduleNotifications(self, snooze: true)
    }
    
    
    func reminderIsRecurring() -> Bool {
        if isRecurring == 0 {
            return false
        } else {
            return true
        }
    }
    
    func reminderIsComplete() -> Bool {
        if isComplete == 0 {
            return false
        } else {
            return true
        }
    }
    
    func setNewDueDate() -> NSDate {
        return createNewDate(dueDate, typeOfInterval: typeOfInterval!, everyAmount: everyAmount! as Int)
    }
    
    func addIDtoReminder() {
        let idAsInteger = list.numberOfReminders.integerValue + idNumber.integerValue
        idNumber = NSNumber(integer: idAsInteger)
    }

}
