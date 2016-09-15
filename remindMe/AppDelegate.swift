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

func fatalCoreDataError(_ error: Error) {
    print("*** Fatal Error: \(error)")
    NotificationCenter.default.post(name: Notification.Name(rawValue: MyManagedObjectContextSaveDidFailNotification), object: nil)
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
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
            let statisticsViewController = viewControllers[0] as! ProductivityViewController
            statisticsViewController.coreDataHandler = coreDataHandler
            
            // Load list
            let managedObjectContext = coreDataHandler.managedObjectContext
            
            print("*** Fetching list")
            let fetchRequest = NSFetchRequest<List>(entityName: "List")
            let entityDescription = NSEntityDescription.entity(forEntityName: "List", in: managedObjectContext)
            
            fetchRequest.entity = entityDescription
            
            do {
                let result = try managedObjectContext.fetch(fetchRequest)
                let list = result[0] as NSManagedObject as! List
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
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            NSLog("Launching from shortcut")
            let allRemindersViewController = getAllRemindersViewController()
            
            // The other screens need this data
            loadList(allRemindersViewController)
            allRemindersViewController.coreDataHandler = coreDataHandler
            
            print("Application launched via shortcut")
            self.shortcutItem = shortcutItem
            shouldPerformShortcutDelegate = false
            
            // Create the observer before the new view controller or else shortcut won't work when launching app
            NotificationCenter.default.addObserver(
                allRemindersViewController,
                selector: #selector(allRemindersViewController.newReminder),
                name: NSNotification.Name(rawValue: "newReminder"),
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
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
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
    func applicationDidEnterBackground(_ application: UIApplication) {
        print(#function)
        NotificationCenter.default.post(name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    }
    
    // MARK: Go to foreground

    // This is not called when application is being launched
    // This is called when opening an application that has already been launched
    func applicationWillEnterForeground(_ application: UIApplication) {
        print(#function)
        NSLog(#function)
        if notificationWentOff {
            NotificationCenter.default.post(name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
            notificationWentOff = false
        }
        
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
    func applicationDidBecomeActive(_ application: UIApplication) {
        print(#function)
        NSLog(#function)
        
        guard let shortcut = shortcutItem else { return }
        
        handleShortcut(shortcut)
        
        self.shortcutItem = nil 
        
    }
    
    func getStatisticsViewController() -> ProductivityViewController {
        // Tab bar controller
        let tabBarController = window!.rootViewController as! UITabBarController
        let tabs = tabBarController.viewControllers!
        let navigationController = tabs[1] as! UINavigationController
        let viewControllers = navigationController.viewControllers
        
        // All reminder view controller
        let statisticsViewController = viewControllers[0] as! ProductivityViewController
        
        return statisticsViewController
    }
    
    // MARK: Notifications

    // This gets called automatically after launch even if the app is terminated.
    func application(_ application: UIApplication,
                     handleActionWithIdentifier identifier: String?,
                     for notification: UILocalNotification,
                     completionHandler: @escaping () -> Void) {
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
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        // Must tap notification for this or app must be running
        print("")
        print(#function)
        NSLog(#function)
        
        notificationWentOff = true
        let reminder = reminderFromNotification(notification)
        sendReminderToController(reminder)
        
        if application.applicationState == .inactive {
            print("Notification was tapped")
            let tab = getSavedTab()
            if tab == 1 {
                NSLog("Changing selected tab index")
                let tabBarController = window!.rootViewController as! UITabBarController
                tabBarController.selectedIndex = 0
                tabBarController.delegate = getAllRemindersViewController()
            } else {
                let allRemindersViewController = getAllRemindersViewController()
                
                // Keep reminders updated
                allRemindersViewController.tableView.reloadData()
                
                // Dismiss other screens
                if allRemindersViewController.presentedViewController != nil {
                    allRemindersViewController.dismiss(animated: true, completion: nil)
                }
            }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "viewReminder"), object: nil)
        } else {
            // Handling notification from within app
            NotificationCenter.default.post(name: Notification.Name(rawValue: "setBadgeForTodayTab"), object: nil)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "refresh"), object: nil)
        }
    }
    
    // MARK: 3D Touch
    
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        NSLog(#function)
        
        // This allows the shortcut to work, no matter which view is being presented
        // Nothing has been done yet for statistics potential presented views
        let allRemindersViewController = getAllRemindersViewController()
        if allRemindersViewController.presentedViewController != nil {
            print("Dismissing controller")
            allRemindersViewController.dismiss(animated: false, completion: nil)
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
    func setUpFirstTime(_ allRemindersViewController: AllRemindersViewController) {
        print(#function)
        
        // Core Data
        let managedObjectContext = coreDataHandler.managedObjectContext
        
        print("*** First time - Creating list")
        let list = NSEntityDescription.insertNewObject(
            forEntityName: "List",
            into: managedObjectContext
            ) as! List
        
        // Initialize
        list.numberOfReminders = 0
        list.numberOfCompletedReminders = 0
        
        list.numberOfRemindersCompletedBeforeDueDate = 0
        
        list.differenceBetweenDueCompletionDate = 0
        list.totalTimesSnoozed = 0
        
        do {
            try managedObjectContext.save()
            print("Saved List")
        } catch {
            fatalCoreDataError(error)
        }
        allRemindersViewController.list = list
    }
    
    func loadList(_ allRemindersViewController: AllRemindersViewController) {
        print(#function)
        
        // Core Data
        let managedObjectContext = coreDataHandler.managedObjectContext
        
        print("*** Fetching list")
        let fetchRequest = NSFetchRequest<List>(entityName: "List")
        let entityDescription = NSEntityDescription.entity(forEntityName: "List", in: managedObjectContext)
        
        fetchRequest.entity = entityDescription
        
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            let list = result[0] as NSManagedObject as! List
            allRemindersViewController.list = list
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    func reminderFromNotification(_ notification: UILocalNotification) -> Reminder {
        let reminderID = notificationHandler.reminderID(notification)
        let reminder = coreDataHandler.getReminderWithID(reminderID, from: "Reminder")
        return reminder!
    }
    
    /// Sends reminder to the view controller
    func sendReminderToController(_ reminder: Reminder) {
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
    
    func handleShortcut(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
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
            NotificationCenter.default.post(name: Notification.Name(rawValue: "newReminder"), object: nil)
            NSLog("Posted notification")
            print("Adding a new reminder")
            succeeded = true
        }
        NSLog("Handle shortcut success: \(succeeded)")
        
        return succeeded
    }
    
    func setBadgeForReminderTab() {
        let now = Date()
        
        // Tab bar controller
        let tabBarController = window!.rootViewController as! UITabBarController
        let tabs = tabBarController.viewControllers!
        let todayNavigationControlelr = tabs[0] as! UINavigationController
        
        // Core Data
        let managedObjectContext = coreDataHandler.managedObjectContext
        
        // Fetch Results
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
