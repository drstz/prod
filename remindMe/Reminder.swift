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
        if let notification = notificationForThisItem() {
            print("Deleteing notification with task")
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
    }
    
    func addIDtoReminder() {
        let idasInteger = list.numberOfReminders.integerValue + idNumber.integerValue
        idNumber = NSNumber(integer: idasInteger)
    }
    
    func notificationForThisItem() -> UILocalNotification? {
        print(#function)
        let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications!
        
        for notification in allNotifications {
            if let reminderID = notification.userInfo?["ReminderID"]  as? String where reminderID == String(self.objectID.URIRepresentation()) {
                print("I've found the notification!")
                return notification
            }
        }
        return nil
    }
    
    func scheduleNotifications() {
        
        let existingNotification = notificationForThisItem()
        if let notification = existingNotification {
            print("Going to change a notification: \(notification)")
            UIApplication.sharedApplication().cancelLocalNotification(notification)
            print("Old notification was deleted")
        }
        
        if self.objectID.temporaryID == false {
            let localNotification = UILocalNotification()
            
            // localNotification.fireDate = dueDate
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 10)
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            
            localNotification.alertBody = "Hi Bob!"
            localNotification.alertAction = "Complete"
            localNotification.category = "CATEGORY"
            localNotification.alertTitle = name
            localNotification.soundName = UILocalNotificationDefaultSoundName
   
            let reminderID = String(self.objectID.URIRepresentation())

            localNotification.userInfo = ["ReminderID": reminderID]
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            print("Notificaiton  was set")
        } else {
            print("Notification was not set")
        }
        
        
    }

}
