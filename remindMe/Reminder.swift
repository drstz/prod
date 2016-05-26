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
    
    deinit {
        print("\(name) was deleted")
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
    
    func deleteReminderNotifications()  {
        if let notification = notificationForThisItem() {
            UIApplication.sharedApplication().cancelLocalNotification(notification)
            print("Deleted notification for \(name)")
        } else {
            print("Deleted no notifications")
        }
        countNotifications()
    }
    
    func addIDtoReminder() {
        let idAsInteger = list.numberOfReminders.integerValue + idNumber.integerValue
        idNumber = NSNumber(integer: idAsInteger)
    }
    
    func countNotifications() {
        let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications!
        let notificationCount = allNotifications.count
        
        var notificationForReminder = [UILocalNotification]()
        
        for notification in allNotifications {
            if let reminderID = notification.userInfo?["ReminderID"] as? Int where reminderID == idNumber {
                notificationForReminder.append(notification)
            }
        }
        
        let notificationForReminderCount = notificationForReminder.count
        
        print("")
        print("\(notificationCount) notifications are scheduled")
        print("\(notificationForReminderCount) notifications for \(name) -- ID: \(idNumber)")
        
    }
    
    func notificationForThisItem() -> UILocalNotification? {
        let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications!
        
        print("\(allNotifications.count) scheduled notifications")
        
        for notification in allNotifications {
            if let reminderID = notification.userInfo?["ReminderID"] as? Int where reminderID == idNumber {
                
                print("Returning notification for \(name)")
                return notification
            }
        }
        print("No notifications found")
        return nil
    }
    
    func scheduleNotifications(snooze isBeingDeferred: Bool = false) {
        
        deleteReminderNotifications()
        
        let localNotification = UILocalNotification()
        
        if isBeingDeferred {
            // For testing
            print("Deferring notification for \(name)")
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 10)
            localNotification.repeatInterval = .Minute
//            localNotification.fireDate = NSDate(timeIntervalSinceNow: 10 * 60)
        } else {
            // For testing
            print("Setting notification for \(name)")
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 10)
            localNotification.repeatInterval = .Minute
            // localNotification.fireDate = dueDate
            
            
        }

        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        
        localNotification.alertBody = name
        localNotification.category = "CATEGORY"
        localNotification.alertTitle = name
        localNotification.soundName = UILocalNotificationDefaultSoundName
        
        localNotification.userInfo = ["ReminderID": idNumber]
        
        let fireDate = localNotification.fireDate

        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        print("Notification for \(name)  was set for \(fireDate)")
        
        countNotifications()
        
    }
    

}
