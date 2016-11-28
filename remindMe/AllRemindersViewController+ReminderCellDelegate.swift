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
    
    func cellWasLongPressed(_ cell: ReminderCell, longPress: UILongPressGestureRecognizer) {
        print(#function)
        let indexPath = tableView.indexPath(for: cell)
        let reminder = coreDataHandler.reminderFromIndexPath(indexPath!)
        
        if longPress.state == .began && selectedReminders().count == 0 {
            print("Going to edit list")
            editingList = true
            tableView.allowsMultipleSelection = true
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            
            var favoriteText = ""
            let completeText = "Complete"
            if reminder.isFavorite == true {
                favoriteText = "Remove favorite"
            } else {
                favoriteText = "Favorite"
            }
            
            let favorite = UIBarButtonItem.init(title: favoriteText, style: .plain, target: self, action: #selector(toolbarFavorite))
            let delete = UIBarButtonItem.init(barButtonSystemItem: .trash, target: self, action: #selector(toolbarDelete))
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolbarItems = [favorite, spacer, delete]
            
            if reminder.wasCompleted == false {
                let complete = UIBarButtonItem.init(title: completeText, style: .plain, target: self, action: #selector(toolbarComplete))
                toolbarItems?.insert(complete, at: 0)
            }
 
            if toolbarIsHidden() {
                showToolbar()
            } else {
                hideToolbar()
            }
        }
    }
    
}
