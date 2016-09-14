//
//  AllRemindersViewController+ToolbarActions.swift
//  remindMe
//
//  Created by Duane Stoltz on 04/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import UIKit

extension AllRemindersViewController {
    // MARK: Toolbar Actions
    
    func toolbarComplete() {
        let reminders = selectedReminders()
        for reminder in reminders {
           reminder.complete()
        }
        coreDataHandler.save()
        deselectRows()
        refreshTableView()
        hideToolbar()
    }
    
    func toolbarDelete() {
        var deleteActionTitle = ""

        let reminders = selectedReminders()
        if reminders.count > 1 {
            deleteActionTitle = "Delete \(reminders.count) reminders?"
        } else {
            deleteActionTitle = "Delete this reminder?"
        }
        
        let alert = UIAlertController(title: deleteActionTitle, message: "You cannot undo this", preferredStyle: .Alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {
            action in
            for reminder in reminders {
                self.deleteReminder(reminder, save: false)
            }
            self.coreDataHandler.save()
            self.deselectRows()
            self.refreshTableView()
            self.hideToolbar()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
        
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
        refreshTableView()
        hideToolbar()
    }
    
    // MARK: Selection and deselection
    
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
    
    func checkSelectionForFavorites() {
        selectionIsMixed = false
        var containsFavorite = false
        var containsUnFavorite = false
        var isComplete = false
        let reminders = selectedReminders()
        for reminder in reminders {
            if reminder.isFavorite == true {
                containsFavorite = true
                if containsUnFavorite {
                    selectionIsMixed = true
                } else {
                    selectionIsMixed = false
                }
            } else {
                containsUnFavorite = true
                if containsFavorite == true {
                    selectionIsMixed = true
                } else {
                    selectionIsMixed = false
                }
            }
            
            if reminder.wasCompleted == true {
                isComplete = true
            } else {
                isComplete = false
            }
        }
        print("Contains favorite = \(containsFavorite)")
        print("Is mixed = \(selectionIsMixed)")
        
        
        if selectionIsMixed || containsUnFavorite {
            if isComplete {
                let favoriteItem = toolbarItems![0]
                favoriteItem.title = "Favorite"
                toolbarItems![0] = favoriteItem
            } else {
                let favoriteItem = toolbarItems![1]
                favoriteItem.title = "Favorite"
                toolbarItems![1] = favoriteItem
            }
        } else if !selectionIsMixed && containsFavorite {
            if isComplete {
                let favoriteItem = toolbarItems![0]
                favoriteItem.title = "Remove favorite"
                toolbarItems![0] = favoriteItem
            } else {
                let favoriteItem = toolbarItems![1]
                favoriteItem.title = "Remove favorite"
                toolbarItems![1] = favoriteItem
            }
        }
    }
}
