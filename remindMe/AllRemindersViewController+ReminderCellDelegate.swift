//
//  AllRemindersViewController+ReminderCellDelegate.swift
//  remindMe
//
//  Created by Duane Stoltz on 05/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import UIKit

extension AllRemindersViewController: ReminderCellDelegate {
    
    
    
    // MARK: Cell
    
    func cellWasLongPressed(cell: ReminderCell, longPress: UILongPressGestureRecognizer) {
        print(#function)
        let indexPath = tableView.indexPathForCell(cell)
        let reminder = coreDataHandler.reminderFromIndexPath(indexPath!)
        
        if longPress.state == .Began && selectedReminders().count == 0 {
            editingList = true
            tableView.allowsMultipleSelection = true
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
            
            
            var favoriteText = ""
            let completeText = "Complete"
            if reminder.isFavorite == true {
                favoriteText = "Remove favorite"
            } else {
                favoriteText = "Favorite"
            }
            
            
            //let complete = UIBarButtonItem.init(title: completeText, style: .Plain, target: self, action: #selector(toolbarComplete))
            let favorite = UIBarButtonItem.init(title: favoriteText, style: .Plain, target: self, action: #selector(toolbarFavorite))
            let delete = UIBarButtonItem.init(barButtonSystemItem: .Trash, target: self, action: #selector(toolbarDelete))
            let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            toolbarItems = [favorite, spacer, delete]
            
            if reminder.isComplete == false {
                let complete = UIBarButtonItem.init(title: completeText, style: .Plain, target: self, action: #selector(toolbarComplete))
                toolbarItems?.insert(complete, atIndex: 0)
    
            }
            
            
            
            
            
            if toolbarIsHidden() {
                showToolbar()
            } else {
                hideToolbar()
            }
        }
    }
    
}
