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

    
    func iAlwaysGetCalled() {
        print(#function)
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
        print(#function)
        print(self.objectID.URIRepresentation())
        let existingNotification = notificationForThisItem()
        if let notification = existingNotification {
            print("Going to change a notification: \(notification)")
            UIApplication.sharedApplication().cancelLocalNotification(notification)
            print("Old notification was deleted")
        }
        
        if self.objectID.temporaryID == false {
            let localNotification = UILocalNotification()
            localNotification.fireDate = dueDate
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.alertBody = name
            localNotification.soundName = UILocalNotificationDefaultSoundName
            let reminderID = String(self.objectID.URIRepresentation())
            localNotification.userInfo = ["ReminderID": reminderID]
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            print("My id is not temp! Yay")
            print("Notificaiton  was set")
        } else {
            print("My id is temp :-(")
            print("Notification was not set")
        }
    }

}
