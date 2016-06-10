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



class AllRemindersViewController: UIViewController, UITabBarControllerDelegate, AddReminderViewControllerDelegate, ReminderCellDelegate, QuickViewViewControllerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    // MARK: - Core Date
    
    let coreDataHandler = CoreDataHandler()
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController!
    
    var myTabBarController: UITabBarController!
    
    var selectedIndexPaths: [NSIndexPath] = [] {
        didSet {
            print("There are \(selectedIndexPaths.count) selected paths")
        }
    }
    var selectedReminders: [Reminder] = [] {
        didSet {
            print("There are \(selectedReminders.count) selected reminders")
        }
    }
    
    
    
    
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
    
    var showingCompleteReminders = false
    
    // MARK: - IBActions
    
    @IBAction func changeSegment() {
       
        setUpCoreData()
        loadCell()
        tableView.reloadData()
        setNumberOfReminders()
    
        
    }
    
    @IBAction func doneSettings(segue: UIStoryboardSegue) {
        
    }

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
        reminder.complete()
        coreDataHandler.save()
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
        
        setNumberOfReminders()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Cell
    
    func cellWasLongPressed(cell: ReminderCell, longPress: UILongPressGestureRecognizer) {
        
        let indexPath = tableView.indexPathForCell(cell)
        if !selectedIndexPaths.contains(indexPath!) {
            selectedIndexPaths.append(indexPath!)
        }
        
    
        if longPress.state == .Began {
            let reminder = coreDataHandler.reminderFromIndexPath(indexPath!)
            
            addReminders(selectedIndexPaths)

            cell.wasSelected = true
            cell.configureColor(reminder)
            
            let completeText = "Complete"
            let favoriteText = "Favorite"

            
            
            
            let complete = UIBarButtonItem.init(title: completeText, style: .Plain, target: self, action: #selector(tBarCompleteThisReminder))
            let favorite = UIBarButtonItem.init(title: favoriteText, style: .Plain, target: self, action: #selector(tBarFavThisReminder))
            let delete = UIBarButtonItem.init(title: "Delete", style: .Plain, target: self, action: #selector(tBarDeleteThisReminder))
            let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            toolbarItems = [complete, spacer, delete, spacer, favorite]
            
            if navigationController?.toolbarHidden == true {
                navigationController?.setToolbarHidden(false, animated: true)
                navigationController?.setNavigationBarHidden(true, animated: true)
            } else {
                navigationController?.setToolbarHidden(true, animated: true)
                navigationController?.setNavigationBarHidden(false, animated: true)
            }
        }
    }
    
    func addReminders(indexpaths: [NSIndexPath]) {
        for indexPath in indexpaths {
            let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
            selectedReminders.append(reminder)
        }
        
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
        print(#function)
        print("--------------------")
        print("")
        super.viewDidLoad()
        
        setUpCoreData()
        loadCell()
        setNumberOfReminders()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(completeReminder), name: "completeReminder", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(deferReminder), name: "deferReminder", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(viewReminder), name: "viewReminder", object: nil)
    }
    
    func tBarCompleteThisReminder() {
        for reminder in selectedReminders {
            reminder.complete()
            
            for index in selectedIndexPaths {
                let cell = tableView.cellForRowAtIndexPath(index) as! ReminderCell
                cell.wasSelected = false
                cell.configureColor(reminder)
            }
        }
        
        selectedIndexPaths.removeAll()
        selectedReminders.removeAll()
        
        coreDataHandler.save()

        navigationController?.setToolbarHidden(true, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    func tBarDeleteThisReminder() {
        for reminder in selectedReminders {
            deleteReminder(reminder)
            
            for index in selectedIndexPaths {
                let cell = tableView.cellForRowAtIndexPath(index) as! ReminderCell
                cell.wasSelected = false
                cell.configureColor(reminder)
            }
        }
        
        selectedIndexPaths.removeAll()
        selectedReminders.removeAll()
        
        coreDataHandler.save()
        
        navigationController?.setToolbarHidden(true, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    func tBarFavThisReminder() {
        for reminder in selectedReminders {
            if reminder.isFavorite == false {
                reminder.setFavorite(true)
            } else {
                reminder.setFavorite(false)
            }
            
            for index in selectedIndexPaths {
                let cell = tableView.cellForRowAtIndexPath(index) as! ReminderCell
                cell.wasSelected = false
                cell.configureColor(reminder)
            }
        }
        selectedIndexPaths.removeAll()
        selectedReminders.removeAll()
        
        
        
        coreDataHandler.save()
        
        
        navigationController?.setToolbarHidden(true, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    
    override func viewDidAppear(animated: Bool) {
        print("--------------------")
        super.viewDidAppear(animated)
        print(#function)
        
        setUpCoreData()
        loadCell()
        setNumberOfReminders()
        
    
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadCell() {
        let cellNib = UINib(nibName: "ReminderCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "ReminderCell")
        tableView.rowHeight = 100
    }
    
    func setUpCoreData() {
        coreDataHandler.setObjectContext(managedObjectContext)
        
        let selectedIndex = myTabBarController.selectedIndex
        let segment = segmentedControl.selectedSegmentIndex
        var status: ReminderStatus = .Complete
        var filter: ReminderFilter = .All
        
        if segment == 0 {
            status = .Incomplete
            print("Status for reminders is set to incomplete")
        } else {
            status = .Complete
            print("Status for reminders is set to complete")
        }
       
        switch selectedIndex {
        case 0:
            filter = .Today
            coreDataHandler.setFetchedResultsController("Reminder", cacheName: "TodayReminders", filterBy: filter, status: status)
        case 1:
            filter = .Week
            coreDataHandler.setFetchedResultsController("Reminder", cacheName: "WeekReminders", filterBy: filter, status: status)
        case 2:
            filter = .All
            coreDataHandler.setFetchedResultsController("Reminder", cacheName: "AllReminders", filterBy: filter, status: status)
        case 3:
            filter = .Favorite
            coreDataHandler.setFetchedResultsController("Reminder", cacheName: "FavoriteReminders", filterBy: filter, status: status)
        default:
            filter = .All
            coreDataHandler.setFetchedResultsController("Reminder", cacheName: "AllReminders", filterBy: filter, status: status)
        }
        
        coreDataHandler.fetchedResultsController.delegate = self
        coreDataHandler.performFetch()
        
    }
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let segueIdentifier = segue.identifier!
        let navigationController = segue.destinationViewController as! UINavigationController
        
        switch segueIdentifier {
            
        case "AddReminder":
            let controller = navigationController.topViewController as! AddReminderViewController
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext
            controller.list = list
        case "EditReminder":
            let controller = navigationController.topViewController as! AddReminderViewController
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
                controller.reminderToEdit = reminder
            }
            
        case "QuickView":
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
                    let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
                    controller.incomingReminder = reminder
                    controller.managedObjectContext = managedObjectContext
                }
            }
            
        default:
            break
            
        }
    }
    
    func setNumberOfReminders() {
        
//        nbOfReminders = tableView.numberOfRowsInSection(0)
//        
//        if nbOfReminders > 1 || nbOfReminders == 0 {
//            titleString = "You have \(nbOfReminders) reminders"
//        } else {
//            titleString = "You have \(nbOfReminders) reminder"
//        }
//        self.title = titleString
        
    }
        
    func completeButtonWasPressed(cell: ReminderCell) {
        let indexPath = tableView.indexPathForCell(cell)
        let reminder = coreDataHandler.reminderFromIndexPath(indexPath!)
        reminder.complete()
        
        coreDataHandler.save()
        setNumberOfReminders()
    }
    
    // MARK: - REMINDERS
    
    // MARK: Reminder list
    
    func updateList() {        
        tableView.reloadData()
    }
    
    // MARK: Reminder Actions
    
    func completeReminder() {
        if let reminder = reminderFromNotification {
            reminder.complete()
        }
        
        coreDataHandler.save()
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
        if coreDataHandler.fetchedResultsController.indexPathForObject(reminder) != nil {
            let indexPath = coreDataHandler.fetchedResultsController.indexPathForObject(reminder)
            let reminderToDelete = coreDataHandler.reminderFromIndexPath(indexPath!)
            
            let reminderNotificationHandler = reminder.notificationHandler
            reminderNotificationHandler.deleteReminderNotifications(reminder)
            
            coreDataHandler.delete(reminderToDelete)
            coreDataHandler.save()
            
            setNumberOfReminders()
        }
    }
}

// MARK: - Extensions

extension AllRemindersViewController: UITableViewDataSource {
    func tableView(tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        
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
        let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if navigationController?.toolbarHidden == true {
            performSegueWithIdentifier("QuickView", sender: tableView.cellForRowAtIndexPath(indexPath))
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            print("There are \(selectedIndexPaths.count) indexPaths")
            if selectedIndexPaths.contains(indexPath) {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! ReminderCell
                cell.wasSelected = true
                cell.backgroundColor = UIColor(red: 174/255, green: 198/255, blue: 207/255, alpha: 1)
                let position = selectedIndexPaths.indexOf(indexPath)
                selectedIndexPaths.removeAtIndex(position!)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
                let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
                
                if selectedReminders.contains(reminder) {
                    let position = selectedReminders.indexOf(reminder)
                    selectedReminders.removeAtIndex(position!)
                }
                if selectedIndexPaths.count == 0 {
                    navigationController?.setToolbarHidden(true, animated: true)
                    navigationController?.setNavigationBarHidden(false, animated: true)
                }
            } else {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! ReminderCell
                cell.backgroundColor = UIColor(red: 69/255, green: 61/255, blue: 85/255, alpha: 1)
                cell.wasSelected = true
                cell.configureColor(reminder)
                selectedIndexPaths.append(indexPath)
                
                let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
                selectedReminders.append(reminder)
                
            }
        }
        
        
    
        
    }
    
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return indexPath
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
        
        let reminderNotificationHandler = reminder.notificationHandler
        reminderNotificationHandler.deleteReminderNotifications(reminder)
        
        coreDataHandler.delete(reminder)
        coreDataHandler.save()
        
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
                let reminder = coreDataHandler.reminderFromIndexPath(indexPath!)
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

