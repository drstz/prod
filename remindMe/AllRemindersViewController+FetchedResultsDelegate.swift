//
//  AllRemindersViewController+FetchedResultsDelegate.swift
//  remindMe
//
//  Created by Duane Stoltz on 04/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import CoreData

extension AllRemindersViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print(#function)
       
        tableView.beginUpdates()
         print("Number of rows in section 0 : \(tableView.numberOfRows(inSection: 0))")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
            
        case .delete:
            print("*** NSFethedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(at: indexPath!) as? ReminderCell {
                print("Cell: \(cell.reminderLabel.text) at row \(indexPath?.row) in section \(indexPath?.section)")
                
                
                // This used to use indexPath instead of newIndexPath
                // When set to indexPath, completing multiple reminders including a repeating one created error: no object at index path
                let reminder = coreDataHandler.reminderFromIndexPath(newIndexPath!)
                
//                for object in controller.fetchedObjects! {
//                    let indexPath = controller.indexPath(forObject: object)
//                    print(object.description)
//                    print("Row: \(indexPath?.row). Section: \(indexPath?.section)")
//                }
        
                cell.configureForReminder(reminder)
            }
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        print(#function)
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
            
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print(#function)
        print("*** controllerDidChangeContent")
        
        
        
        tableView.endUpdates()
        print("Number of rows in section 0 : \(tableView.numberOfRows(inSection: 0))")
        setNoReminderView()
        setBadgeForTodayTab()
    }
}
