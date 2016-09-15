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
    func numberOfSections(in tableView: UITableView) -> Int {
        return (coreDataHandler.fetchedResultsController!.sections?.count)! 
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        print(#function)
        let sectionInfo = (coreDataHandler.fetchedResultsController?.sections!)! as [NSFetchedResultsSectionInfo]
        let text = sectionInfo[section].name
        
        // Dequeue with the reuse identifier
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableSectionHeader")
        let header = view as! TableSectionHeader
        
        header.titleLabel.text = text
        
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        print(#function)
        let sectionInfo = (coreDataHandler.fetchedResultsController?.sections!)! as [NSFetchedResultsSectionInfo]
        let text = sectionInfo[section].name
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableSectionHeader")
        let header = view as! TableSectionHeader
        
        header.titleLabel.text = text
        header.titleLabel.backgroundColor = UIColor(red: 40/255, green: 114/255, blue: 192/255, alpha: 1)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = coreDataHandler.fetchedResultsController?.sections![section]
        return sectionInfo!.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath) as! ReminderCell
        let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
        
        cell.configureForReminder(reminder)
        cell.delegate = self
        print(reminder.creationDate)
        return cell
    }
    
}

extension AllRemindersViewController: UITableViewDelegate {
    // MARK: - Selection
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function)
        print("Number of selected reminders = \(selectedReminders().count)")
        if toolbarIsHidden() {
            // This is a bug in iOS maybe. For some reason this doesn't happen on the main thread
            // Should find where UI code is not on main thread for some reason or what causes a delay
            // but no crash
            DispatchQueue.main.async(execute: {
               self.performSegue(withIdentifier: "Popup",sender: tableView.cellForRow(at: indexPath))
            })
            
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            checkSelectionForFavorites()
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print(#function)
        print("Number of selected reminders = \(selectedReminders().count)")
        let selectedIndexPathsCount = tableView.indexPathsForSelectedRows?.count
        if selectedIndexPathsCount == nil {
            hideToolbar()
            refreshTableView()
        } else {
            checkSelectionForFavorites()
        }
        
    }
    
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:) func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
            let alert = UIAlertController(title: "Delete \"\(reminder.name)\" ?", message: "You cannot undo this", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
                action in
                let reminderNotificationHandler = reminder.notificationHandler
                reminderNotificationHandler.deleteReminderNotifications(reminder)
                
                self.coreDataHandler.delete(reminder)
                self.coreDataHandler.save()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
}
