//
//  AllRemindersViewController+NotificationActions.swift
//  remindMe
//
//  Created by Duane Stoltz on 04/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import UIKit
import Fabric
import Crashlytics

extension AllRemindersViewController {
    
//    func completeReminder() {
//        print(#function)
//        NSLog(#function)
//        if let reminder = reminderFromNotification {
//            reminder.complete()
//            
//            // Tracking
//            Answers.logCustomEvent(withName: "Completed", customAttributes: ["Category": "Notification"])
//        }
//        coreDataHandler.save()
//    }
//    
//    func snoozeReminder() {
//        NSLog(#function)
//        print(#function)
//        if let reminder = reminderFromNotification {
//            reminder.snooze()
//            
//            // Tracking
//            Answers.logCustomEvent(withName: "Snoozed", customAttributes: ["Category": "Notification"])
//        }
//        coreDataHandler.save()
//    }
    
    func viewReminder() {
        NSLog(#function)
        print(#function)
        notificationHasGoneOff = true
//        if let reminder = reminderFromNotification {
//            if presentedViewController != nil {
//                dismissViewControllerAnimated(false, completion: {
//                    self.performSegueWithIdentifier("Popup", sender: reminder)
//                })
//            } else {
//                performSegueWithIdentifier("Popup", sender: reminder)
//            }
//            
//        } else {
//            print("Error")
//        }
        if let reminder = reminderFromNotification {
            // Tracking
            Answers.logCustomEvent(withName: "View Reminder", customAttributes: ["Category": "Notification"])
            performSegue(withIdentifier: "Popup", sender: reminder)
        }
        
    }
    
}
