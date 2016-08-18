//
//  AppDelegate.swift
//  remindMe
//
//  Created by Duane Stoltz on 11/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit
import CoreData

let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"

func fatalCoreDataError(error: ErrorType) {
    print("*** Fatal Error: \(error)")
    NSNotificationCenter.defaultCenter().postNotificationName(MyManagedObjectContextSaveDidFailNotification, object: nil)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let coreDataHandler = CoreDataHandler()
    let notificationHandler = NotificationHandler()
    
    var firstTime = true
    
    var notificationWentOff = false

    var window: UIWindow?
    
    var shortcutItem: UIApplicationShortcutItem?
    
    // MARK: - Application
    
    // MARK: Launch
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        print(#function)
        // User Defaults
        registerDefaults()
        
        // Shortcut
        var shouldPerformShortcutDelegate = true
        
        
        
        // Saved Tab
        let savedTab = getSavedTab()
        
        if savedTab == 0 {
            // All Reminders View Controller
            let allRemindersViewController = getAllRemindersViewController()
            
            // Transfer data
            allRemindersViewController.coreDataHandler = coreDataHandler
            
            // Make View Controller a delegate of the tab bar controller
            allRemindersViewController.tabBarController?.delegate = allRemindersViewController
            
            // Handle first time
            // This is for the creation of the list variable. It is needed to add reminders
            if isFirstTime() {
                setUpFirstTime(allRemindersViewController)
            } else {
                loadList(allRemindersViewController)
            }
            
            // Select index
            allRemindersViewController.tabBarController?.selectedIndex = savedTab
            
        } else {
            // Tab bar controller
            let tabBarController = window!.rootViewController as! UITabBarController
            let tabs = tabBarController.viewControllers!
            let navigationController = tabs[savedTab] as! UINavigationController
            let viewControllers = navigationController.viewControllers
            
            // All reminder view controller
            let statisticsViewController = viewControllers[0] as! StatisticsViewController
            statisticsViewController.coreDataHandler = coreDataHandler
            
            // Make View Controller a delegate of the tab bar controller
            statisticsViewController.tabBarController?.delegate = statisticsViewController
            
            // Select index
            statisticsViewController.tabBarController?.selectedIndex = savedTab
        }
        
        
    
        // Set badge
        setBadgeForReminderTab()
        
//        // Create shortcut for 3D Touch
//        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
//            print("Application launched via shortcut")
//            self.shortcutItem = shortcutItem
//            shouldPerformShortcutDelegate = false
//            
//            // Create the observer before the new view controller or else shortcut won't work when launching app
//            NSNotificationCenter.defaultCenter().addObserver(
//                allRemindersViewController,
//                selector: #selector(allRemindersViewController.newReminder),
//                name: "newReminder",
//                object: nil
//            )
//            
//        }
        
        
        return shouldPerformShortcutDelegate
    }
    
    // MARK: Go to background
    
    func applicationDidEnterBackground(application: UIApplication) {
        print(#function)
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillResignActiveNotification, object: nil)
    }
    
    // MARK: Go to foreground

    func applicationWillEnterForeground(application: UIApplication) {
        print(#function)
        if notificationWentOff {
            NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillEnterForegroundNotification, object: nil)
            notificationWentOff = false
        }
        
        let allRemindersViewController = getAllRemindersViewController()
        allRemindersViewController.setUpCoreData()
        allRemindersViewController.tableView.reloadData()
       
        
        allRemindersViewController.setBadgeForTodayTab()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        print("Application did become active")
        
        guard let shortcut = shortcutItem else { return }
        
        handleShortcut(shortcut)
        
        self.shortcutItem = nil 
        
    }
    
    // MARK: Notifications

    func application(application: UIApplication,
                     handleActionWithIdentifier identifier: String?,
                     forLocalNotification notification: UILocalNotification,
                     completionHandler: () -> Void) {
        print("")
        print(#function)
        
        handleIncomingNotification(notification)
        notificationHandler.handleActionInCategory(notification, actionIdentifier: identifier!)
        
        completionHandler()
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        // Must tap notification for this or app must be running
        print("")
        print(#function)
        
        notificationWentOff = true
        
        handleIncomingNotification(notification)
        notificationHandler.recieveLocalNotificationWithState(application.applicationState)
    }
    
    // MARK: 3D Touch
    
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        print("Tapped shortcut")
        completionHandler(handleShortcut(shortcutItem))
    }
    
    // MARK: - Methods
    
    func getAllRemindersViewController() -> AllRemindersViewController {
        
        // Saved tab
        let savedTab = getSavedTab()
        
        // Tab bar controller
        let tabBarController = window!.rootViewController as! UITabBarController
        let tabs = tabBarController.viewControllers!
        let navigationController = tabs[savedTab] as! UINavigationController
        let viewControllers = navigationController.viewControllers
        
        // All reminder view controller
        let allRemindersViewController = viewControllers[0] as! AllRemindersViewController
        return allRemindersViewController
    }
    
    
    func setUpFirstTime(allRemindersViewController: AllRemindersViewController) {
        print(#function)
        
        // Core Data
        let managedObjectContext = coreDataHandler.managedObjectContext
        
        print("*** First time - Creating list")
        let list = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: managedObjectContext) as! List
        list.numberOfReminders = 0
        
        do {
            try managedObjectContext.save()
            print("Saved List")
        } catch {
            fatalCoreDataError(error)
        }
        allRemindersViewController.list = list
    }
    
    func loadList(allRemindersViewController: AllRemindersViewController) {
        print(#function)
        
        // Core Data
        let managedObjectContext = coreDataHandler.managedObjectContext
        
        
        
        print("*** Fetching list")
        let fetchRequest = NSFetchRequest()
        let entityDescription = NSEntityDescription.entityForName("List", inManagedObjectContext: managedObjectContext)
        
        fetchRequest.entity = entityDescription
        
        do {
            let result = try managedObjectContext.executeFetchRequest(fetchRequest)
            let list = result[0] as! NSManagedObject as! List
            allRemindersViewController.list = list
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    func sendReminderToController(reminder: Reminder) {
        print(#function)
        
        // Saved Tab
        let savedTab = getSavedTab()
        
        // Tab bar controller
        let tabBarController = window!.rootViewController as! UITabBarController
        let tabs = tabBarController.viewControllers!
        let navigationController = tabs[savedTab] as! UINavigationController
        let viewControllers = navigationController.viewControllers
        let allRemindersViewController = viewControllers[0] as! AllRemindersViewController
        
        // Send reminder to notification
        allRemindersViewController.reminderFromNotification = reminder
    }
    
    func handleIncomingNotification(notification: UILocalNotification) {
        print(#function)
        
        let reminderID = notificationHandler.reminderID(notification)
        let reminder = coreDataHandler.getReminderWithID(reminderID, from: "Reminder")
        sendReminderToController(reminder!)
    }
    
    func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
        print("Handling shortcut")
        var succeeded = false
        
        if shortcutItem.type == "createReminder" {
            
            NSNotificationCenter.defaultCenter().postNotificationName("newReminder", object: nil)
            print("Adding a new reminder")
            succeeded = true
        }
        
        return succeeded
    }
    
    func setBadgeForReminderTab() {
        let now = NSDate()
        
        // Tab bar controller
        let tabBarController = window!.rootViewController as! UITabBarController
        let tabs = tabBarController.viewControllers!
        let todayNavigationControlelr = tabs[0] as! UINavigationController
        
        // Core Data
        let managedObjectContext = coreDataHandler.managedObjectContext
        
        // Fetch Results
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
        
        // Count results
        let count = fetchedResultsController.fetchedObjects?.count
        
        // Update reminder tab badge
        if count != 0 {
            todayNavigationControlelr.tabBarItem.badgeValue = "\(count!)"
        } else {
            todayNavigationControlelr.tabBarItem.badgeValue = nil
        }
        
    }
}
