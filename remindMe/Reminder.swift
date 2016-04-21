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

// Insert code here to add functionality to your managed object subclass
    
    func iAlwaysGetCalled() {
        print(#function)
    }
    
    func scheduleNotifications() {
        print(#function)
        if self.objectID.temporaryID == false {
            let localNotification = UILocalNotification()
            localNotification.fireDate = dueDate
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.alertBody = name
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.userInfo = ["ReminderID": "\(self.objectID)"]
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            print("My id is not temp! Yay")
            print("Notificaiton  was set")
        } else {
            print("My id is temp :-(")
            print("Notification was not set")
        }
    }

}
