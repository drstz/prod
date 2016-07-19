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
        let indexPath = tableView.indexPathForCell(cell)
        
        if longPress.state == .Began {
            tableView.allowsMultipleSelection = true
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
            
            let completeText = "Complete"
            let favoriteText = "Favorite"
            
            let complete = UIBarButtonItem.init(title: completeText, style: .Plain, target: self, action: #selector(toolbarComplete))
            let favorite = UIBarButtonItem.init(title: favoriteText, style: .Plain, target: self, action: #selector(toolbarFavorite))
            let delete = UIBarButtonItem.init(barButtonSystemItem: .Trash, target: self, action: #selector(toolbarDelete))
            let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            toolbarItems = [complete, favorite, spacer, delete]
            
            if navigationController?.toolbarHidden == true {
                navigationController?.setToolbarHidden(false, animated: true)
            } else {
                navigationController?.setToolbarHidden(true, animated: true)
                
            }
            
        }
    }
    
}
