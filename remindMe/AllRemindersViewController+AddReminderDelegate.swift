//
//  AllRemindersViewController+AddReminderDelegate.swift
//  remindMe
//
//  Created by Duane Stoltz on 05/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation

extension AllRemindersViewController: AddReminderViewControllerDelegate {
    
    // MARK: Add/Edit Reminders
    
    func addReminderViewControllerDidCancel(controller: AddReminderViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func addReminderViewController(controller:AddReminderViewController,
                                   didFinishAddingReminder reminder: Reminder) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewController(controller:AddReminderViewController,
                                   didChooseToDeleteReminder reminder: Reminder) {
        deleteReminder(reminder)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewControllerDidFinishAdding(controller: AddReminderViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewController(controller: AddReminderViewController, didFinishEditingReminder reminder: Reminder) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
