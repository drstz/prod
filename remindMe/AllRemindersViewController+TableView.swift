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
        print(#function)
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
        print(#function)
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
        
        return cell
    }
    
}

extension AllRemindersViewController: UITableViewDelegate {
    // MARK: - Selection
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if navigationController?.toolbarHidden == true {
            //performSegueWithIdentifier("QuickView", sender: tableView.cellForRowAtIndexPath(indexPath))
            performSegueWithIdentifier("Popup", sender: tableView.cellForRowAtIndexPath(indexPath))
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
