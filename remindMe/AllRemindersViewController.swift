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

protocol AllRemindersViewControllerDelegate: class {
    func allRemindersViewControllerDelegateDidReceiveNotification (controller: AllRemindersViewController,
                                                                   reminder: Reminder)
}

class AllRemindersViewController: UIViewController, AddReminderViewControllerDelegate, ReminderCellDelegate, QuickViewViewControllerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Core Date
    
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
    var managedObjectContext: NSManagedObjectContext!
    
    // MARK: - Delegates
    
    weak var delegate: AllRemindersViewControllerDelegate?
    
    
    // MARK: - Properties
    
    var reminders = [Reminder]()
    var reminderFromNotification: Reminder? {
        didSet {
            print("\"All reminders\" has reminder \"\(reminderFromNotification!.name)\"", separator:"", terminator: "\n")
            delegate?.allRemindersViewControllerDelegateDidReceiveNotification(self, reminder: reminderFromNotification!)
        }
    }
    
    var list: List!
    
    var titleString = ""
    var nbOfReminders = 0
    
    var notificationHasGoneOff = false
    
    // MARK: - Delegate Methods
    
    // MARK: Quick View
    
    func quickViewViewControllerDidCancel(controller: QuickViewViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func quickViewViewControllerDidDelete(controller: QuickViewViewController, didDeleteReminder reminder: Reminder) {
        deleteReminder(reminder)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func quickViewViewControllerDidSnooze(controller: QuickViewViewController, didSnoozeReminder reminder: Reminder) {
        let reminderNotificationHandler = reminder.notificationHandler
        reminderNotificationHandler.scheduleNotifications(reminder, snooze: true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func quickViewViewControllerDidComplete(controller: QuickViewViewController, didCompleteReminder reminder: Reminder) {
        print("Going to complete reminder")
        if reminder.isComplete == false {
            reminder.isComplete = true
            let reminderReccurs = reminder.reminderIsRecurring()
            
            if reminderReccurs {
                let newDate = reminder.setNewDueDate()
                reminder.dueDate = newDate
                let reminderNotificationHandler = reminder.notificationHandler
                reminderNotificationHandler.scheduleNotifications(reminder)
            } else {
                let notificationHandler = reminder.notificationHandler
                notificationHandler.deleteReminderNotifications(reminder)
            }
        } else {
            reminder.isComplete = false
        }
        
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Add/Edit Reminders
    
    func addReminderViewControllerDidCancel(controller: AddReminderViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func addReminderViewController(controller:AddReminderViewController,
                                   didFinishAddingReminder reminder: Reminder) {
        setNumberOfReminders()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewController(controller:AddReminderViewController,
                                   didChooseToDeleteReminder reminder: Reminder) {
        deleteReminder(reminder)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewController(controller: AddReminderViewController,
                                   didFinishEditingReminder reminder: Reminder) {
        
        dismissViewControllerAnimated(true, completion: nil)
        
        print("The reminder will go off: \(reminder.dueDate)")
        if reminder.isRecurring == true {
            print("The reminder will go off again: \(reminder.nextDueDate)")
        }
        
        let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications!
        
        for notification in allNotifications {
            print(notification)
        }
        
        if allNotifications.count == 0 {
            print("There are no more notifications")
        }
        
        setNumberOfReminders()
    }
    
    // MARK: - Methods
    
    // MARK: Init & Deinit
    
    required init?(coder aDecoder: NSCoder) {
        reminders = [Reminder]()
        super.init(coder: aDecoder)
    }
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()
        
        // The Nib
        let cellNib = UINib(nibName: "ReminderCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "ReminderCell")
        tableView.rowHeight = 200
        setNumberOfReminders()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(completeReminder), name: "completeReminder", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(deferReminder), name: "deferReminder", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(viewReminder), name: "viewReminder", object: nil)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        setNumberOfReminders()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Add Reminder
        if segue.identifier == "AddReminder" {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! AddReminderViewController
            
            
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext
            controller.list = list
            
            // Edit Reminder
        } else if segue.identifier == "EditReminder" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! AddReminderViewController
            
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                let reminder = fetchedResultsController.objectAtIndexPath(indexPath) as! Reminder
                controller.reminderToEdit = reminder
            }
        } else if segue.identifier == "QuickView" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! QuickViewViewController
            controller.delegate = self
            
            // Make Quick View a delegate of All Reminders
            delegate = controller
            
            if let reminder = sender as? Reminder {
                controller.incomingReminder = reminder
                controller.managedObjectContext = managedObjectContext
                controller.notificationHasGoneOff = notificationHasGoneOff
            } else {
                
                if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                    let reminder = fetchedResultsController.objectAtIndexPath(indexPath) as! Reminder
                    controller.incomingReminder = reminder
                    controller.managedObjectContext = managedObjectContext
                }
            }
            
        }
        
    }
    
    func setNumberOfReminders() {
        
        nbOfReminders = tableView.numberOfRowsInSection(0)
        
        if nbOfReminders > 1 || nbOfReminders == 0 {
            titleString = "You have \(nbOfReminders) reminders"
        } else {
            titleString = "You have \(nbOfReminders) reminder"
        }
        self.title = titleString
        
    }
    
    func completeButtonWasPressed(cell: ReminderCell) {
        let indexPath = tableView.indexPathForCell(cell)
        let reminder = fetchedResultsController.objectAtIndexPath(indexPath!) as! Reminder
        if reminder.isComplete == false {
            reminder.isComplete = true
        } else {
            reminder.isComplete = false 
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        print(reminder.isComplete)
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
    
    // MARK: Reminder Actions
    
    func completeReminder() {
        if let reminder = reminderFromNotification {
            reminder.complete()
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }

    }
    
    func deferReminder() {
        if let reminder = reminderFromNotification {
            reminder.snooze()
        }
    }
    
    func viewReminder() {
        let reminderNotificationHandler = reminderFromNotification?.notificationHandler
        reminderNotificationHandler?.deleteReminderNotifications(reminderFromNotification!)
        notificationHasGoneOff = true
        
        performSegueWithIdentifier("QuickView", sender: reminderFromNotification)
        
    }

    func deleteReminder(reminder: Reminder) {
        if fetchedResultsController.indexPathForObject(reminder) != nil {
            let indexPath = fetchedResultsController.indexPathForObject(reminder)
            let reminderToDelete = fetchedResultsController.objectAtIndexPath(indexPath!) as! Reminder
            
            let reminderNotificationHandler = reminder.notificationHandler
            reminderNotificationHandler.deleteReminderNotifications(reminder)
            
            managedObjectContext.deleteObject(reminderToDelete)
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
            
            setNumberOfReminders()
        }
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
        
        // Make this view controller the delegate of ReminderCell
        cell.delegate = self
        
        return cell
    }
    
}

extension AllRemindersViewController: UITableViewDelegate {
    // MARK: - Selection
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // performSegueWithIdentifier("EditReminder", sender: tableView.cellForRowAtIndexPath(indexPath))
        performSegueWithIdentifier("QuickView", sender: tableView.cellForRowAtIndexPath(indexPath))
        print("Index Path: \(indexPath)")
        
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {

        return indexPath
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let reminder = fetchedResultsController.objectAtIndexPath(indexPath) as! Reminder
        
        let reminderNotificationHandler = reminder.notificationHandler
        reminderNotificationHandler.deleteReminderNotifications(reminder)
        
        managedObjectContext.deleteObject(reminder)

        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        setNumberOfReminders()
    }
    
}

extension AllRemindersViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
        setNumberOfReminders()
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
        setNumberOfReminders()
        
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
        setNumberOfReminders()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("*** controllerDidChangeContent")
        setNumberOfReminders()
        tableView.endUpdates()
    }
}

