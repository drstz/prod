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
    
    // MARK: - CoreData
    
    lazy var managedObjectContext:NSManagedObjectContext = {
        // Here you create an NSURL object pointing at this the DataModel.momd folder
        guard let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") else {
            fatalError("Could not find data model in app bundle")
        }
        // You create an NSManagadObjectmodel from the URL. This represents the data during runtime
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing model from: \(modelURL)")
        }
        // Data is stored in an SQLite database inside the app's documents folder. Here you create an NSURL pointing at the DataStore.sqlite file
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        let documentsDirectory = urls[0]
        
        let storeURL = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
        
        do {
            // This object is in charge of the SQLITE database
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            // The databse is added to the coordinator
            let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options)
            // The NSManagedObjectContext is created and returned
            let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            
            context.persistentStoreCoordinator = coordinator
            return context
        } catch {
            fatalError("Error adding persistent store at \(storeURL): \(error)")
        }
        
    }()
    
    // MARK: - Application
    
    // MARK: Launch
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        print(#function)
        // User Defaults
        registerDefaults()
        
        // Core Data
        coreDataHandler.setObjectContext(managedObjectContext)
        
        // Shortcut
        var shouldPerformShortcutDelegate = true
        
        // Saved Tab
        let savedTab = getSavedTab()
        
        // Tab bar controller
        let tabBarController = window!.rootViewController as! UITabBarController
        
        // Transfer data
        let allRemindersViewController = getAllRemindersViewController()
        
        allRemindersViewController.managedObjectContext = managedObjectContext
        allRemindersViewController.myTabIndex = savedTab
        
        
        tabBarController.delegate = allRemindersViewController
        
        allRemindersViewController.myTabBarController = tabBarController
        
        if isFirstTime() {
            setUpFirstTime(allRemindersViewController)
        } else {
            loadList(allRemindersViewController)
        }
        
        tabBarController.selectedIndex = savedTab
    
        setBadgeForTodayTab()
        
        
        // Create shortcut for 3D Touch
        
        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
            print("Application launched via shortcut")
            self.shortcutItem = shortcutItem
            shouldPerformShortcutDelegate = false
            
            // Create the observer before the new view controller or else shortcut won't work when launching app
            NSNotificationCenter.defaultCenter().addObserver(allRemindersViewController, selector: #selector(allRemindersViewController.newReminder), name: "newReminder", object: nil)
            
        }
        
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
        let savedTab = getSavedTab()
        
        let tabBarController = window!.rootViewController as! UITabBarController
        let tabs = tabBarController.viewControllers!
        let navigationController = tabs[savedTab] as! UINavigationController
        let viewControllers = navigationController.viewControllers
        let allRemindersViewController = viewControllers[0] as! AllRemindersViewController
        return allRemindersViewController
    }
    
    
    func setUpFirstTime(allRemindersViewController: AllRemindersViewController) {
        print(#function)
        
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
        
        let tabBarController = window!.rootViewController as! UITabBarController
        let tabs = tabBarController.viewControllers!
        let savedTab = getSavedTab()
        
        
        let navigationController = tabs[savedTab] as! UINavigationController
        let viewControllers = navigationController.viewControllers
        let allRemindersViewController = viewControllers[0] as! AllRemindersViewController
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
    
    func setBadgeForTodayTab() {
        let now = NSDate()
        
        let tabBarController = window!.rootViewController as! UITabBarController
        let tabs = tabBarController.viewControllers!
        let todayNavigationControlelr = tabs[0] as! UINavigationController
        
        
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
        todayNavigationControlelr.tabBarItem.badgeValue = "\(count!)"
    }
}
