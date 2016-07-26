//
//  AllRemindersViewController+ToolbarActions.swift
//  remindMe
//
//  Created by Duane Stoltz on 04/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation

extension AllRemindersViewController {
    // MARK: Toolbar Actions
    
    func toolbarComplete() {
        print(#function)
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                reminder.complete()
            }
        }
        
        coreDataHandler.save()
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func toolbarDelete() {
        print(#function)
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
                deleteReminder(reminder, save: false)
            }
        }
        
        coreDataHandler.save()
        navigationController?.setToolbarHidden(true, animated: true)
    }
        
    func selectionHasFavorite(selectedReminders: [Reminder]) -> Bool {
        for reminder in selectedReminders {
            if reminder.isFavorite == true {
                return true
            }
        }
        return false
    }
    
    func selectionIsMixed(selectedReminders: [Reminder]) -> Bool {
        var isFavorite: Bool?
        for reminder in selectedReminders {
            if isFavorite == nil {
                isFavorite = reminder.isFavorite as? Bool
            } else {
                if reminder.isFavorite != isFavorite {
                    return true
                }
            }
        }
        return false
    }
    
    func selectedReminders() -> [Reminder] {
        var reminders = [Reminder]()
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
                reminders.append(reminder)
            }
        }
        return reminders
    }
    
    func toolbarFavorite() {
        let reminders = selectedReminders()
        if selectionHasFavorite(reminders) && selectionIsMixed(reminders) {
            for reminder in reminders {
                reminder.setFavorite(true)
            }
        } else {
            for reminder in reminders {
                if reminder.isFavorite == false {
                    reminder.setFavorite(true)
                } else {
                    reminder.setFavorite(false)
                }
            }
        }
        
        coreDataHandler.save()
        deselectRows()
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func deselectRows() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
}
