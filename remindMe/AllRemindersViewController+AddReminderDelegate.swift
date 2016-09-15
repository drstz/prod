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
    
    func addReminderViewControllerDidCancel(_ controller: AddReminderViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func addReminderViewController(_ controller:AddReminderViewController,
                                   didFinishAddingReminder reminder: Reminder) {
        dismiss(animated: true, completion: nil)
    }
    
    func addReminderViewController(_ controller:AddReminderViewController,
                                   didChooseToDeleteReminder reminder: Reminder) {
        deleteReminder(reminder)
        dismiss(animated: true, completion: nil)
    }
    
    func addReminderViewControllerDidFinishAdding(_ controller: AddReminderViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addReminderViewController(_ controller: AddReminderViewController, didFinishEditingReminder reminder: Reminder) {
        dismiss(animated: true, completion: nil)
    }
    
}
