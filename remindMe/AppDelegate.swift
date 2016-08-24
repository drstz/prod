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
        NSLog(#function)
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
            let navigationController = tabs[1] as! UINavigationController
            let viewControllers = navigationController.viewControllers
            
            // All reminder view controller
            let statisticsViewController = viewControllers[0] as! StatisticsViewController
            statisticsViewController.coreDataHandler = coreDataHandler
            
            // Load list
            let managedObjectContext = coreDataHandler.managedObjectContext
            
            print("*** Fetching list")
            let fetchRequest = NSFetchRequest()
            let entityDescription = NSEntityDescription.entityForName("List", inManagedObjectContext: managedObjectContext)
            
            fetchRequest.entity = entityDescription
            
            do {
                let result = try managedObjectContext.executeFetchRequest(fetchRequest)
                let list = result[0] as! NSManagedObject as! List
                statisticsViewController.list = list
            } catch {
                let fetchError = error as NSError
                print(fetchError)
            }
            
            // Make View Controller a delegate of the tab bar controller
            statisticsViewController.tabBarController?.delegate = statisticsViewController
            
            // Select index
            statisticsViewController.tabBarController?.selectedIndex = savedTab
        }
        
        // Set badge
        setBadgeForReminderTab()
        
        // When launching app from a reminder action
        // Set observers to allow viewing action to work
        let allRemindersViewController = getAllRemindersViewController()
        if !allRemindersViewController.observersAreSet {
            allRemindersViewController.addObservers()
            allRemindersViewController.observersAreSet = true
        }
        
        // Create shortcut for 3D Touch
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            NSLog("Launching from shortcut")
            let allRemindersViewController = getAllRemindersViewController()
            
            // The other screens need this data
            loadList(allRemindersViewController)
            allRemindersViewController.coreDataHandler = coreDataHandler
            
            print("Application launched via shortcut")
            self.shortcutItem = shortcutItem
            shouldPerformShortcutDelegate = false
            
            // Create the observer before the new view controller or else shortcut won't work when launching app
            NSNotificationCenter.defaultCenter().addObserver(
                allRemindersViewController,
                selector: #selector(allRemindersViewController.newReminder),
                name: "newReminder",
                object: nil
            )
            
            if getSavedTab() == 1 {
                
                let tabBarController = window!.rootViewController as! UITabBarController
                tabBarController.selectedIndex = 0
                tabBarController.delegate = getAllRemindersViewController()
            }
        }

        // This doesn't get called when actions are chosen
        // This only gets called if app is launched after tapping a notification
        if let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            NSLog("App delegate has notification")
            let reminder = reminderFromNotification(notification)
            sendReminderToController(reminder)
            
            if getSavedTab() == 1 {
                NSLog("Changing selected tab index")
                let tabBarController = window!.rootViewController as! UITabBarController
                tabBarController.selectedIndex = 0
                tabBarController.delegate = getAllRemindersViewController()
                let allRemindersViewController = getAllRemindersViewController()
                
                // Do this or else all reminders won't have a handler
                allRemindersViewController.coreDataHandler = coreDataHandler
                allRemindersViewController.notificationWasTapped = true
                
                // NSNotificationCenter.defaultCenter().postNotificationName("viewReminder", object: nil)
            } else {
               allRemindersViewController.notificationWasTapped = true
            }
            
        }

        return shouldPerformShortcutDelegate
    }
    
    // MARK: Go to background
    
    // Home button
    func applicationDidEnterBackground(application: UIApplication) {
        print(#function)
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillResignActiveNotification, object: nil)
    }
    
    // MARK: Go to foreground

    // This is not called when application is being launched
    // This is called when opening an application that has already been launched
    func applicationWillEnterForeground(application: UIApplication) {
        print(#function)
        NSLog(#function)
        if notificationWentOff {
            NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillEnterForegroundNotification, object: nil)
            notificationWentOff = false
        }
        let statisticsViewController = getStatisticsViewController()
        let allRemindersViewController = getAllRemindersViewController()
        
        
        
        // Share the same manager?
        allRemindersViewController.coreDataHandler = coreDataHandler
        allRemindersViewController.setUpCoreData()
        // allRemindersViewController.tableView.reloadData()
       
        
        allRemindersViewController.setBadgeForTodayTab()
        
        // Update popup if it is already being presented
        let tab = getSavedTab()
        if tab == 0 {
            let presentedViewController = allRemindersViewController.presentedViewController
            if presentedViewController == presentedViewController as? PopupViewController {
                if let popupViewController = presentedViewController as? PopupViewController {
                    popupViewController.updatePopup()
                }
                print("Presenting popup")
            } else {
                print("Not presenting popup")
                print("Presenting: \(presentedViewController)")
            }
        }
    }
    
    // This is called at launch
    // This is called when opening an application that has already been launched
    func applicationDidBecomeActive(application: UIApplication) {
        print(#function)
        NSLog(#function)
        
        guard let shortcut = shortcutItem else { return }
        
        handleShortcut(shortcut)
        
        self.shortcutItem = nil 
        
    }
    
    func getStatisticsViewController() -> StatisticsViewController {
        // Tab bar controller
        let tabBarController = window!.rootViewController as! UITabBarController
        let tabs = tabBarController.viewControllers!
        let navigationController = tabs[1] as! UINavigationController
        let viewControllers = navigationController.viewControllers
        
        // All reminder view controller
        let statisticsViewController = viewControllers[0] as! StatisticsViewController
        
        return statisticsViewController
    }
    
    // MARK: Notifications

    // This gets called automatically after launch even if the app is terminated.
    func application(application: UIApplication,
                     handleActionWithIdentifier identifier: String?,
                     forLocalNotification notification: UILocalNotification,
                     completionHandler: () -> Void) {
        print("")
        print(#function)
        NSLog(#function)
        
        let reminder = reminderFromNotification(notification)
        // sendReminderToController(reminder)
        
        //notificationHandler.handleActionInCategory(notification, actionIdentifier: identifier!)
        
        notificationHandler.handleAction(reminder, category: notification.category!, identifier: identifier!)
        coreDataHandler.save()
        
        completionHandler()
    }
    
    // App must be running for this to go off
    // Does not go off is app is terminated
    // Does go off if app is in background
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        // Must tap notification for this or app must be running
        print("")
        print(#function)
        NSLog(#function)
        
        notificationWentOff = true
        let reminder = reminderFromNotification(notification)
        sendReminderToController(reminder)
        
        if application.applicationState == .Inactive {
            print("Notification was tapped")
            
            if getSavedTab() == 1 {
                NSLog("Changing selected tab index")
                let tabBarController = window!.rootViewController as! UITabBarController
                tabBarController.selectedIndex = 0
                tabBarController.delegate = getAllRemindersViewController()
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName("viewReminder", object: nil)
        } else {
            // Handling notification from within app
            NSNotificationCenter.defaultCenter().postNotificationName("setBadgeForTodayTab", object: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("refresh", object: nil)
        }
    }
    
    // MARK: 3D Touch
    
    func application(application: UIApplication,
                     performActionForShortcutItem shortcutItem: UIApplicationShortcutItem,
                     completionHandler: (Bool) -> Void) {
        NSLog(#function)
        
        // This allows the shortcut to work, no matter which view is being presented
        // Nothing has been done yet for statistics potential presented views
        let allRemindersViewController = getAllRemindersViewController()
        if allRemindersViewController.presentedViewController != nil {
            print("Dismissing controller")
            allRemindersViewController.dismissViewControllerAnimated(false, completion: nil)
        }
        completionHandler(handleShortcut(shortcutItem))
    }
    
    // MARK: - Methods
    
    func getAllRemindersViewController() -> AllRemindersViewController {
        
        // Tab bar controller
        let tabBarController = window!.rootViewController as! UITabBarController
        let tabs = tabBarController.viewControllers!
        let navigationController = tabs[0] as! UINavigationController
        let viewControllers = navigationController.viewControllers
        
        // All reminder view controller
        let allRemindersViewController = viewControllers[0] as! AllRemindersViewController
        return allRemindersViewController
    }
    
    /// Creates the list variable that will be used to create and number reminders
    func setUpFirstTime(allRemindersViewController: AllRemindersViewController) {
        print(#function)
        
        // Core Data
        let managedObjectContext = coreDataHandler.managedObjectContext
        
        print("*** First time - Creating list")
        let list = NSEntityDescription.insertNewObjectForEntityForName(
            "List",
            inManagedObjectContext: managedObjectContext
            ) as! List
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
    
    
    
    func reminderFromNotification(notification: UILocalNotification) -> Reminder {
        let reminderID = notificationHandler.reminderID(notification)
        let reminder = coreDataHandler.getReminderWithID(reminderID, from: "Reminder")
        return reminder!
    }
    
    /// Sends reminder to the view controller
    func sendReminderToController(reminder: Reminder) {
        print(#function)
        
        // Saved Tab
        // let savedTab = getSavedTab()
        
        // Tab bar controller
        let tabBarController = window!.rootViewController as! UITabBarController
        let tabs = tabBarController.viewControllers!
        let navigationController = tabs[0] as! UINavigationController
        let viewControllers = navigationController.viewControllers
        let allRemindersViewController = viewControllers[0] as! AllRemindersViewController
        
        // Send reminder to notification
        allRemindersViewController.reminderFromNotification = reminder
    }
    
    func handleShortcut(shortcutItem: UIApplicationShortcutItem) -> Bool {
        NSLog(#function)
        print("Handling shortcut")
        var succeeded = false
        
        if shortcutItem.type == "createReminder" {
            NSLog("Shortcut type is Create Reminder")
            
            if getSavedTab() == 1 {
                NSLog("Shortcut = Tab is 1 ")
                let tabBarController = window!.rootViewController as! UITabBarController
                NSLog("Shortcut: recovered tab bar controller")
                tabBarController.selectedIndex = 0
                tabBarController.delegate = getAllRemindersViewController()
            }
            
            NSLog("Posting notification")
            NSNotificationCenter.defaultCenter().postNotificationName("newReminder", object: nil)
            NSLog("Posted notification")
            print("Adding a new reminder")
            succeeded = true
        }
        NSLog("Handle shortcut success: \(succeeded)")
        
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
