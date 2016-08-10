//
//  AllRemindersViewController+TableView.swift
//  remindMe
//
//  Created by Duane Stoltz on 04/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension AllRemindersViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (coreDataHandler.fetchedResultsController.sections?.count)! 
    }
    
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        print(#function)
        let sectionInfo = coreDataHandler.fetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
        let text = sectionInfo[section].name
        
        // Dequeue with the reuse identifier
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("TableSectionHeader")
        let header = view as! TableSectionHeader
        
        header.titleLabel.text = text
        
        // header.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        
        return view
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        print(#function)
        let sectionInfo = coreDataHandler.fetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
        let text = sectionInfo[section].name
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("TableSectionHeader")
        let header = view as! TableSectionHeader
        
        header.titleLabel.text = text
        header.titleLabel.backgroundColor = UIColor(red: 40/255, green: 114/255, blue: 192/255, alpha: 1)
        
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = coreDataHandler.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath) as! ReminderCell
        let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
        
        cell.configureForReminder(reminder)
        cell.delegate = self
        print(reminder.creationDate)
        return cell
    }
    
}

extension AllRemindersViewController: UITableViewDelegate {
    // MARK: - Selection
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(#function)
        if navigationController?.toolbarHidden == true {
  
            // This is a bug in iOS maybe. For some reason this doesn't happen on the main thread
            // Should find where UI code is not on main thread for some reason or what causes a delay
            // but no crash
            
            dispatch_async(dispatch_get_main_queue(),{
               self.performSegueWithIdentifier("Popup",sender: tableView.cellForRowAtIndexPath(indexPath))
            })
            
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        print(#function)
        let selectedIndexPathsCount = tableView.indexPathsForSelectedRows?.count
        print("There are \(selectedIndexPathsCount) selected rows")
        if selectedIndexPathsCount == nil {
            navigationController?.setToolbarHidden(true, animated: true)
            refreshTableView()
        }
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
            let alert = UIAlertController(title: "Delete \"\(reminder.name)\" ?", message: "You cannot undo this", preferredStyle: .Alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {
                action in
                let reminderNotificationHandler = reminder.notificationHandler
                reminderNotificationHandler.deleteReminderNotifications(reminder)
                
                self.coreDataHandler.delete(reminder)
                self.coreDataHandler.save()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
}
