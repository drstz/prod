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
        
        averageTimeBetweenCreationCompletionCell.detailTextLabel?.textColor = UIColor.white
        
        nbOfRemindersCompletedBeforeDueDateLabel.textColor = UIColor.lightGray
        averageTimeBetweenCreationCompletionLabel.textColor = UIColor.lightGray
        averageSnoozeBeforeCompletionLabel.textColor = UIColor.lightGray
        percentageRemindersSnoozedBeforeCompletion.textColor = UIColor.white
        
        numberOfCreatedRemindersLabel.textColor = UIColor.lightGray

        numberOfCompletedRemindersLabel.textColor = UIColor.lightGray
        
        tableView.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        tableView.separatorColor = UIColor.white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        saveSelectedTab((tabBarController?.selectedIndex)!)
        averageTimeBetweenCreationCompletionCell.detailTextLabel?.textColor = UIColor.white
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // MARK: - Tableview
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.isUserInteractionEnabled = true
        cell.backgroundColor = UIColor(red: 40/255, green: 82/255, blue: 108/255, alpha: 1)
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    // MARK: - Data
    func setUpCoreData() {
        let filter: ReminderFilter = .All
        let status: ReminderStatus = .complete
        
        coreDataHandler.setFetchedResultsController("Reminder", cacheName: "AllReminders", filterBy: filter, status: status)
        coreDataHandler.performFetch()
    }
    
    func getReminders() -> [Reminder] {
        var reminders = [Reminder]()
        let frc = coreDataHandler.fetchedResultsController
        let objects = frc?.fetchedObjects
        if let objects = objects {
            for object in objects {
                if let reminder = object as? Reminder {
                    reminders.append(reminder)
                }
            }
        }
        return reminders
    }
    
    func countTimesSnoozed(_ reminders: [Reminder]) {
        let numberOfTimesSnoozedBeforeCompletion = list.totalTimesSnoozed.floatValue
        let nbOfCompletedReminders = list.numberOfCompletedReminders.floatValue
        
        print("Number of times snoozed \(numberOfTimesSnoozedBeforeCompletion)")
        print("Number of completed reminders \(nbOfCompletedReminders)")
        
        if nbOfCompletedReminders != 0 {
            let averageTimesSnoozedBeforeCompletion = numberOfTimesSnoozedBeforeCompletion / nbOfCompletedReminders
            averageSnoozeBeforeCompletionLabel.text = String(averageTimesSnoozedBeforeCompletion)
        } else {
            averageSnoozeBeforeCompletionLabel.text = "No data"
        }
    }
    
    func calculateAverageTimeBetweenDueDateCompletion(_ reminders: [Reminder]) {
        var unit = ""
        
        
        let totalTimeBetweenCreationAndCompletionDates = list.differenceBetweenDueCompletionDate.floatValue
        let nbOfCompletedReminders = list.numberOfCompletedReminders.floatValue
        let nbOfRemindersCompletedBeforeDueDate = list.numberOfRemindersCompletedBeforeDueDate.floatValue
        let totalNumberOfRemindersCompeltedAfterDueDate = nbOfCompletedReminders - nbOfRemindersCompletedBeforeDueDate
        if totalNumberOfRemindersCompeltedAfterDueDate != 0 {
            var averageTimeBetweenDates = totalTimeBetweenCreationAndCompletionDates / totalNumberOfRemindersCompeltedAfterDueDate
            print("Average time is : \(averageTimeBetweenDates)")
            if averageTimeBetweenDates > 1 {
                unit = "minutes"
            } else {
                unit = "minute"
            }
            
            if averageTimeBetweenDates > 60 {
                
                averageTimeBetweenDates = averageTimeBetweenDates / 60
                if averageTimeBetweenDates > 1 {
                    unit = "hours"
                } else {
                    unit = "hour"
                }
                
                
                if averageTimeBetweenDates > 24{
                    averageTimeBetweenDates = averageTimeBetweenDates / 24
                    if averageTimeBetweenDates > 1 {
                        unit = "days"
                    } else {
                       unit = "day"
                    }
                    
                }
            }
            
            if averageTimeBetweenDates < 1 {
                 averageTimeBetweenCreationCompletionLabel.text = "<1 \(unit)"
            } else {
                averageTimeBetweenCreationCompletionLabel.text = String(averageTimeBetweenDates) + " " + unit
            }
            
        } else {
            averageTimeBetweenCreationCompletionLabel.text = "No data"
        }
    }
    
    func calculateRemindersCompletedBeforeDueDate(_ reminders: [Reminder]) {
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
    
    func updateNumberOfCreatedRemindersLabel() {
        let nbOfCreatedReminders = list.numberOfReminders.intValue
        numberOfCreatedRemindersLabel.text = String(nbOfCreatedReminders)
    }
    
    func updateNumberOfCompletedRemindersLabel() {
        let nbOfCompletedReminders = list.numberOfCompletedReminders.intValue
        numberOfCompletedRemindersLabel.text = String(nbOfCompletedReminders)
    }
    
    

  // MARK: - Tab Bar Controller Delegate Methods
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
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
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {}

}
