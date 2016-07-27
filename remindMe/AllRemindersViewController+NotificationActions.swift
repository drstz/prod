//
//  AllRemindersViewController+NotificationActions.swift
//  remindMe
//
//  Created by Duane Stoltz on 04/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import UIKit

extension AllRemindersViewController {
    
    func completeReminder() {
        print(#function)
        if let reminder = reminderFromNotification {
            reminder.complete()
        }
        
        coreDataHandler.save()
    }
    
    func deferReminder() {
        print(#function)
        if let reminder = reminderFromNotification {
            reminder.snooze()
        }
        coreDataHandler.save()
    }
    
    func viewReminder() {
        print(#function)
        print(myTabIndex)
        //        let reminderNotificationHandler = reminderFromNotification?.notificationHandler
        //        reminderNotificationHandler?.deleteReminderNotifications(reminderFromNotification!)
        notificationHasGoneOff = true
        if let reminder = reminderFromNotification {
            if presentedViewController != nil {
                dismissViewControllerAnimated(false, completion: {
                    self.performSegueWithIdentifier("Popup", sender: reminder)
                })
            } else {
                performSegueWithIdentifier("Popup", sender: reminder)
            }
            
        } else {
//            let alert = UIAlertController(title: "Error", message: "Could not find reminder", preferredStyle: .Alert)
//            let action = UIAlertAction(title: "Dismiss", style: .Default, handler: nil)
//            alert.addAction(action)
//            presentViewController(alert, animated: true, completion: nil)
            print("Error")
        }
        
    }
    
}
