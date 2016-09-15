//
//  AllRemindersViewController+PopupDelegate.swift
//  remindMe
//
//  Created by Duane Stoltz on 21/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation

extension AllRemindersViewController: PopupViewControllerDelegate {
    func popupViewControllerDidComplete(_ controller: PopupViewController, reminder: Reminder) {
        reminder.complete()
        coreDataHandler.save()
        dismiss(animated: true, completion: nil)
    }
    
    func popupViewControllerDidSnooze(_ controller: PopupViewController, reminder: Reminder) {
        reminder.snooze()
        coreDataHandler.save()
        dismiss(animated: true, completion: nil)
    }
    
    func popupViewControllerDidDelete(_ controller: PopupViewController, reminder: Reminder) {
        deleteReminder(reminder)
        dismiss(animated: true, completion: nil)
    }
}
