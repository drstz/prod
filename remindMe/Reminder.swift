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
        
        completionDate = NSDate()
    }
    
    func snooze() {
        print("Going to snooze reminder")
        let newDate = calculateNewDate()
        setDate(newDate)
        
        notificationHandler.scheduleNotifications(self, snooze: true)
        var nbOfSnoozesAsInt = nbOfSnoozes.integerValue
        nbOfSnoozesAsInt += 1
        nbOfSnoozes = NSNumber(integer: nbOfSnoozesAsInt)
    }
    
    func calculateNewDate() -> NSDate {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let chosenUnit = userDefaults.objectForKey("SnoozeUnit") as! String
        
        
        let duration = userDefaults.doubleForKey("SnoozeDuration")
        let unit = SnoozeUnit(rawValue: chosenUnit)
        
        let deferInterval = snoozeDuration(duration, unit: unit!)
        
        return NSDate(timeIntervalSinceNow: deferInterval)
    }
    
    func reminderIsRecurring() -> Bool {
        if isRecurring == 0 {
            return false
        } else {
            return true
        }
    }
    
    func isDue() -> Bool {
        //print(#function)
        let now = NSDate()
        let earlierDate = dueDate.earlierDate(now)
        
        return earlierDate == dueDate
    }
    
    func reminderIsComplete() -> Bool {
        if isComplete == 0 {
            return false
        } else {
            return true
        }
    }
    
    func setNewDueDate() -> NSDate {
        if usePattern == true {
            return createNewDate(dueDate, typeOfInterval: typeOfInterval!, everyAmount: everyAmount! as Int)
        } else {
            return setNewDay()
        }
    }
    
    func setNewDay() -> NSDate {
        var weekdays = [Int]()
        
        // Get weekday of due date
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Weekday, .Hour, .Minute], fromDate: dueDate)
        let dayOfDueDate = components.weekday
        var chosenWeekday = 0
        
        // 1, 2, 3, 4 , 5 , 6, 7
        for day in selectedDays {
            weekdays.append(Int(day as! NSNumber))
        }
        
        for i in 0 ..< weekdays.count {
            if dayOfDueDate < weekdays[i]  {
                chosenWeekday = weekdays[i]
                break
            }
            
            if i == weekdays.count - 1 {
                chosenWeekday = weekdays[0]
            }
        }
        
        // Change Day
        var newDateWithWeekday = calendar.dateBySettingUnit(
            .Weekday,
            value: chosenWeekday,
            ofDate: dueDate,
            options: NSCalendarOptions.init(rawValue: 0))
        
        // Change hour back to normal
        newDateWithWeekday = calendar.dateBySettingHour(
            components.hour,
            minute: components.minute,
            second: 0,
            ofDate: newDateWithWeekday!,
            options: NSCalendarOptions.init(rawValue: 0))
        
        let newDate = newDateWithWeekday!
        return newDate
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
    
//    func setNextDate(date: NSDate?) {
//        nextDueDate = date
//    }
    
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
        isRecurring = choice as NSNumber
    }
    
    func addToList(list: List) {
        self.list = list
    }

}
