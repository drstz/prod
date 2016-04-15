//
//  ViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 11/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class AllRemindersViewController: UIViewController, AddReminderViewControllerDelegate {
    
    // MARK: - Instance Variables
    
    var reminders = [Reminder]()
    
    // MARK: fetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
       
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName("Reminder", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            
            // This is kept even after the app quits to keep it fast
            cacheName: "Reminder")
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    // Core Data
    
    var managedObjectContext: NSManagedObjectContext!
 
    required init?(coder aDecoder: NSCoder) {
        reminders = [Reminder]()
        super.init(coder: aDecoder)
    }
    
    // MARK: - Properties
    
    var nothingDue = false
    
    var titleString = ""
    var nbOfReminders = 0
    
    // MARK: - Deinit
    
    deinit {
        fetchedResultsController.delegate = nil
    }


    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Navigation
    
    func setNumberOfReminders() {
        nbOfReminders = reminders.count
        if nbOfReminders > 1 || nbOfReminders == 0 {
            titleString = "You have \(nbOfReminders) reminders"
        } else {
            titleString = "You have \(nbOfReminders) reminder"
        }
        self.title = titleString
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddReminder" {
            
            // The segue first goes to the navigation controller that the new view controller is embeded in
            let navigationController = segue.destinationViewController as! UINavigationController
            
            // To find the view controller, you look in the navigation controller topViewController property. This is the screen that is active in this navigation controller
            let controller = navigationController.topViewController as! AddReminderViewController
            
            // You now have the view controller that you want and you want to access its delegate property, setting it to this pages viewController(self)
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext 
            
        } else if segue.identifier == "EditReminder" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! AddReminderViewController
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                let reminder = fetchedResultsController.objectAtIndexPath(indexPath) as! Reminder
                controller.reminderToEdit = reminder
            }
        }
    }
    
    // MARK: - AddReminderDelegate
    
    func addReminderViewControllerDidCancel(controller: AddReminderViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewController(controller: AddReminderViewController,
                                   didFinishAddingReminder reminder: Reminder) {
        let newRowIndex = reminders.count
        
        reminders.append(reminder)
        
        let indexPath = NSIndexPath(forRow: newRowIndex, inSection: 0)
        let indexPaths = [indexPath]
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    
    func addReminderViewController(controller: AddReminderViewController,
                                   didFinishEditingReminder reminder: Reminder,
                                   anIndex: Int?) {
        if let index = anIndex {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as! ReminderCell? {
                cell.configureForReminder(reminder)
                
                
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    
    
    // MARK: - REMINDERS
    

    // MARK: Reminder list
    
    func updateList() {        
        tableView.reloadData()
    }
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    
    // MARK: - The view

    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()
        
        // updateList()
        
        // The Nib
        let cellNib = UINib(nibName: "ReminderCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "ReminderCell")
        tableView.rowHeight = 200
        setNumberOfReminders()
        


    }
    
    override func viewWillAppear(animated: Bool) {
        // self.navigationController?.navigationBar.topItem?.title =
        setNumberOfReminders()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

// MARK: - Extensions

extension AllRemindersViewController: UITableViewDataSource {
    func tableView(tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath) as! ReminderCell

        let reminder = fetchedResultsController.objectAtIndexPath(indexPath) as! Reminder
        cell.configureForReminder(reminder)
    
        return cell
    }
    
}

extension AllRemindersViewController: UITableViewDelegate {
    // MARK: - Selection
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("EditReminder", sender: indexPath)
        print("Index Path: \(indexPath)")
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if reminders.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        reminders.removeAtIndex(indexPath.row)
        
        let indexPaths = [indexPath]
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        setNumberOfReminders()
        
    }
    
}

extension AllRemindersViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print(#function)
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                    atIndexPath indexPath: NSIndexPath?,
                    forChangeType type: NSFetchedResultsChangeType,
                    newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        case .Delete:
            print("*** NSFethedResultsChangeDelete (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            print("*** NSFetchedResultsChangeUpdate (object")
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? ReminderCell {
                let reminder = controller.objectAtIndexPath(indexPath!) as! Reminder
                cell.configureForReminder(reminder)
            }
            
        case .Move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                    atIndex sectionIndex: Int,
                    forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        case .Delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
        case .Update:
            print("*** NSFetchedResultsChangeUpdate (section)")
            
        case .Move:
            print("*** NSFetchedResultsChangeMove (section)")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}

