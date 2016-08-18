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
    
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    
    var buttons = [UIButton]()
    
    // MARK: - Coredata
    
    let coreDataHandler = CoreDataHandler()
    var managedObjectContext: NSManagedObjectContext!
    
    // MARK: - Segment
    
    var selectedSegment = 0
    
    // MARK: - Delegates
    
    weak var delegate: AllRemindersViewControllerDelegate?
    
    // MARK: Selected button
    var selectedButton: UIButton?
    
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
    
    var upcomingTabNumber: Int?
    
    var sentMessage = "I came from nowhere"
    
    var editingList = false
    
    // Help with changing toolbar
    var selectionIsMixed = false
    
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
        // Set choice
        let filter: ReminderFilter = .Today
        saveFilter(filter)
        
        // Selected Button
        let chosenButton = button(from: filter)
        
        // Show selected
        selectButton(chosenButton)
        
        // Filter list
        filterList(filter)
    }
    
    @IBAction func loadAllReminders() {
        // Set choice
        let filter: ReminderFilter = .All
        saveFilter(filter)
        
        // Selected Button
        let chosenButton = button(from: filter)
        
        // Show selected
        selectButton(chosenButton)
        
        // Filter list
        filterList(filter)
    }
    
    @IBAction func loadRemindersForWeek() {
        // Set choice
        let filter: ReminderFilter = .Week
        saveFilter(filter)
        
        // Selected Button
        let chosenButton = button(from: filter)
        
        // Show selected
        selectButton(chosenButton)
        
        // Filter list
        filterList(filter)
    }
    
    @IBAction func loadFavoriteReminders() {
        // Set choice
        let filter: ReminderFilter = .Favorite
        saveFilter(filter)
        
        // Selected Button
        let chosenButton = button(from: filter)
        
        // Show selected
        selectButton(chosenButton)
        
        // Filter list
        filterList(filter)
    }
    
    func filterList(filter: ReminderFilter) {
        // Handle Segment
        let status = chosenStatus()
        
        coreDataHandler.setObjectContext(managedObjectContext)
        
        // Fetch choice
        coreDataHandler.setFetchedResultsController("Reminder", cacheName: "AllReminders", filterBy: filter, status: status)
        
        // Reload tableview with choice
        coreDataHandler.fetchedResultsController.delegate = self
        coreDataHandler.performFetch()
        
        tableView.reloadData()
        
        // Check if no reminder view should be showing or not
        setNoReminderView()
    }
    
    /// Highlights the selected button.
    /// Sets the previous one to normal state.
    func selectButton(chosenButton: UIButton) {
        // Save previous button for later
        let previouslySelectedButton = selectedButton
        
        selectedButton = chosenButton
        
        if let selectedButton = selectedButton {
            // Show selected
            customizeButton(selectedButton, selected: true)
            
            // Deselected previous button
            if let previouslySelectedButton = previouslySelectedButton {
                customizeButton(previouslySelectedButton, selected: false)
            }
        }
    }
    
    func chosenStatus() -> ReminderStatus {
        let segment = segmentedControl.selectedSegmentIndex
        if segment == 0 {
            return .Incomplete
        } else {
            return .Complete
        }
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
        
        // Set up buttons
        appendButtonsToArray()
        
        for button in buttons {
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.whiteColor().CGColor
        }
        
        // Chosen filter
        let filter = savedFilter()
        
        // Selected button
        selectedButton = button(from: filter)
        
        // Unselected Buttons
        if let selectedButton = selectedButton {
            let otherButtons = unselectedButtons(selectedButton, buttons: buttons)
            
            // Customize buttons
            customizeButton(selectedButton, selected: true)
            
            for button in otherButtons {
                customizeButton(button, selected: false)
            }
        }
        
        // Customize table view
        tableView.separatorColor = UIColor.clearColor()
        tableView.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        
        // Customize bars
        
        // Navigation Bar
        navigationController?.navigationBar.tintColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        
        // Tab bar
        navigationController?.tabBarController?.tabBar.tintColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        
        // Customize filter bar
        filterBar.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        
        // Customize no reminder screen
        noReminderScreen.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
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
        
        let selectedIndex = tabBarController?.selectedIndex
        saveSelectedTab(selectedIndex!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        print(#function)
        super.viewWillDisappear(animated)
        print("Here comes the recieved message: \(sentMessage)")
        deselectRows()
        hideToolbar()
        removeObservers()
    }
    
    // MARK: Buttons
    
    func unselectedButtons(selectedButton: UIButton, buttons: [UIButton]) -> [UIButton] {
        // Index of selected buttons
        let indexOfChosenButton = buttons.indexOf(selectedButton)
        var unselectedButtons = buttons
        
        // Remove selected button from new array
        if let index = indexOfChosenButton {
            unselectedButtons.removeAtIndex(index)
        }
        return unselectedButtons
    }
    
    func button(from filter: ReminderFilter) -> UIButton {
        switch filter {
        case .All:
            return allButton
        case .Today:
            return todayButton
        case .Week:
            return weekButton
        case .Favorite:
            return favoritesButton
        default:
            print("Error finding chosen button")
            return allButton
        }
    }
    
    // MARK: Customize filter buttons
    func appendButtonsToArray() {
        buttons.append(allButton)
        buttons.append(todayButton)
        buttons.append(weekButton)
        buttons.append(favoritesButton)
    }
    
    func customizeButton(button: UIButton, selected: Bool) {
        if selected {
            //button.backgroundColor = UIColor(red: 33/255, green: 69/255, blue: 59/255, alpha: 1)
            button.backgroundColor = UIColor.whiteColor()
            button.tintColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
            button.layer.borderColor = UIColor.whiteColor().CGColor
        } else {
            button.backgroundColor = UIColor.clearColor()
            button.tintColor = UIColor.whiteColor()
            button.layer.borderColor = UIColor.whiteColor().CGColor
        }
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
        coreDataHandler.setObjectContext(managedObjectContext)
        
        let filter = savedFilter()
        let status = chosenStatus()
        
        coreDataHandler.setFetchedResultsController("Reminder", cacheName: "AllReminders", filterBy: filter, status: status)
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
        
        switch selectedButton! {
        case todayButton:
            text = "No \(completedText) reminders for today"
        case weekButton:
            text = "No \(completedText) reminders for the week"
        case allButton:
            text = "No \(completedText) reminders"
        case favoritesButton:
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