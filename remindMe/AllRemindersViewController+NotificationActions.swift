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
    func viewReminder() {
        NSLog(#function)
        print(#function)
        notificationHasGoneOff = true

        if let reminder = reminderFromNotification {
            // Tracking
            Answers.logCustomEvent(withName: "View Reminder", customAttributes: ["Category": "Notification"])
            performSegue(withIdentifier: "Popup", sender: reminder)
        }
        
    }
    
}
