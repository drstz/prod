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
        print("")
        print(#function)
        print("Reminder was deallocated")
    }
    
    func complete() {
        print("Going to complete reminder")
        
        
        if reminderIsRecurring() {
            let newDate = setNewDueDate()
            dueDate = newDate
            notificationHandler.scheduleNotifications(self)
            print("Completed Reminder - New One Scheduled")
        } else {
            isComplete = true
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
    
    func setTitle(title: String)  {
        name = title
    }
    
    func setDate(date: NSDate) {
        dueDate = date
    }
    
    func setNextDate(date: NSDate?) {
        nextDueDate = date
    }
    
    func setRepeatInterval(interval: String?) {
        typeOfInterval = interval
    }
    
    func setRepeatFrequency(frequency: Int?) {
        everyAmount = frequency
    }
    
    func setCompletionStatus(status: Bool) {
        isComplete = status
    }
    
    func setFavorite(choice: Bool) {
        isFavorite = choice
    }
    
    func setRecurring(choice: Bool) {
        isRecurring = choice
    }
    
    func addToList(list: List) {
        self.list = list
    }

}
