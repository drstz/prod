//
//  StatisticsViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 18/08/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

class ProductivityViewController: UITableViewController, UITabBarControllerDelegate {
    
    // MARK: - Outlets
    
    // MARK: Cells
    
    @IBOutlet weak var averageTimeBetweenCreationCompletionCell: UITableViewCell!
    @IBOutlet weak var averageSnoozeBeforeCompletionCell: UITableViewCell!
    @IBOutlet weak var nbOfRemindersCompletedBeforeDueDate: UITableViewCell!
    
    @IBOutlet weak var nbOfCreatedRemindersCell: UITableViewCell!
    @IBOutlet weak var nbOfCompletedRemindersCell: UITableViewCell!
    
    // MARK: Labels
    
    // Productivity
    @IBOutlet weak var averageTimeBetweenCreationCompletionLabel: UILabel!
    @IBOutlet weak var averageSnoozeBeforeCompletionLabel: UILabel!
    @IBOutlet weak var nbOfRemindersCompletedBeforeDueDateLabel: UILabel!
    @IBOutlet weak var percentageRemindersSnoozedBeforeCompletion: UILabel!
    
    // Stats
    @IBOutlet weak var numberOfCreatedRemindersLabel: UILabel!
    @IBOutlet weak var numberOfActiveRemindersLabel: UILabel!
    @IBOutlet weak var numberOfCompletedRemindersLabel: UILabel!
    
    // MARK: - Core Data
    
    var coreDataHandler: CoreDataHandler!
    
    // MARK: - List
    // This is used when creating a reminder
    var list: List!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        averageTimeBetweenCreationCompletionCell.detailTextLabel?.textColor = UIColor.whiteColor()
        
        nbOfRemindersCompletedBeforeDueDateLabel.textColor = UIColor.lightGrayColor()
        averageTimeBetweenCreationCompletionLabel.textColor = UIColor.lightGrayColor()
        averageSnoozeBeforeCompletionLabel.textColor = UIColor.lightGrayColor()
        percentageRemindersSnoozedBeforeCompletion.textColor = UIColor.whiteColor()
        
        numberOfCreatedRemindersLabel.textColor = UIColor.lightGrayColor()

        numberOfCompletedRemindersLabel.textColor = UIColor.lightGrayColor()
        
        tableView.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        tableView.separatorColor = UIColor.whiteColor()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUpCoreData()
        
        let reminders = getReminders()
        
        calculateAverageTimeBetweenDueDateCompletion(reminders)
        countTimesSnoozed(reminders)
        calculateRemindersCompletedBeforeDueDate(reminders)
        updateNumberOfCreatedRemindersLabel()
        updateNumberOfCompletedRemindersLabel()
        calcutePercentageOfRemindersSnoozed()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        saveSelectedTab((tabBarController?.selectedIndex)!)
        averageTimeBetweenCreationCompletionCell.detailTextLabel?.textColor = UIColor.whiteColor()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        // tabBarController?.delegate = nil
    }
    
    // MARK: - Tableview
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.userInteractionEnabled = true
        cell.backgroundColor = UIColor(red: 40/255, green: 82/255, blue: 108/255, alpha: 1)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.whiteColor()
        // header.titleLabel.textColor = UIColor.whiteColor()
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
    // MARK: - Data
    func setUpCoreData() {
        let filter: ReminderFilter = .All
        let status: ReminderStatus = .Complete
        
        coreDataHandler.setFetchedResultsController("Reminder", cacheName: "AllReminders", filterBy: filter, status: status)
        coreDataHandler.performFetch()
    }
    
    func getReminders() -> [Reminder] {
        var reminders = [Reminder]()
        let frc = coreDataHandler.fetchedResultsController
        let objects = frc.fetchedObjects
        if let objects = objects {
            for object in objects {
                if let reminder = object as? Reminder {
                    reminders.append(reminder)
                }
            }
        }
        return reminders
    }
    
    func countTimesSnoozed(reminders: [Reminder]) {
        let numberOfTimesSnoozedBeforeCompletion = list.totalTimesSnoozed.integerValue
        let nbOfCompletedReminders = list.numberOfCompletedReminders.integerValue
        
        print("Number of times snoozed \(numberOfTimesSnoozedBeforeCompletion)")
        print("Number of completed reminders \(nbOfCompletedReminders)")
        
        if nbOfCompletedReminders != 0 {
            let averageTimesSnoozedBeforeCompletion = numberOfTimesSnoozedBeforeCompletion / nbOfCompletedReminders
            averageSnoozeBeforeCompletionLabel.text = String(averageTimesSnoozedBeforeCompletion)
        } else {
            averageSnoozeBeforeCompletionLabel.text = "No data"
        }
    }
    
    func calculateAverageTimeBetweenDueDateCompletion(reminders: [Reminder]) {
        var unit = "minutes"
        
        
        let totalTimeBetweenCreationAndCompletionDates = list.differenceBetweenDueCompletionDate.floatValue
        let nbOfCompletedReminders = list.numberOfCompletedReminders.floatValue
        if nbOfCompletedReminders != 0 {
            var averageTimeBetweenDates = totalTimeBetweenCreationAndCompletionDates / nbOfCompletedReminders
            print("Average time is : \(averageTimeBetweenDates)")
            if averageTimeBetweenDates > 60 {
                
                averageTimeBetweenDates = averageTimeBetweenDates / 60
                unit = "hours"
                
                if averageTimeBetweenDates > 24{
                    averageTimeBetweenDates = averageTimeBetweenDates / 24
                    unit = "days"
                }
                
            }
            if averageTimeBetweenDates < 0 {
                averageTimeBetweenDates = averageTimeBetweenDates * -1
                
            }
            
            if averageTimeBetweenDates <= 1 {
                 averageTimeBetweenCreationCompletionLabel.text = "<1 \(unit)"
            } else {
                averageTimeBetweenCreationCompletionLabel.text = String(averageTimeBetweenDates) + " " + unit
            }
            
        } else {
            averageTimeBetweenCreationCompletionLabel.text = "No data"
        }
        
        
    }
    
    func calculateRemindersCompletedBeforeDueDate(reminders: [Reminder]) {
        let nbOfRemindersCompletedBeforeDueDate = list.numberOfRemindersCompletedBeforeDueDate.floatValue
        let nbOfCompletedReminders = list.numberOfCompletedReminders.floatValue
        if nbOfRemindersCompletedBeforeDueDate != 0 {
            print("\(nbOfRemindersCompletedBeforeDueDate) / \(nbOfCompletedReminders) * 100")
            let percentageOfRemindersCompletedBeforeDueDate = Int((nbOfRemindersCompletedBeforeDueDate / nbOfCompletedReminders) * 100.0)
            nbOfRemindersCompletedBeforeDueDateLabel.text = String(percentageOfRemindersCompletedBeforeDueDate) + "%"
        } else {
            nbOfRemindersCompletedBeforeDueDateLabel.text = "None"
        }
    }
    
    func updateNumberOfCreatedRemindersLabel() {
        let nbOfCreatedReminders = list.numberOfReminders.integerValue
        numberOfCreatedRemindersLabel.text = String(nbOfCreatedReminders)
    }
    
    func updateNumberOfCompletedRemindersLabel() {
        let nbOfCompletedReminders = list.numberOfCompletedReminders.integerValue
        numberOfCompletedRemindersLabel.text = String(nbOfCompletedReminders)
    }
    
    func calcutePercentageOfRemindersSnoozed() {
        let nbOfCompletedReminders = list.numberOfCompletedReminders.floatValue
        let nbOfRemindersSnoozed = list.numberOfSnoozedReminders.floatValue
        
        if nbOfCompletedReminders != 0 {
            print("\(nbOfRemindersSnoozed) / \(nbOfCompletedReminders) * 100")
            let percentageOfSnoozedReminders = Int((nbOfRemindersSnoozed / nbOfCompletedReminders) * 100.0)
            percentageRemindersSnoozedBeforeCompletion.text = String(percentageOfSnoozedReminders) + "%"
        } else {
            percentageRemindersSnoozedBeforeCompletion.text = "No data"
        }
        
    
    }
    
    

  // MARK: - Tab Bar Controller Delegate Methods
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        print(#function)
        if viewController.tabBarItem.tag == 0 {
            print("Selecting Reminders Tab")
            let navigationController = viewController as! UINavigationController
            let allReminderViewController = navigationController.viewControllers[0] as! AllRemindersViewController
            
            // Make sure only one view controller is the delegate
            allReminderViewController.tabBarController?.delegate = allReminderViewController
            allReminderViewController.coreDataHandler = coreDataHandler
            allReminderViewController.list = list 
            
            return true
        } else {
            print("Selecting Profile Tab")
            return false
        }
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {}

}
