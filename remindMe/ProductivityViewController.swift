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
    
    // MARK: Labels
    
    // Productivity
    @IBOutlet weak var averageTimeBetweenCreationCompletionLabel: UILabel!
    @IBOutlet weak var averageSnoozeBeforeCompletionLabel: UILabel!
    @IBOutlet weak var nbOfRemindersCompletedBeforeDueDateLabel: UILabel!
    
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
        
        nbOfRemindersCompletedBeforeDueDateLabel.textColor = UIColor.lightGrayColor()
        averageTimeBetweenCreationCompletionLabel.textColor = UIColor.lightGrayColor()
        averageSnoozeBeforeCompletionLabel.textColor = UIColor.lightGrayColor()
        
        numberOfCreatedRemindersLabel.textColor = UIColor.lightGrayColor()
//        numberOfActiveRemindersLabel.textColor = UIColor.lightGrayColor()
        numberOfCompletedRemindersLabel.textColor = UIColor.lightGrayColor()
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        saveSelectedTab((tabBarController?.selectedIndex)!)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        // tabBarController?.delegate = nil
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
        var position = "after"
        
        let totalTimeBetweenCreationAndCompletionDates = list.differenceBetweenDueCompletionDate.integerValue
        let nbOfCompletedReminders = list.numberOfCompletedReminders.integerValue
        if nbOfCompletedReminders != 0 {
            var averageTimeBetweenDates = totalTimeBetweenCreationAndCompletionDates / nbOfCompletedReminders
            print("Average time is : \(averageTimeBetweenDates)")
            if (averageTimeBetweenDates * -1) > 60 {
                
                averageTimeBetweenDates = averageTimeBetweenDates / 60
                unit = "hours"
                
                if (averageTimeBetweenDates * -1) > 24{
                    averageTimeBetweenDates = averageTimeBetweenDates / 24
                    unit = "days"
                }
                
            }
            if averageTimeBetweenDates < 0 {
                averageTimeBetweenDates = averageTimeBetweenDates * -1
                position = "before"
            }
            averageTimeBetweenCreationCompletionLabel.text = String(averageTimeBetweenDates) + " " + unit + " " + position
        } else {
            averageTimeBetweenCreationCompletionLabel.text = "No data"
        }
        
        
    }
    
    func calculateRemindersCompletedBeforeDueDate(reminders: [Reminder]) {
        let nbOfRemindersCompletedBeforeDueDate = list.numberOfRemindersCompletedBeforeDueDate.integerValue
        nbOfRemindersCompletedBeforeDueDateLabel.text = String(nbOfRemindersCompletedBeforeDueDate)
    }
    
    func updateNumberOfCreatedRemindersLabel() {
        let nbOfCreatedReminders = list.numberOfReminders.integerValue
        numberOfCreatedRemindersLabel.text = String(nbOfCreatedReminders)
    }
    
    func updateNumberOfCompletedRemindersLabel() {
        let nbOfCompletedReminders = list.numberOfCompletedReminders.integerValue
        numberOfCompletedRemindersLabel.text = String(nbOfCompletedReminders)
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
