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
        print("Reminder was deleted")
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
            print("Notification was deleted")
        } else {
            print("No notifications were found")
        }
    }
    
    func addIDtoReminder() {
        let idAsInteger = list.numberOfReminders.integerValue + idNumber.integerValue
        idNumber = NSNumber(integer: idAsInteger)
    }
    
    func notificationForThisItem() -> UILocalNotification? {
        let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications!
        
        for notification in allNotifications {
            if let reminderID = notification.userInfo?["ReminderID"]  as? Int where reminderID == idNumber {
                print("Returning notifications")
                return notification
            }
        }
        print("Found no notifications")
        return nil
    }
    
    func scheduleNotifications(isBeingDeferred: Bool = false) {
        
        deleteReminderNotifications()
        
        let localNotification = UILocalNotification()
        
        if isBeingDeferred {
            // For testing
            print("Deffered Notification")
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 10)
            localNotification.repeatInterval = .Minute
//            localNotification.fireDate = NSDate(timeIntervalSinceNow: 10 * 60)
        } else {
            // For testing
//            localNotification.fireDate = NSDate(timeIntervalSinceNow: 10)
            localNotification.repeatInterval = .Minute
            localNotification.fireDate = dueDate
            
            
        }

        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        
        localNotification.alertBody = name
        localNotification.category = "CATEGORY"
        localNotification.alertTitle = name
        localNotification.soundName = UILocalNotificationDefaultSoundName
        
        localNotification.userInfo = ["ReminderID": idNumber]
        
        print(localNotification.fireDate)
        print(dueDate)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        print("Notification  was set")
        
    }
    

}
