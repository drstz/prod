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
    
    var firstTime = true

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
        
        let navigationController = window!.rootViewController as! UINavigationController
        let navigationViewControllers = navigationController.viewControllers
        let allRemindersViewController = navigationViewControllers[0] as! AllRemindersViewController
        allRemindersViewController.managedObjectContext = managedObjectContext
        
        if isFirstTime() {
            print("*** First time")
            let list = NSEntityDescription.insertNewObjectForEntityForName("List", inManagedObjectContext: managedObjectContext) as! List
            list.numberOfReminders = 0
            
            do {
                try managedObjectContext.save()
                print("Saved...")
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
        
        

        return true
    }
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        print(#function)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
    }

    func applicationWillTerminate(application: UIApplication) {
        
    }
    
    func application(application: UIApplication,
                     handleActionWithIdentifier identifier: String?,
                     forLocalNotification notification: UILocalNotification,
                     completionHandler: () -> Void) {
        
        let idFromNotification = notification.userInfo!["ReminderID"] as! Int
        
        let fetchRequest = NSFetchRequest(entityName: "Reminder")
        let predicate = NSPredicate(format: "%K == %@", "idNumber", "\(idFromNotification)" )
        fetchRequest.predicate = predicate
        
        do {
            let result = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            let reminder = result[0] as! NSManagedObject as! Reminder
            
            let navigationController = window!.rootViewController as! UINavigationController
            let navigationViewControllers = navigationController.viewControllers
            let allRemindersViewController = navigationViewControllers[0] as! AllRemindersViewController
            allRemindersViewController.reminderFromNotification = reminder
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }

        if notification.category == "CATEGORY" {
            if identifier == "Complete" {

                print("You asked to complete")
                NSNotificationCenter.defaultCenter().postNotificationName("completeReminder", object: nil)
            }
            
            if identifier == "Defer" {
                print("You asked to defer")
                NSNotificationCenter.defaultCenter().postNotificationName("deferReminder", object: nil)
            }
        }
        completionHandler()
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print(#function)
        if application.applicationState == .Inactive {
            
            print("Handling notification from the background")
            
            let idFromNotification = notification.userInfo!["ReminderID"] as! Int
            
            let fetchRequest = NSFetchRequest(entityName: "Reminder")
            let predicate = NSPredicate(format: "%K == %@", "idNumber", "\(idFromNotification)" )
            fetchRequest.predicate = predicate
            
            do {
                let result = try self.managedObjectContext.executeFetchRequest(fetchRequest)
                let reminder = result[0] as! NSManagedObject as! Reminder
                
                let navigationController = window!.rootViewController as! UINavigationController
                let navigationViewControllers = navigationController.viewControllers
                let allRemindersViewController = navigationViewControllers[0] as! AllRemindersViewController
                allRemindersViewController.reminderFromNotification = reminder
                
            } catch {
                let fetchError = error as NSError
                print(fetchError)
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName("viewReminder", object: nil)
            
            
        }
        
    }

}

