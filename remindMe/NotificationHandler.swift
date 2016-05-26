//
//  NotificationHandler.swift
//  remindMe
//
//  Created by Duane Stoltz on 26/05/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import UIKit

class NotificationHandler {
    
    deinit {
        print("Notification Handler was deallocated")
    }
    
    func scheduleNotifications(reminder: Reminder, snooze isBeingDeferred: Bool = false) {
        let name = reminder.name
        let idNumber = reminder.idNumber
        
        deleteReminderNotifications(reminder)
        
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
        localNotification.alertTitle = name
        
        localNotification.category = "CATEGORY"
        localNotification.soundName = UILocalNotificationDefaultSoundName
        
        localNotification.userInfo = ["ReminderID": idNumber]
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
        let numberOfNotifications = countAllNotifications()
        print("Total of \(numberOfNotifications) notifications" )
    }
    
    func deleteReminderNotifications(reminder: Reminder)  {
        let notifications = notificationsForReminder(reminder)
        
        for notification in notifications {
            UIApplication.sharedApplication().cancelLocalNotification(notification)
            print("Deleted notification for \(reminder.name)")
        }
        
        let numberOfNotifications = countReminderNotifications(reminder)
        print("\(numberOfNotifications) notifications for \(reminder.name)")
    }
    
    func allNotifications() -> [UILocalNotification] {
        let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications!
        return allNotifications
    }
    
    func notificationsForReminder(reminder: Reminder) -> [UILocalNotification] {
        let notifications = allNotifications()
        var notificationsForReminder = [UILocalNotification]()
        
        for notification in notifications {
            if let reminderID = notification.userInfo?["ReminderID"] as? Int where reminderID == reminder.idNumber {
                notificationsForReminder.append(notification)
            }
        }
        return notificationsForReminder
    }
    
    func countReminderNotifications(reminder: Reminder) -> Int {
        let notifications = notificationsForReminder(reminder)
        return notifications.count
    }
    
    func countAllNotifications() -> Int {
        let notifications = allNotifications()
        return notifications.count
    }
}