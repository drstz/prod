//
//  AllRemindersViewController+NotificationActions.swift
//  remindMe
//
//  Created by Duane Stoltz on 04/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation

extension AllRemindersViewController {
    
    func completeReminder() {
        if let reminder = reminderFromNotification {
            reminder.complete()
        }
        
        coreDataHandler.save()
    }
    
    func deferReminder() {
        if let reminder = reminderFromNotification {
            reminder.snooze()
        }
        coreDataHandler.save()
    }
    
    func viewReminder() {
        print(#function)
        //        let reminderNotificationHandler = reminderFromNotification?.notificationHandler
        //        reminderNotificationHandler?.deleteReminderNotifications(reminderFromNotification!)
        notificationHasGoneOff = true
        
        performSegueWithIdentifier("QuickView", sender: reminderFromNotification)
    }
    
}
