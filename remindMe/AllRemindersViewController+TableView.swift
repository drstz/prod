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
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = coreDataHandler.fetchedResultsController.sections! as [NSFetchedResultsSectionInfo]
        return sectionInfo[section].name
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = coreDataHandler.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath) as! ReminderCell
        
        let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
        cell.configureForReminder(reminder)
        
        // Make this view controller the delegate of ReminderCell
        cell.delegate = self
        
        return cell
    }
    
}

extension AllRemindersViewController: UITableViewDelegate {
    // MARK: - Selection
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if navigationController?.toolbarHidden == true {
            performSegueWithIdentifier("QuickView", sender: tableView.cellForRowAtIndexPath(indexPath))
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        let selectedIndexPathsCount = tableView.indexPathsForSelectedRows?.count
        print("There are \(selectedIndexPathsCount) selected rows")
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedIndexPathsCount = tableView.indexPathsForSelectedRows?.count
        print("There are \(selectedIndexPathsCount) selected rows")
        if selectedIndexPathsCount == nil {
            navigationController?.setToolbarHidden(true, animated: true)
        }
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
        
        let reminderNotificationHandler = reminder.notificationHandler
        reminderNotificationHandler.deleteReminderNotifications(reminder)
        
        coreDataHandler.delete(reminder)
        coreDataHandler.save()
    }
    
}
