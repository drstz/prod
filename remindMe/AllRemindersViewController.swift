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
        
        setNoReminderView()
        setBadgeForTodayTab()
    }
    
    @IBAction func doneSettings(segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Methods
    
    // MARK: Init & Deinit
    
    required init?(coder aDecoder: NSCoder) {
        reminders = [Reminder]()
        super.init(coder: aDecoder)
    }
    
    deinit {
        fetchedResultsController.delegate = nil
//        print("All Reminders was deallocated")
    }
    
    // MARK: View
    
    func countDueReminders() {
        //self.navigationController?.tabBarItem.badgeValue = "2"
    }
    
    override func viewDidLoad() {
        print(#function)
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        
        navigationController?.tabBarController?.tabBar.tintColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
    
        tableView.separatorColor = UIColor.clearColor()
        tableView.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)

    }
    
    override func viewWillAppear(animated: Bool) {
        print(#function)
        super.viewWillAppear(animated)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(completeReminder), name: "completeReminder", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(deferReminder), name: "deferReminder", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(viewReminder), name: "viewReminder", object: nil)
        
        segmentedControl.selectedSegmentIndex = selectedSegment
        setUpCoreData()
        loadCell()
        
        tableView.reloadData()
        
        setNoReminderView()
        
        countDueReminders()
        
        setBadgeForTodayTab()

    }
    
    override func viewDidAppear(animated: Bool) {
        print(#function)
        super.viewDidAppear(animated)
        
        let selectedIndex = myTabBarController.selectedIndex
        saveSelectedTab(selectedIndex)
        

    }
    
    override func viewDidLayoutSubviews() {
        
    }
    
    func numberOfRemindersInSection() {
        print(#function)
        let numberOfRows = tableView.numberOfRowsInSection(0)
        print("There are \(numberOfRows) rows")
    }
    
    override func viewWillDisappear(animated: Bool) {
        print(#function)
        super.viewWillDisappear(animated)
        print("Here comes the recieved message: \(sentMessage)")
        clearSelectedIndexPaths()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "completeReminder", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "deferReminder", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "viewReminder", object: nil)
    
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
        let nib = UINib(nibName: "TableSectionHeader", bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "TableSectionHeader")
        tableView.rowHeight = 100
        
    }
    
    // MARK: Coredata
    
    func setUpCoreData() {
//        print(#function)
        
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
    
    func setBadgeForTodayTab() {
        print(#function)
        let viewControllers = navigationController?.tabBarController?.viewControllers
        print("Number of viewControllers : \(viewControllers?.count)")
        
        let someNavigationController = viewControllers![0] as! UINavigationController
        let todayViewController = someNavigationController.viewControllers[0] as! AllRemindersViewController
        
        let nbOfDueReminders = numberOfDueReminders()
        if nbOfDueReminders == 0 {
            todayViewController.navigationController?.tabBarItem.badgeValue = nil
        } else {
            todayViewController.navigationController?.tabBarItem.badgeValue = "\(numberOfDueReminders())"
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
        if let selectedTabIndex = myTabBarController?.selectedIndex {
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
            
        case "QuickView":
            let navigationController = segue.destinationViewController as! UINavigationController
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
        case "Popup":
            print("Preparing popup")
    
            let popupViewController = segue.destinationViewController as! PopupViewController
            
            popupViewController.delegate = self
            
            // Make Quick View a delegate of All Reminders
            // delegate = controller
            
            if let reminder = sender as? Reminder {
                // When coming from notification
                print("Coming from notification")
                popupViewController.incomingReminder = reminder
                popupViewController.managedObjectContext = managedObjectContext
                //controller.notificationHasGoneOff = notificationHasGoneOff
            } else {
                // When coming from list
                if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell) {
                    let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
                    popupViewController.incomingReminder = reminder
                    popupViewController.managedObjectContext = managedObjectContext
                }
            }
            print("Done preparing popup")
        default:
            break
            
        }
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