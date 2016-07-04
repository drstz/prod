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
    
    var sentMessage = "I came from nowhere"

    // MARK: - Delegates
    
    weak var delegate: AllRemindersViewControllerDelegate?
    
    // MARK: - Properties
    
    var reminders = [Reminder]()
    var reminderFromNotification: Reminder? {
        didSet {
            print("Tab \(tabBarController?.selectedIndex) has reminder \"\(reminderFromNotification!.name)")
            print("")
            delegate?.allRemindersViewControllerDelegateDidReceiveNotification(self, reminder: reminderFromNotification!)
        }
    }
    
    var list: List!
    
    var titleString = ""
    var nbOfReminders = 0
    
    var notificationHasGoneOff = false
    
    var showingCompleteReminders = false
    
    var upcomingTabNumber: Int?
    
    // MARK: - IBActions
    
    @IBAction func changeSegment() {
        print("")
        print(#function)
        
        setUpCoreData()
        loadCell()
        tableView.reloadData()
        clearSelectedIndexPaths()
    }
    
    @IBAction func doneSettings(segue: UIStoryboardSegue) {
        
    }

    // MARK: - Delegate Methods
    
    // MARK: TabBar
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        print("")
        print(#function)
        let selectedIndex = myTabBarController.selectedIndex
        print("Selected tab is \(selectedIndex).")
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        print("")
        print(#function)
        let selectedIndex = myTabBarController.selectedIndex
        print("Selected tab is \(selectedIndex).")
        
        let navigationController = viewController as! UINavigationController
        let viewControllers = navigationController.viewControllers
        let allRemindersViewController = viewControllers[0] as! AllRemindersViewController
        
        let selectedViewControllerTab = allRemindersViewController.tabBarController?.selectedIndex
        let selectedViewControllerTag = allRemindersViewController.tabBarController?.tabBar.selectedItem?.tag
        
        
        allRemindersViewController.sentMessage = "I came from tab \(selectedIndex)"
        
        allRemindersViewController.managedObjectContext = managedObjectContext
        allRemindersViewController.list = list
        tabBarController.delegate = allRemindersViewController
        allRemindersViewController.myTabBarController = tabBarController
        
        print("Selected view controller's tab is \(selectedViewControllerTab).")
        print("Selected view controller's tab  TAG is \(selectedViewControllerTag!).")

        return true
    }
    
    
    // MARK: Quick View
    
    func quickViewViewControllerDidCancel(controller: QuickViewViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func quickViewViewControllerDidDelete(controller: QuickViewViewController, didDeleteReminder reminder: Reminder) {
        deleteReminder(reminder)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func quickViewViewControllerDidSnooze(controller: QuickViewViewController, didSnoozeReminder reminder: Reminder) {
        reminder.snooze()
        coreDataHandler.save()
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
    }
    
    // Cell
    
    func cellWasLongPressed(cell: ReminderCell, longPress: UILongPressGestureRecognizer) {
        let indexPath = tableView.indexPathForCell(cell)
        
        if longPress.state == .Began {
            tableView.allowsMultipleSelection = true
            tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
   
            let completeText = "Complete"
            let favoriteText = "Favorite"

            let complete = UIBarButtonItem.init(title: completeText, style: .Plain, target: self, action: #selector(toolbarComplete))
            let favorite = UIBarButtonItem.init(title: favoriteText, style: .Plain, target: self, action: #selector(toolbarFavorite))
            let delete = UIBarButtonItem.init(title: "Delete", style: .Plain, target: self, action: #selector(toolbarDelete))
            let spacer = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
            toolbarItems = [complete, spacer, delete, spacer, favorite]
            
            if navigationController?.toolbarHidden == true {
                navigationController?.setToolbarHidden(false, animated: true)
            } else {
                navigationController?.setToolbarHidden(true, animated: true)
            }
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
        print("All Reminders was deallocated")
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        print(#function)
        super.viewDidLoad()
    
        tableView.separatorColor = UIColor.clearColor()
        
        let selectedIndex = myTabBarController.selectedIndex
        print("Selected tab is \(selectedIndex).")
//        setUpCoreData()
//        loadCell()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(completeReminder), name: "completeReminder", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(deferReminder), name: "deferReminder", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(viewReminder), name: "viewReminder", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        print(#function)
        super.viewWillAppear(animated)
        
        setUpCoreData()
        loadCell()
        
        let selectedIndex = myTabBarController.selectedIndex
        print("Selected tab is \(selectedIndex).")
    }
    
    override func viewDidAppear(animated: Bool) {
        print("")
        print(#function)
        super.viewDidAppear(animated)
    
        setUpCoreData()
        loadCell()
        
        let selectedIndex = myTabBarController.selectedIndex
        print("Selected tab is \(selectedIndex).")
        print("Here comes the sent message: \(sentMessage)")
        
        saveSelectedTab(selectedIndex)
        print("")
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        print(#function)
        super.viewWillDisappear(animated)
        
        clearSelectedIndexPaths()
        let selectedIndex = myTabBarController.selectedIndex
        print("Selected tab is \(selectedIndex).")
        print("")
    }
    
    func clearSelectedIndexPaths() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
        }
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadCell() {
        print(#function)
        let cellNib = UINib(nibName: "ReminderCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "ReminderCell")
        tableView.rowHeight = 100
    }
    
    func setUpCoreData() {
        print(#function)
        
        coreDataHandler.setObjectContext(managedObjectContext)
        
        let selectedIndex = myTabBarController.selectedIndex
        let segment = segmentedControl.selectedSegmentIndex
        var status: ReminderStatus = .Complete
        var filter: ReminderFilter = .All
        
        if segment == 0 {
            status = .Incomplete
            // print("Status for reminders is set to incomplete")
        } else {
            status = .Complete
            // print("Status for reminders is set to complete")
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
    
    // MARK: Toolbar Actions
    
    func toolbarComplete() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                reminder.complete()
            }
        }
        
        coreDataHandler.save()
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func toolbarDelete() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
                deleteReminder(reminder, save: false)
            }
        }
        
        coreDataHandler.save()
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func toolbarFavorite() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
                
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                if reminder.isFavorite == false {
                    reminder.setFavorite(true)
                } else {
                    reminder.setFavorite(false)
                }
            }
        }
        coreDataHandler.save()
        navigationController?.setToolbarHidden(true, animated: true)
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
                // When coming from notification
                controller.incomingReminder = reminder
                controller.managedObjectContext = managedObjectContext
                controller.notificationHasGoneOff = notificationHasGoneOff
            } else {
                // When coming from list
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
        
    func completeButtonWasPressed(cell: ReminderCell) {
        let indexPath = tableView.indexPathForCell(cell)
        let reminder = coreDataHandler.reminderFromIndexPath(indexPath!)
        reminder.complete()
        
        coreDataHandler.save()
    }
    
    // MARK: - REMINDERS
    
    // MARK: Reminder list
    
    func updateList() {        
        tableView.reloadData()
    }
    
    // MARK: Reminder Actions
    
    

    func deleteReminder(reminder: Reminder, save: Bool = true) {
        print(#function)
        if coreDataHandler.fetchedResultsController.indexPathForObject(reminder) != nil {
            let reminderNotificationHandler = reminder.notificationHandler
            reminderNotificationHandler.deleteReminderNotifications(reminder)
            
            coreDataHandler.delete(reminder)
            if save {
                coreDataHandler.save()
            }
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

extension AllRemindersViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
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
                let reminder = coreDataHandler.reminderFromIndexPath(indexPath!)
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

