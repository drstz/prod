//
//  AllRemindersViewController+PopupDelegate.swift
//  remindMe
//
//  Created by Duane Stoltz on 21/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation

extension AllRemindersViewController: PopupViewControllerDelegate {
    func popupViewControllerDidComplete(controller: PopupViewController, reminder: Reminder) {
        reminder.complete()
        coreDataHandler.save()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func popupViewControllerDidSnooze(controller: PopupViewController, reminder: Reminder) {
        reminder.snooze()
        coreDataHandler.save()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func popupViewControllerDidDelete(controller: PopupViewController, reminder: Reminder) {
        deleteReminder(reminder)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
