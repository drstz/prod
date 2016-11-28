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
import Fabric
import Crashlytics

protocol AllRemindersViewControllerDelegate: class {
    func allRemindersViewControllerDelegateDidReceiveNotification (_ controller: AllRemindersViewController,
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
    
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    
    var buttons = [UIButton]()
    
    // MARK: - Coredata
    
    var coreDataHandler: CoreDataHandler!
    
    // MARK: - Segment
    
    var selectedSegment = 0
    
    // MARK: - Delegates
    
    weak var delegate: AllRemindersViewControllerDelegate?
    
    // MARK: Selected button
    var selectedButton: UIButton?
    
    // MARK: - Properties
    
    var reminderFromNotification: Reminder? {
        didSet {
            print("Tab \(tabBarController?.selectedIndex) has reminder \"\(reminderFromNotification!.name)")
            print("")
            delegate?.allRemindersViewControllerDelegateDidReceiveNotification(self, reminder: reminderFromNotification!)
        }
    }
    
    var list: List!
    
    // Help with changing toolbar
    var selectionIsMixed = false
    
    // Help with settings observers
    var observersAreSet = false
    
    // Help with popup after notification
    var notificationWasTapped = false
    
    // MARK: Colors
    let theme = Theme()
    
    // MARK: - IBActions
    
    // MARK: Segment
    
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
    
    func chosenStatus() -> ReminderStatus {
        let segment = segmentedControl.selectedSegmentIndex
        if segment == 0 {
            return .incomplete
        } else {
            return .complete
        }
    }
    
    // MARK: Filter Bar
    
    @IBAction func loadRemindersForToday() {
        if savedFilter() != .Today {
            // Set choice
            let filter: ReminderFilter = .Today
            save(filter)
            
            // Selected Button
            let chosenButton = button(from: filter)
            
            // Show selected
            selectButton(chosenButton)
            
            // Filter list
            filterList(filter)
            
            // Hide toolbar
            deselectRows()
            hideToolbar()
        }
    }
    
    @IBAction func loadAllReminders() {
        if savedFilter() != .All {
            // Set choice
            let filter: ReminderFilter = .All
            save(filter)
            
            // Selected Button
            let chosenButton = button(from: filter)
            
            // Show selected
            selectButton(chosenButton)
            
            // Filter list
            filterList(filter)
            
            // Hide toolbar
            deselectRows()
            hideToolbar()
        }
    }
    
    @IBAction func loadRemindersForWeek() {
        if savedFilter() != .Week {
            // Set choice
            let filter: ReminderFilter = .Week
            save(filter)
            
            // Selected Button
            let chosenButton = button(from: filter)
            
            // Show selected
            selectButton(chosenButton)
            
            // Filter list
            filterList(filter)
            
            // Hide toolbar
            deselectRows()
            hideToolbar()
        }
    }
    
    @IBAction func loadFavoriteReminders() {
        if savedFilter() != .Favorite {
            // Set choice
            let filter: ReminderFilter = .Favorite
            save(filter)
            
            // Selected Button
            let chosenButton = button(from: filter)
            
            // Show selected
            selectButton(chosenButton)
            
            // Filter list
            filterList(filter)
            
            // Hide toolbar
            deselectRows()
            hideToolbar()
        }
    }
    
    /// Highlights the selected button.
    /// Sets the previous one to normal state.
    func selectButton(_ chosenButton: UIButton) {
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
    
    // MARK: Filter list
    
    func filterList(_ filter: ReminderFilter) {
        // Handle Segment
        let status = chosenStatus()
        
        // Fetch choice
        coreDataHandler.setFetchedResultsController("Reminder", cacheName: "AllReminders", filterBy: filter, status: status)
        
        // Reload tableview with choice
        coreDataHandler.fetchedResultsController?.delegate = self
        coreDataHandler.performFetch()
        
        tableView.reloadData()
        
        // Check if no reminder view should be showing or not
        setNoReminderView()
    }
    
    // MARK: Unwind segue
    
    /// This is used to allow the settings viewcontroller to perform the unwind segue
    @IBAction func doneSettings(_ segue: UIStoryboardSegue) {}
    
    // MARK: - Methods
    
    // MARK: Init & Deinit
    
    required init?(coder aDecoder: NSCoder) {
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
            button.layer.borderColor = UIColor.white.cgColor
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
        tableView.separatorColor = UIColor.clear
        tableView.backgroundColor = theme.backgroundColor
        
        // Customize bars
        
        // Navigation Bar
        navigationController?.navigationBar.tintColor = theme.tintColor
        
        // Tab bar
        navigationController?.tabBarController?.tabBar.tintColor = theme.tintColor
        
        // Customize filter bar
        filterBar.backgroundColor = theme.backgroundColor
        
        
        // Customize no reminder screen
        noReminderScreen.backgroundColor = theme.backgroundColor
        
        // Observers
        if !observersAreSet {
            addObservers()
            observersAreSet = true
        }	
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        super.viewWillAppear(animated)
        
        // addObservers()
        
        segmentedControl.selectedSegmentIndex = selectedSegment
        setUpCoreData()
        loadCell()
        
        tableView.reloadData()
        
        setNoReminderView()
        setBadgeForTodayTab()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(#function)
        super.viewDidAppear(animated)
        
        let selectedIndex = tabBarController?.selectedIndex
        saveSelectedTab(selectedIndex!)
        
        if notificationWasTapped {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "viewReminder"), object: nil)
            notificationWasTapped = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(#function)
        super.viewWillDisappear(animated)
        deselectRows()
        hideToolbar()
    }
    
    // MARK: Buttons
    
    func unselectedButtons(_ selectedButton: UIButton, buttons: [UIButton]) -> [UIButton] {
        // Index of selected buttons
        let indexOfChosenButton = buttons.index(of: selectedButton)
        var unselectedButtons = buttons
        
        // Remove selected button from new array
        if let index = indexOfChosenButton {
            unselectedButtons.remove(at: index)
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
    
    func customizeButton(_ button: UIButton, selected: Bool) {
        if selected {
            button.backgroundColor = UIColor.white
            button.tintColor = theme.tintColor
            button.layer.borderColor = UIColor.white.cgColor
        } else {
            button.backgroundColor = UIColor.clear
            button.tintColor = UIColor.white
            button.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    // MARK: 3D Touch
    
    /// This is called when a user uses the 3D touch Quick Action
    func newReminder() {
        NSLog(#function)
        performSegue(withIdentifier: "AddReminder", sender: self)
    }
    
    // MARK: Observers
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(viewReminder), name: NSNotification.Name(rawValue: "viewReminder"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setBadgeForTodayTab), name: NSNotification.Name(rawValue: "setBadgeForTodayTab"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: NSNotification.Name(rawValue: "refresh"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newReminder), name: NSNotification.Name(rawValue: "newReminder"), object: nil)
    }
    
    /// Removes observers so that messages are only sent to one view controller at a time
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "viewReminder"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "setBadgeForTodayTab"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "refresh"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newReminder"), object: nil)
    }
    
    // MARK: Selection
    
    func deselectRows() {
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                tableView.deselectRow(at: indexPath, animated: true)
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
        return (navigationController?.isToolbarHidden)!
    }
    
    // MARK: Cell
    
    func loadCell() {
        let cellNib = UINib(nibName: "ReminderCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "ReminderCell")
        
        let sectionHeaderNib = UINib(nibName: "TableSectionHeader", bundle: nil)
        tableView.register(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: "TableSectionHeader")
        tableView.rowHeight = 100
    }
    
    // MARK: Coredata
    
    func setUpCoreData() {
        let filter = savedFilter()
        let status = chosenStatus()
        
        coreDataHandler.setFetchedResultsController("Reminder", cacheName: "AllReminders", filterBy: filter, status: status)
        coreDataHandler.fetchedResultsController?.delegate = self
        coreDataHandler.performFetch()
    }
    
    func setBadgeForTodayTab() {
        print(#function)
        
        let nbOfDueReminders = numberOfDueReminders()
        if nbOfDueReminders == 0 {
            self.navigationController?.tabBarItem.badgeValue = nil
        } else {
            self.navigationController?.tabBarItem.badgeValue = "\(numberOfDueReminders())"
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
        // Core Data
        let managedObjectContext = coreDataHandler.managedObjectContext
        
        let now = Date()
        
        let fetchRequest = NSFetchRequest<Reminder>(entityName: "Reminder")
        fetchRequest.fetchBatchSize = 20
        
        let entity = NSEntityDescription.entity(forEntityName: "Reminder", in: managedObjectContext)
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate(format: "%K == %@ AND %K <= %@", "wasCompleted", false as CVarArg, "dueDate", now as CVarArg)
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
            noReminderScreen.isHidden = false
            setNoReminderLabel()
        } else {
            print("There are reminders")
            noReminderScreen.isHidden = true
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(#function)
        NSLog(#function)
        // Core Data
        NSLog("Segue: Getting MOC")
        let managedObjectContext = coreDataHandler.managedObjectContext
        NSLog("Segue: Got MOC")
        let segueIdentifier = segue.identifier!
        
        switch segueIdentifier {
        case "AddReminder":
            NSLog("Segue: Preparing to add reminder")
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! AddReminderViewController
            NSLog("Segue: Got add reminder view controller")
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext
            NSLog("Segue: Set MOC")
            controller.list = list
            NSLog("Segue: Done")
        case "EditReminder":
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! AddReminderViewController
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
                controller.reminderToEdit = reminder
            }
        case "Popup":
            let popupViewController = segue.destination as! PopupViewController
            popupViewController.delegate = self
            
            if let reminder = sender as? Reminder {
                // When coming from notification
                print("Coming from notification")
                popupViewController.incomingReminder = reminder
                popupViewController.managedObjectContext = managedObjectContext
            } else {
                // When coming from list
                if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
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
    func deleteReminder(_ reminder: Reminder, save: Bool = true) {
        print(#function)
        if coreDataHandler.fetchedResultsController?.indexPath(forObject: reminder) != nil {
            let reminderNotificationHandler = reminder.notificationHandler
            reminderNotificationHandler.deleteReminderNotifications(reminder)
            
            coreDataHandler.delete(reminder)
            if save {
                coreDataHandler.save()
            }
        }
    }
}

extension AllRemindersViewController: AddReminderViewControllerDelegate {
    
    // MARK: Add/Edit Reminders
    
    func addReminderViewControllerDidCancel(_ controller: AddReminderViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addReminderViewController(_ controller:AddReminderViewController,
                                   didFinishAddingReminder reminder: Reminder) {
        dismiss(animated: true, completion: nil)
    }
    
    func addReminderViewController(_ controller:AddReminderViewController,
                                   didChooseToDeleteReminder reminder: Reminder) {
        deleteReminder(reminder)
        dismiss(animated: true, completion: nil)
    }
    
    func addReminderViewControllerDidFinishAdding(_ controller: AddReminderViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addReminderViewController(_ controller: AddReminderViewController, didFinishEditingReminder reminder: Reminder) {
        dismiss(animated: true, completion: nil)
    }
}

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

extension AllRemindersViewController {
    func viewReminder() {
        NSLog(#function)
        print(#function)
        
        if let reminder = reminderFromNotification {
            // Tracking
            Answers.logCustomEvent(withName: "View Reminder", customAttributes: ["Category": "Notification"])
            performSegue(withIdentifier: "Popup", sender: reminder)
        }
    }
}

extension AllRemindersViewController: PopupViewControllerDelegate {
    func popupViewControllerDidComplete(_ controller: PopupViewController, reminder: Reminder) {
        reminder.complete()
        coreDataHandler.save()
        dismiss(animated: true, completion: nil)
    }
    
    func popupViewControllerDidSnooze(_ controller: PopupViewController, reminder: Reminder) {
        print(#function)
        reminder.snooze()
        coreDataHandler.save()
        dismiss(animated: true, completion: nil)
    }
    
    func popupViewControllerDidDelete(_ controller: PopupViewController, reminder: Reminder) {
        deleteReminder(reminder)
        dismiss(animated: true, completion: nil)
    }
}

extension AllRemindersViewController: ReminderCellDelegate {
    
    // MARK: Cell
    
    func cellWasLongPressed(_ cell: ReminderCell, longPress: UILongPressGestureRecognizer) {
        print(#function)
        let indexPath = tableView.indexPath(for: cell)
        let reminder = coreDataHandler.reminderFromIndexPath(indexPath!)
        
        if longPress.state == .began && selectedReminders().count == 0 {
            print("Going to edit list")
            tableView.allowsMultipleSelection = true
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            
            var favoriteText = ""
            let completeText = "Complete"
            if reminder.isFavorite == true {
                favoriteText = "Remove favorite"
            } else {
                favoriteText = "Favorite"
            }
            
            let favorite = UIBarButtonItem.init(title: favoriteText, style: .plain, target: self, action: #selector(toolbarFavorite))
            let delete = UIBarButtonItem.init(barButtonSystemItem: .trash, target: self, action: #selector(toolbarDelete))
            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            toolbarItems = [favorite, spacer, delete]
            
            if reminder.wasCompleted == false {
                let complete = UIBarButtonItem.init(title: completeText, style: .plain, target: self, action: #selector(toolbarComplete))
                toolbarItems?.insert(complete, at: 0)
            }
            
            if toolbarIsHidden() {
                showToolbar()
            } else {
                hideToolbar()
            }
        }
    }
}

extension AllRemindersViewController: UITabBarControllerDelegate, PremiumUserViewControllerDelegate  {
    // MARK: TabBar
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print(#function)
        
        if viewController.tabBarItem.tag == 1 {
            
            if isPremium() {
                print("Selecting Profile Tab")
                let navigationController = viewController as! UINavigationController
                let statisticViewController = navigationController.viewControllers[0] as! ProductivityViewController
                
                // Make sure only one view controller is the delegate
                statisticViewController.tabBarController?.delegate = statisticViewController
                statisticViewController.coreDataHandler = coreDataHandler
                statisticViewController.list = list
                
                return true
            } else {
                presentPremiumView()
                return false
            }
            
            
        } else {
            print("Selecting Reminders Tab")
            return false
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print(#function)
    }
    
    func presentPremiumView() {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        
        
        let premiumView = storyboard.instantiateViewController(withIdentifier: "PremiumView") as! PremiumUserViewController
        premiumView.delegate = self
        
        let navigationController = UINavigationController()
        navigationController.viewControllers.append(premiumView)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    func premiumUserViewControllerDelegateDidCancel(controller: PremiumUserViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension AllRemindersViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        print(#function)
        print(coreDataHandler.fetchedResultsController!.sections?.count)
        return (coreDataHandler.fetchedResultsController!.sections?.count)!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        print(#function)
        let sectionInfo = (coreDataHandler.fetchedResultsController?.sections!)! as [NSFetchedResultsSectionInfo]
        let text = sectionInfo[section].name
        
        // Dequeue with the reuse identifier
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TableSectionHeader")
        let header = view as! TableSectionHeader
        
        header.titleLabel.text = text
        
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        print(#function)
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
    
    private func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
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

extension AllRemindersViewController {
    // MARK: Toolbar Actions
    
    func toolbarComplete() {
        let reminders = selectedReminders()
        for reminder in reminders {
            reminder.complete()
            
            // Tracking
            Answers.logCustomEvent(withName: "Completed", customAttributes: ["Category": "Toolbar"])
        }
        coreDataHandler.save()
        deselectRows()
        // refreshTableView() // Might need to restore this
        hideToolbar()
    }
    
    func toolbarDelete() {
        var deleteActionTitle = ""
        
        let reminders = selectedReminders()
        if reminders.count > 1 {
            deleteActionTitle = "Delete \(reminders.count) reminders?"
        } else {
            deleteActionTitle = "Delete this reminder?"
        }
        
        let alert = UIAlertController(title: deleteActionTitle, message: "You cannot undo this", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
            action in
            for reminder in reminders {
                self.deleteReminder(reminder, save: false)
            }
            self.coreDataHandler.save()
            self.deselectRows()
            self.refreshTableView()
            self.hideToolbar()
            
            // Tracking
            Answers.logCustomEvent(withName: "Delete", customAttributes: ["Category": "Toolbar"])
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func toolbarFavorite() {
        let reminders = selectedReminders()
        if selectionHasFavorite(reminders) && selectionIsMixed(reminders) {
            for reminder in reminders {
                reminder.setFavorite(true)
                Answers.logCustomEvent(withName: "Favorited", customAttributes: ["Category": "Toolbar"])
            }
        } else {
            for reminder in reminders {
                if reminder.isFavorite == false {
                    reminder.setFavorite(true)
                    Answers.logCustomEvent(withName: "Favorited", customAttributes: ["Category": "Toolbar"])
                } else {
                    reminder.setFavorite(false)
                    Answers.logCustomEvent(withName: "Unfavorited", customAttributes: ["Category": "Toolbar"])
                }
            }
        }
        
        coreDataHandler.save()
        deselectRows()
        refreshTableView()
        hideToolbar()
    }
    
    // MARK: Selection and deselection
    
    func selectedReminders() -> [Reminder] {
        var reminders = [Reminder]()
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                let reminder = coreDataHandler.reminderFromIndexPath(indexPath)
                reminders.append(reminder)
            }
        }
        return reminders
    }
    
    func selectionHasFavorite(_ selectedReminders: [Reminder]) -> Bool {
        for reminder in selectedReminders {
            if reminder.isFavorite == true {
                return true
            }
        }
        return false
    }
    
    func selectionIsMixed(_ selectedReminders: [Reminder]) -> Bool {
        var isFavorite: Bool?
        for reminder in selectedReminders {
            if isFavorite == nil {
                isFavorite = reminder.isFavorite as? Bool
            } else {
                if reminder.isFavorite as? Bool != isFavorite {
                    return true
                }
            }
        }
        return false
    }
    
    func checkSelectionForFavorites() {
        selectionIsMixed = false
        var containsFavorite = false
        var containsUnFavorite = false
        var isComplete = false
        let reminders = selectedReminders()
        for reminder in reminders {
            if reminder.isFavorite == true {
                containsFavorite = true
                if containsUnFavorite {
                    selectionIsMixed = true
                } else {
                    selectionIsMixed = false
                }
            } else {
                containsUnFavorite = true
                if containsFavorite == true {
                    selectionIsMixed = true
                } else {
                    selectionIsMixed = false
                }
            }
            
            if reminder.wasCompleted == true {
                isComplete = true
            } else {
                isComplete = false
            }
        }
        print("Contains favorite = \(containsFavorite)")
        print("Is mixed = \(selectionIsMixed)")
        
        
        if selectionIsMixed || containsUnFavorite {
            if isComplete {
                let favoriteItem = toolbarItems![0]
                favoriteItem.title = "Favorite"
                toolbarItems![0] = favoriteItem
            } else {
                let favoriteItem = toolbarItems![1]
                favoriteItem.title = "Favorite"
                toolbarItems![1] = favoriteItem
            }
        } else if !selectionIsMixed && containsFavorite {
            if isComplete {
                let favoriteItem = toolbarItems![0]
                favoriteItem.title = "Remove favorite"
                toolbarItems![0] = favoriteItem
            } else {
                let favoriteItem = toolbarItems![1]
                favoriteItem.title = "Remove favorite"
                toolbarItems![1] = favoriteItem
            }
        }
    }
}

class TableSectionHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        //        print(#function)
        super.awakeFromNib()
        
        titleLabel.layer.cornerRadius = 3
        titleLabel.layer.masksToBounds = true
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.white
    }
}
