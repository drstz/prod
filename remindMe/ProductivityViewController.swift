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
    
    // MARK: Labels
    @IBOutlet weak var averageTimeBetweenCreationCompletionLabel: UILabel!
    @IBOutlet weak var averageSnoozeBeforeCompletionLabel: UILabel!
    
    // MARK: - Core Data
    
    var coreDataHandler: CoreDataHandler!
    
    // MARK: - List
    // This is used when creating a reminder
    var list: List!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //tabBarController?.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUpCoreData()
        countReminders()
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
    
    func countReminders() {
        
        let frc = coreDataHandler.fetchedResultsController
        let amountOfFetchedObjects = frc.fetchedObjects?.count
        averageSnoozeBeforeCompletionLabel.text = String(amountOfFetchedObjects!)
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
