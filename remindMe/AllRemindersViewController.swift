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

class AllRemindersViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var noReminderScreen: UIView!
    @IBOutlet weak var noReminderLabel: UILabel!
    
    // MARK: Filter bar
    
    @IBOutlet weak var filterBar: UIView!
    
    // MARK: Filter bar buttons
    
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var allButton: UIButton!
    
    // MARK: - Coredata
    
    let coreDataHandler = CoreDataHandler()
    var managedObjectContext: NSManagedObjectContext!
    
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
    
    var editingList = false
    
    // Help with changing toolbar
    var selectionIsMixed = false
    
    // MARK: Reminder filter
    
    
    
    // MARK: - IBActions
    
    @IBAction func changeSegment() {
        print("")
        print(#function)
        
        setUpCoreData()
        loadCell()
        tableView.reloadData()
        
        deselectRows()
        hideToolbar()
        
        selectedSegment = segmentedControl.selectedSegmentIndex
        
        setNoReminderView()
        setBadgeForTodayTab()
    }
    
    @IBAction func loadRemindersForToday() {
        coreDataHandler.setObjectContext(managedObjectContext)
        var status: ReminderStatus = .Complete
        
        // Handle segment
        let segment = segmentedControl.selectedSegmentIndex
        if segment == 0 {
            status = .Incomplete
            print("Fetching incomplete reminders")
        } else {
            status = .Complete
            print("Fetching complete reminders")
        }
        
        // Set choice
        let filter: ReminderFilter = .Today
        print("Filter was set to \(filter)")
        saveFilter(filter)
        
        // Show selected
        customizeButton(todayButton, selected: true)
        
        // Deselect Other
        customizeButton(allButton, selected: false)
        
        // Fetch choice
        coreDataHandler.setFetchedResultsController("Reminder", cacheName: "AllReminders", filterBy: filter, status: status)
        
        // Reload tableview with choice
        coreDataHandler.fetchedResultsController.delegate = self
        coreDataHandler.performFetch()
        
        tableView.reloadData()
    }
    
    @IBAction func loadAllReminders() {
        coreDataHandler.setObjectContext(managedObjectContext)
        var status: ReminderStatus = .Complete
        
        // Handle segment
        let segment = segmentedControl.selectedSegmentIndex
        if segment == 0 {
            status = .Incomplete
            print("Fetching incomplete reminders")
        } else {
            status = .Complete
            print("Fetching complete reminders")
        }
        
        // Set choice
        let filter: ReminderFilter = .All
        saveFilter(filter)
        
        // Show selected
        customizeButton(allButton, selected: true)
        
        // Deselect Other
        customizeButton(todayButton, selected: false)
        
        // Fetch choice
        coreDataHandler.setFetchedResultsController("Reminder", cacheName: "AllReminders", filterBy: filter, status: status)
        
        // Reload tableview with choice
        coreDataHandler.fetchedResultsController.delegate = self
        coreDataHandler.performFetch()
        
        tableView.reloadData()
    }
    
    // MARK: Unwind segue
    
    /// This is used to allow the settings viewcontroller to perform the unwind segue
    @IBAction func doneSettings(segue: UIStoryboardSegue) {}
    
    // MARK: - Methods
    
    // MARK: Init & Deinit
    
    required init?(coder aDecoder: NSCoder) {
        reminders = [Reminder]()
        super.init(coder: aDecoder)
    }
    
    deinit {
        print(#function)
        print(self)
    }
    
    // MARK: View

    override func viewDidLoad() {
        print(#function)
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        
        navigationController?.tabBarController?.tabBar.tintColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
    
        tableView.separatorColor = UIColor.clearColor()
        tableView.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        
        // Customize buttons
        
        // All Button
        allButton.layer.cornerRadius = 10
        allButton.layer.borderWidth = 1
        allButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        // Today Button
        todayButton.layer.cornerRadius = 10
        todayButton.layer.borderWidth = 1
        todayButton.layer.borderColor = UIColor.whiteColor().CGColor
        
        let filter = savedFilter()
        if filter == .All {
            customizeButton(allButton, selected: true)
            customizeButton(todayButton, selected: false)
        } else {
            customizeButton(todayButton, selected: true)
            customizeButton(allButton, selected: false)
        }
        
        // Customize filter bar
        filterBar.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
    }
    
    func customizeButton(button: UIButton, selected: Bool) {
        if selected {
            button.backgroundColor = UIColor(red: 33/255, green: 69/255, blue: 59/255, alpha: 1)
            button.tintColor = UIColor.whiteColor()
            button.layer.borderColor = UIColor.whiteColor().CGColor
        } else {
            button.backgroundColor = UIColor.clearColor()
            button.tintColor = UIColor.whiteColor()
            button.layer.borderColor = UIColor.whiteColor().CGColor
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        print(#function)
        super.viewWillAppear(animated)
        
        addObservers()
        
        segmentedControl.selectedSegmentIndex = selectedSegment
        setUpCoreData()
        loadCell()
        
        tableView.reloadData()
        
        setNoReminderView()
        setBadgeForTodayTab()
    }
    
    override func viewDidAppear(animated: Bool) {
        print(#function)
        super.viewDidAppear(animated)
        
        let selectedIndex = myTabBarController.selectedIndex
        saveSelectedTab(selectedIndex)
    }
    
    override func viewWillDisappear(animated: Bool) {
        print(#function)
        super.viewWillDisappear(animated)
        print("Here comes the recieved message: \(sentMessage)")
        deselectRows()
        hideToolbar()
        removeObservers()
    }
    
    // MARK: 3D Touch
    
    /// This is called when a user uses the 3D touch Quick Action
    func newReminder() {
        performSegueWithIdentifier("AddReminder", sender: self)
    }
    
    // MARK: Observers
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(completeReminder), name: "completeReminder", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(snoozeReminder), name: "snoozeReminder", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(viewReminder), name: "viewReminder", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setBadgeForTodayTab), name: "setBadgeForTodayTab", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshTableView), name: "refresh", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(newReminder), name: "newReminder", object: nil)
    }
    
    /// Removes observers so that messages are only sent to one view controller at a time
    func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "completeReminder", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "snoozeReminder", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "viewReminder", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "setBadgeForTodayTab", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "refresh", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "newReminder", object: nil)
    }
    
    // MARK: Selection
    
    func deselectRows() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
    }
    
    // MARK: Toolbar
    
    func showToolbar() {
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    func hideToolbar() {
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func toolbarIsHidden() -> Bool {
        return (navigationController?.toolbarHidden)!
    }
    
    // MARK: Cell
    
    func loadCell() {
        //print(#function)
        let cellNib = UINib(nibName: "ReminderCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "ReminderCell")
        
        let sectionHeaderNib = UINib(nibName: "TableSectionHeader", bundle: nil)
        tableView.registerNib(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: "TableSectionHeader")
        tableView.rowHeight = 100
        
    }
    
    // MARK: Coredata
    
    func setUpCoreData() {
//        print(#function)
        
        coreDataHandler.setObjectContext(managedObjectContext)
        
        let selectedIndex = myTabIndex
        let segment = segmentedControl.selectedSegmentIndex
        var status: ReminderStatus = .Complete
        var filter: ReminderFilter = savedFilter()
        
        
        if segment == 0 {
            status = .Incomplete
            print("Fetching incomplete reminders")
        } else {
            status = .Complete
            print("Fetching complete reminders")
        }
        print(savedFilter())
        coreDataHandler.setFetchedResultsController("Reminder", cacheName: "AllReminders", filterBy: savedFilter(), status: status)
       
//        switch selectedIndex {
//        case 0:
//            print("Filtering for index \(selectedIndex)")
//            filter = .All
//            coreDataHandler.setFetchedResultsController("Reminder", cacheName: "AllReminders", filterBy: filter, status: status)
//        case 1:
//            print("Filtering for index \(selectedIndex)")
//            filter = .Week
//            coreDataHandler.setFetchedResultsController("Reminder", cacheName: "WeekReminders", filterBy: filter, status: status)
//        case 2:
//            print("Filtering for index \(selectedIndex)")
//            filter = .All
//            coreDataHandler.setFetchedResultsController("Reminder", cacheName: "AllReminders", filterBy: filter, status: status)
//        case 3:
//            print("Filtering for index \(selectedIndex)")
//            filter = .Favorite
//            coreDataHandler.setFetchedResultsController("Reminder", cacheName: "FavoriteReminders", filterBy: filter, status: status)
//        default:
//            print("Filtering for default")
//            filter = .All
//            coreDataHandler.setFetchedResultsController("Reminder", cacheName: "AllReminders", filterBy: filter, status: status)
//        }
        
        coreDataHandler.fetchedResultsController.delegate = self
        coreDataHandler.performFetch()
        
    }
    
    func setBadgeForTodayTab() {
        print(#function)
        let viewControllers = navigationController?.tabBarController?.viewControllers
        
        let someNavigationController = viewControllers![0] as! UINavigationController
        let todayViewController = someNavigationController.viewControllers[0] as! AllRemindersViewController
        
        let nbOfDueReminders = numberOfDueReminders()
        if nbOfDueReminders == 0 {
            todayViewController.navigationController?.tabBarItem.badgeValue = nil
        } else {
            todayViewController.navigationController?.tabBarItem.badgeValue = "\(numberOfDueReminders())"
        }
    }
    
    func refreshTableView() {
        let nbOfSelectedRows = tableView.indexPathsForSelectedRows?.count
        print("Number of selected rows : \(nbOfSelectedRows)")
        
        if nbOfSelectedRows == nil {
            setUpCoreData()
            tableView.reloadData()
        }
    }
    
    func numberOfDueReminders() -> Int {
        let now = NSDate()
        
        let fetchRequest = NSFetchRequest()
        fetchRequest.fetchBatchSize = 20
        
        let entity = NSEntityDescription.entityForName("Reminder", inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "%K == %@ AND %K <= %@", "isComplete", false, "dueDate", now)
        fetchRequest.predicate = predicate
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
        
        let count = fetchedResultsController.fetchedObjects?.count
        return count!
    }
    
    // MARK: Handle no reminders
    
    func setNoReminderView() {
        print(#function)
        if tableView.numberOfSections == 0 {
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
        
        switch myTabIndex {
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
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(#function)
        
        let segueIdentifier = segue.identifier!
        
        switch segueIdentifier {
        case "AddReminder":
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! AddReminderViewController
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext
            controller.list = list
        case "EditReminder":
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! AddReminderViewController
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
                controller.reminderToEdit = reminder
            }
        case "Popup":
            let popupViewController = segue.destinationViewController as! PopupViewController
            popupViewController.delegate = self
            
            if let reminder = sender as? Reminder {
                // When coming from notification
                print("Coming from notification")
                popupViewController.incomingReminder = reminder
                popupViewController.managedObjectContext = managedObjectContext
            } else {
                // When coming from list
                if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                    let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
                    popupViewController.incomingReminder = reminder
                    popupViewController.managedObjectContext = managedObjectContext
                }
            }
        default:
            break
        }
    }
            
    // MARK: - REMINDERS
    
    // MARK: Reminder Actions
    
    
    /// Delete a reminder
    /// - Parameter reminder: The reminder to delete
    /// - Parameter save: Indicate whether the methode should save or not to repeat saving twice
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