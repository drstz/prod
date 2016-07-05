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
    
    @IBOutlet weak var noReminderScreen: UIView!
    
    @IBOutlet weak var noReminderLabel: UILabel!
    
    // MARK: - Coredata
    
    let coreDataHandler = CoreDataHandler()
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController!
    
    // MARK: - Tabbar
    
    var myTabBarController: UITabBarController!
    var myTabIndex = 0
    
    // MARK: - Segment
    
    var selectedSegment = 0
    
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
    
    var sentMessage = "I came from nowhere"
    
    // MARK: - IBActions
    
    @IBAction func changeSegment() {
        print("")
        print(#function)
        
        setUpCoreData()
        loadCell()
        tableView.reloadData()
        clearSelectedIndexPaths()
        selectedSegment = segmentedControl.selectedSegmentIndex
        
        numberOfRemindersInSection()
        
        setNoReminderView()
        
        let selectedIndex = myTabBarController.selectedIndex
        print("Current tab is \(selectedIndex).")
        print("I want to be tab \(myTabIndex).")
    }
    
    @IBAction func doneSettings(segue: UIStoryboardSegue) {
        
    }

    // MARK: - Delegate Methods
    
    // MARK: TabBar

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        print("")
        
        print("___________________")
        print(#function)
        let selectedIndex = myTabBarController.selectedIndex
        
        
        let navigationController = viewController as! UINavigationController
        let viewControllers = navigationController.viewControllers
        let allRemindersViewController = viewControllers[0] as! AllRemindersViewController
        
        let selectedViewControllerTab = allRemindersViewController.tabBarController?.selectedIndex
        
        
        
        let selectedViewControllerTag = allRemindersViewController.tabBarController?.tabBar.selectedItem?.tag
        print("CHANGING TAB \(selectedIndex) ---> \(selectedViewControllerTag!) ")
        print("Segment is \(segmentedControl.selectedSegmentIndex)")
        
        
        let messageToSend = "I came from tab \(selectedIndex)"
        allRemindersViewController.sentMessage = messageToSend
    
        
        allRemindersViewController.managedObjectContext = managedObjectContext
        allRemindersViewController.list = list
        tabBarController.delegate = allRemindersViewController
        allRemindersViewController.myTabBarController = tabBarController
        
        allRemindersViewController.selectedSegment = selectedSegment
        
        allRemindersViewController.myTabIndex = selectedViewControllerTag!
        
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        print("")
        print("")
        print("")
        print("___________________")
        print(#function)
        print("Here comes the recieved message: \(sentMessage)")
        let selectedIndex = myTabBarController.selectedIndex
        print("Current tab is \(selectedIndex).")
        print("I want to be tab \(myTabIndex).")
        print("Segment is \(segmentedControl.selectedSegmentIndex)")
        
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
        print("")
        print("___________________")
        print(#function)
        super.viewDidLoad()
    
        tableView.separatorColor = UIColor.clearColor()
        
        let selectedIndex = myTabBarController.selectedIndex
        print("Current tab is \(selectedIndex).")
        print("I want to be tab \(myTabIndex).")
        print("Segment is \(segmentedControl.selectedSegmentIndex)")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(completeReminder), name: "completeReminder", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(deferReminder), name: "deferReminder", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(viewReminder), name: "viewReminder", object: nil)
        
        print(#function)
        print("___________________")
        print("")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        print("")
        print("___________________")
        print(#function)
        super.viewWillAppear(animated)
        
        
        // TODO: This must be done or else runtime error. Why?
        segmentedControl.selectedSegmentIndex = selectedSegment
        setUpCoreData()
        loadCell()
        
        tableView.reloadData()
        
        let selectedIndex = myTabBarController.selectedIndex
        print("Current tab is \(selectedIndex).")
        print("I want to be tab \(myTabIndex).")
        print("Segment is \(segmentedControl.selectedSegmentIndex)")
        
        print("Here comes the recieved message: \(sentMessage)")
        numberOfRemindersInSection()
        print(#function)
        print("___________________")
        print("")
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        print("")
        print("___________________")
        print(#function)
        super.viewDidAppear(animated)
    
        numberOfRemindersInSection()
        
//        setUpCoreData()
//        loadCell()
        
        let selectedIndex = myTabBarController.selectedIndex
        print("Current tab is \(selectedIndex).")
        print("I want to be tab \(myTabIndex).")
        print("Here comes the recieved message: \(sentMessage)")
        
        saveSelectedTab(selectedIndex)
        setNoReminderView()
        
        numberOfRemindersInSection()
        print(#function)
        print("___________________")
        print("")
    }
    
    func numberOfRemindersInSection() {
        print(#function)
        let numberOfRows = tableView.numberOfRowsInSection(0)
        print("There are \(numberOfRows) rows")
    }
    
    
    
    override func viewWillDisappear(animated: Bool) {
        print("")
        print("___________________")
        print("___________________")
        print(#function)
        super.viewWillDisappear(animated)
        print("Here comes the recieved message: \(sentMessage)")
        clearSelectedIndexPaths()
        let selectedIndex = myTabBarController.selectedIndex
        print("Current tab is \(selectedIndex).")
        print("I want to be tab \(myTabIndex).")
        print(#function)
        print("___________________")
        print("")
    }
    
    // MARK: Selection
    func clearSelectedIndexPaths() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }
        }
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    // MARK: Cell
    
    func loadCell() {
        //print(#function)
        let cellNib = UINib(nibName: "ReminderCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "ReminderCell")
        tableView.rowHeight = 100
    }
    
    // MARK: Coredata
    
    func setUpCoreData() {
        print(#function)
        
        coreDataHandler.setObjectContext(managedObjectContext)
        
        let selectedIndex = myTabIndex
        let segment = segmentedControl.selectedSegmentIndex
        var status: ReminderStatus = .Complete
        var filter: ReminderFilter = .All
        
        if segment == 0 {
            status = .Incomplete
            print("Fetching incomplete reminders")
        } else {
            status = .Complete
            print("Fetching complete reminders")
        }
       
        switch selectedIndex {
        case 0:
            print("Filtering for index \(selectedIndex)")
            filter = .Today
            coreDataHandler.setFetchedResultsController("Reminder", cacheName: "TodayReminders", filterBy: filter, status: status)
        case 1:
            print("Filtering for index \(selectedIndex)")
            filter = .Week
            coreDataHandler.setFetchedResultsController("Reminder", cacheName: "WeekReminders", filterBy: filter, status: status)
        case 2:
            print("Filtering for index \(selectedIndex)")
            filter = .All
            coreDataHandler.setFetchedResultsController("Reminder", cacheName: "AllReminders", filterBy: filter, status: status)
        case 3:
            print("Filtering for index \(selectedIndex)")
            filter = .Favorite
            coreDataHandler.setFetchedResultsController("Reminder", cacheName: "FavoriteReminders", filterBy: filter, status: status)
        default:
            print("Filtering for default")
            filter = .All
            coreDataHandler.setFetchedResultsController("Reminder", cacheName: "AllReminders", filterBy: filter, status: status)
        }
        
        coreDataHandler.fetchedResultsController.delegate = self
        coreDataHandler.performFetch()
        
    }
    
    // MARK: Handle no reminders
    
    func setNoReminderView() {
        print(#function)
        if tableView.numberOfRowsInSection(0) == 0 {
            print("There are no reminders")
            noReminderScreen.hidden = false
            setNoReminderLabel()
        } else {
            print("There are reminders")
            noReminderScreen.hidden = true
        }
    }
    
    func setNoReminderLabel() {
        print(#function)
        var completedText = ""
        var text = ""
        
        if selectedSegment == 0 {
            completedText = "upcoming"
        } else {
            completedText = "completed"
        }
        if let selectedTabIndex = tabBarController?.selectedIndex {
            switch selectedTabIndex {
            case 0:
                text = "No \(completedText) reminders for today"
            case 1:
                text = "No \(completedText) reminders for the week"
            case 2:
                text = "No \(completedText) reminders"
            case 3:
                text = "No \(completedText) favorites"
            default:
                text = "Error"
            }
            noReminderLabel.text = text
        }
        
    }
    
    
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(#function)
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
        print(#function)
        let indexPath = tableView.indexPathForCell(cell)
        let reminder = coreDataHandler.reminderFromIndexPath(indexPath!)
        reminder.complete()
        
        coreDataHandler.save()
    }
    
    // MARK: - REMINDERS
    
    // MARK: Reminder list
    
    func updateList() {
        print(#function)
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