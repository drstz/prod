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
            wasCompleted = true
            notificationHandler.deleteReminderNotifications(self)
        }
        
        completionDate = Date()
        list.increaseNbOfCompletedReminders()
        if isDue() {
            let nbOfMinutesDifferenceBetweenDates = calculateNbOfMinutesDifference(dueDate as Date, secondDate: completionDate! as Date)
            list.addDifferenceBetweenDates(nbOfMinutesDifferenceBetweenDates)
        }
        
        
        let earlierDate = (completionDate as NSDate?)?.earlierDate(dueDate as Date)
        if earlierDate == completionDate {
            list.increaseNumberOfRemindersCompletedBeforeDueDate()
        }
        
        if timesSnoozed.intValue > 0 {
            list.increaseNbOfSnoozedReminders()
        }
        
        list.increaseTotalTimesSnoozedBeforeCompletion(timesSnoozed.intValue)
        resetStats()
        
    }
    
    private func resetStats() {
        timesSnoozed = 0
    }
    
    func calculateNbOfMinutesDifference(_ firstDate: Date, secondDate: Date) -> Int {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.minute, from: firstDate, to: secondDate, options: [])
        let nbOfMinutes = components.minute
        
        return nbOfMinutes!
    }
    
    func snooze() {
        print("Going to snooze reminder")
        print("")
        
        let newDate = calculateNewDate()
        setDate(newDate)
        
        notificationHandler.scheduleNotifications(self, snooze: true)
        var nbOfSnoozesAsInt = timesSnoozed.intValue
        nbOfSnoozesAsInt += 1
        timesSnoozed = NSNumber(value: nbOfSnoozesAsInt as Int)
    }
    
    func calculateNewDate() -> Date {
        let userDefaults = UserDefaults.standard
        let chosenUnit = userDefaults.object(forKey: "SnoozeUnit") as! String
        
        
        let duration = userDefaults.double(forKey: "SnoozeDuration")
        let unit = SnoozeUnit(rawValue: chosenUnit)
        
        let deferInterval = snoozeDuration(duration, unit: unit!)
        
        return Date(timeIntervalSinceNow: deferInterval)
    }
    
    func reminderIsRecurring() -> Bool {
        if repeats == 0 {
            return false
        } else {
            return true
        }
    }
    
    func isDue() -> Bool {
        //print(#function)
        let now = Date()
        let earlierDate = (dueDate as NSDate).earlierDate(now)
        
        return earlierDate == dueDate as Date
    }
    
    func reminderIsComplete() -> Bool {
        if wasCompleted == 0 {
            return false
        } else {
            return true
        }
    }
    
    func setNewDueDate() -> Date {
        if usesCustomPattern == true {
            return createNewDate(dueDate, typeOfInterval: interval!, everyAmount: frequency! as Int)
        } else {
            return setNewDay()
        }
    }
    
    func setNewDay() -> Date {
//        2,  Monday
//        3,
//        4,
//        5,
//        6,
//        7,
//        1   Sunday
        
        var onlyOneDay = false
        var weekdays = [Int]()
        
        // Get weekday of due date
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.weekday, .hour, .minute], from: dueDate as Date)
        let dayOfDueDate = components.weekday
        var chosenWeekday = 0
        
        for day in selectedDays {
            weekdays.append(Int(day as! NSNumber))
        }
        
        if weekdays.count == 1 {
            if dayOfDueDate == weekdays[0] {
                onlyOneDay = true
            }
        }
        
        if onlyOneDay {
            // If there is only one day, and that day is the same, a week should be added
            return dueDate.addWeeks(1)
        } else {
            for i in 0 ..< weekdays.count {
                if dayOfDueDate! < weekdays[i]  {
                    chosenWeekday = weekdays[i]
                    break
                }
                
                if i == weekdays.count - 1 {
                    chosenWeekday = weekdays[0]
                }
            }
            
            // Change Day
            var newDateWithWeekday = (calendar as NSCalendar).date(
                bySettingUnit: .weekday,
                value: chosenWeekday,
                of: dueDate as Date,
                options: NSCalendar.Options.init(rawValue: 0))
            
            // Change hour back to normal
            newDateWithWeekday = (calendar as NSCalendar).date(
                bySettingHour: components.hour!,
                minute: components.minute!,
                second: 0,
                of: newDateWithWeekday!,
                options: NSCalendar.Options.init(rawValue: 0))
            
            let newDate = newDateWithWeekday!
            return newDate
        }
    }
    
    func addIDtoReminder() {
        let idAsInteger = list.numberOfReminders.intValue + idNumber.intValue
        idNumber = NSNumber(value: idAsInteger as Int)
    }
    
    func setTitle(_ title: String)  {
        name = title
    }
    
    func setDate(_ date: Date) {
        dueDate = date
    }
        
    func setRepeatInterval(_ interval: String?) {
        self.interval = interval
    }
    
    func setRepeatFrequency(_ frequency: Int?) {
        self.frequency = frequency as NSNumber?
    }
    
    func setCompletionStatus(_ status: Bool) {
        wasCompleted = status as NSNumber
    }
    
    func setFavorite(_ choice: Bool) {
        isFavorite = choice as NSNumber?
    }
    
    func setRecurring(_ choice: Bool) {
        repeats = choice as NSNumber
    }
    
    func addToList(_ list: List) {
        self.list = list
    }

}
