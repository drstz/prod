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
    
    func toolbarFavorite() {
        print(#function)
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
                
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                if reminder.isFavorite == false {
                    reminder.setFavorite(true)
                } else {
                    reminder.setFavorite(false)
                }
            }
        }
        coreDataHandler.save()
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
}
