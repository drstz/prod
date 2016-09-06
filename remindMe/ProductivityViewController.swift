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
    @IBOutlet weak var averageTimeBetweenCreationCompletionLabel: UILabel!
    @IBOutlet weak var averageSnoozeBeforeCompletionLabel: UILabel!
    @IBOutlet weak var nbOfRemindersCompletedBeforeDueDateLabel: UILabel!
    
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUpCoreData()
        
        let reminders = getReminders()
        
        calculateAverageTimeBetweenDueDateCompletion(reminders)
        countTimesSnoozed(reminders)
        calculateRemindersCompletedBeforeDueDate(reminders)
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
        var totalSnoozeCount = 0
        for reminder in reminders {
            let snoozeCount = reminder.nbOfSnoozes
            totalSnoozeCount += (snoozeCount.integerValue)
        }
        
        if reminders.count != 0 {
            let averageSnoozeCount = totalSnoozeCount / reminders.count
            averageSnoozeBeforeCompletionLabel.text = String(averageSnoozeCount)
        } else {
            averageSnoozeBeforeCompletionLabel.text = String(0)
        }
    }
    
    func calculateAverageTimeBetweenDueDateCompletion(reminders: [Reminder]) {
        /// Overdue reminders only
        var remindersInCalculation = 0
        let calendar = NSCalendar.currentCalendar()
        
        var totalTimeBetweenDates = 0
        for reminder in reminders {
            let dueDate = reminder.dueDate
            if let completionDate = reminder.completionDate {
                let earlierDate = dueDate.earlierDate(completionDate)
                if earlierDate == dueDate {
                    remindersInCalculation += 1
                    let minutes = calendar.components(.Minute, fromDate: dueDate, toDate: completionDate, options: [])
                    totalTimeBetweenDates += minutes.minute
                }
                
                
            }
            
        }
        var average = totalTimeBetweenDates / remindersInCalculation
        
        
        averageTimeBetweenCreationCompletionLabel.text = String(average) + " " + "minutes"
    }
    
    func calculateRemindersCompletedBeforeDueDate(reminders: [Reminder]) {
        var remindersCompletedBeforeDueDate = 0
        for reminder in reminders {
            let dueDate = reminder.dueDate
            if let completionDate = reminder.completionDate {
                let earlierDate = dueDate.earlierDate(completionDate)
                if earlierDate == completionDate {
                    remindersCompletedBeforeDueDate += 1
                }
            }
        }
        nbOfRemindersCompletedBeforeDueDateLabel.text = String(remindersCompletedBeforeDueDate)
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
