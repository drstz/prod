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
    
    func snoozeReminder() {
        print(#function)
        if let reminder = reminderFromNotification {
            reminder.snooze()
        }
        coreDataHandler.save()
    }
    
    func viewReminder() {
        print(#function)
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
            print("Error")
        }
        
    }
    
}
