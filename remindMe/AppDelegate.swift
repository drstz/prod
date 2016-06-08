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
    
    // MARK: - CoreData
    
    lazy var managedObjectContext:NSManagedObjectContext = {
        // 1
        // Here you create an NSURL object pointing at this the DataModel.momd folder
        guard let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") else {
            fatalError("Could not find data model in app bundle")
        }
        // 2
        // You create an NSManagadObjectmodel from the URL. This represents the data during runtime
        guard let model = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing model from: \(modelURL)")
        }
        // 3
        // Data is stored in an SQLite database inside the app's documents folder. Here you create an NSURL pointing at the DataStore.sqlite file
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        let documentsDirectory = urls[0]
        
        let storeURL = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
        
        do {
            // 4
            // This object is in charge of the SQLITE database
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            // 5
            // The databse is added to the coordinator
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            // 6
            // The NSManagedObjectContext is created and returned
            let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            
            context.persistentStoreCoordinator = coordinator
            return context
        // 7
        } catch {
            fatalError("Error adding persistent store at \(storeURL): \(error)")
        }
        
    }()
    
    // MARK: - The Rest


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        print(#function)
        registerDefaults()
        
        coreDataHandler.setObjectContext(managedObjectContext)
        
        let tabBarController = window!.rootViewController as! UITabBarController
        let tabs = tabBarController.viewControllers!
        print("There are \(tabs.count) tabs")
        
        for index in 0..<tabs.count {
            let navigationController = tabs[index] as! UINavigationController
            let viewControllers = navigationController.viewControllers
            let allRemindersViewController = viewControllers[0] as! AllRemindersViewController
            allRemindersViewController.managedObjectContext = managedObjectContext
            tabBarController.delegate = allRemindersViewController
            allRemindersViewController.myTabBarController = tabBarController
            
            if isFirstTime() {
                print("*** First time - Creating list")
                let list = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: managedObjectContext) as! List
                list.numberOfReminders = 0
                
                do {
                    try managedObjectContext.save()
                    print("Saved List")
                    print(list.numberOfReminders)
                } catch {
                    fatalCoreDataError(error)
                }
                allRemindersViewController.list = list
                
            } else {
                print("*** Fetching list")
                let fetchRequest = NSFetchRequest()
                let entityDescription = NSEntityDescription.entityForName("List", inManagedObjectContext: managedObjectContext)
                
                fetchRequest.entity = entityDescription
                
                do {
                    let result = try managedObjectContext.executeFetchRequest(fetchRequest)
                    let list = result[0] as! NSManagedObject as! List
                    print(list.numberOfReminders)
                    allRemindersViewController.list = list
                } catch {
                    let fetchError = error as NSError
                    print(fetchError)
                }
            }
        }
        return true
    }
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillResignActiveNotification, object: nil)
    }

    func applicationWillEnterForeground(application: UIApplication) {
        if notificationWentOff {
            NSNotificationCenter.defaultCenter().postNotificationName(UIApplicationWillEnterForegroundNotification, object: nil)
            notificationWentOff = false
        }
    }

    func application(application: UIApplication,
                     handleActionWithIdentifier identifier: String?,
                     forLocalNotification notification: UILocalNotification,
                     completionHandler: () -> Void) {
        
        handleIncomingNotification(notification)
        notificationHandler.handleActionInCategory(notification, actionIdentifier: identifier!)
        
        completionHandler()
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        notificationWentOff = true
        
        handleIncomingNotification(notification)
        notificationHandler.recieveLocalNotificationWithState(application.applicationState)
    }
    
    func sendReminderToController(reminder: Reminder) {
        let tabBarController = window!.rootViewController as! UITabBarController
        let tabs = tabBarController.viewControllers!
        
        for index in 0..<tabs.count {
            let navigationController = tabs[index] as! UINavigationController
            let viewControllers = navigationController.viewControllers
            let allRemindersViewController = viewControllers[0] as! AllRemindersViewController
            allRemindersViewController.reminderFromNotification = reminder
            
            
        }
    }
    
    func handleIncomingNotification(notification: UILocalNotification) {
        let reminderID = notificationHandler.reminderID(notification)
        let reminder = coreDataHandler.getReminderWithID(reminderID, from: "Reminder")
        sendReminderToController(reminder!)
    }
    
    
}
