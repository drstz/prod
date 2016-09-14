//
//  CoreDataHandler.swift
//  remindMe
//
//  Created by Duane Stoltz on 26/05/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import CoreData

enum ReminderFilter: String {
    case Favorite
    case All
    case Today
    case Week
    case NoFavorites
}

enum ReminderStatus {
    case Complete
    case Incomplete
}

class CoreDataHandler {
    
    // MARK: - Object Context
    
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
    
    var fetchedResultsController: NSFetchedResultsController!
    
    deinit {
        print("")
        print(#function)
        print("Coredata handler was deallocated")
    }
    
    // MARK: - Methods
    
    func setObjectContext(mObjectContext : NSManagedObjectContext) {
        managedObjectContext = mObjectContext
    }
    
    // MARK: Search Reminder
    
    func getReminderWithID(idFromNotification : Int, from entity: String) -> Reminder? {
        
        let fetchRequest = NSFetchRequest(entityName: entity)
        
        let predicate = NSPredicate(format: "%K == %@", "idNumber", "\(idFromNotification)" )
        fetchRequest.predicate = predicate
        
        var reminder: Reminder?
        
        do {
            let result = try self.managedObjectContext.executeFetchRequest(fetchRequest)
            reminder = result[0] as! NSManagedObject as? Reminder
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return reminder
    }
    
    func reminderFromIndexPath(indexPath: NSIndexPath) -> Reminder {
        let reminder = fetchedResultsController.objectAtIndexPath(indexPath) as! Reminder
        
        return reminder
    }
    
    // MARK: Fetch Request
    
    func setFetchedResultsController(entity: String, cacheName: String, filterBy filter: ReminderFilter, status: ReminderStatus){
        let fetchRequest = prepareFetchRequest(entity, filter: filter, status: status)
        
        let newFetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            // This allows the app to seperate reminders into sections
            sectionNameKeyPath: "section",
            cacheName: nil
        )
        
        fetchedResultsController = newFetchedResultsController
    }
    
    func prepareFetchRequest(entity: String, filter: ReminderFilter, status: ReminderStatus) -> NSFetchRequest {
        let fetchRequest = NSFetchRequest()
        fetchRequest.fetchBatchSize = 20
        
        setEntity(entity, fetchRequest: fetchRequest)
        setSortDescriptors(fetchRequest)
        setPredicate(fetchRequest, filter: filter, status: status)
        
        return fetchRequest
    }
    
    func setEntity(entity: String, fetchRequest: NSFetchRequest) {
        let entity = NSEntityDescription.entityForName(entity, inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
    }
    
    func setSortDescriptors(fetchRequest: NSFetchRequest) {
        let sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
    }
    
    func setPredicate(fetchRequest: NSFetchRequest, filter: ReminderFilter, status: ReminderStatus){
        let parameter = filterBy(filter)
        let statusString = filterStatus(status)

        switch filter {
        case .All:
            switch status {
            case .Complete:
                let predicate = NSPredicate(format: "%K == %@", statusString, true)
                fetchRequest.predicate = predicate
            case .Incomplete:
                let predicate = NSPredicate(format: "%K == %@", statusString, false)
                fetchRequest.predicate = predicate
            }
        case .Favorite:
            switch status {
            case .Complete:
                let predicate = NSPredicate(format: "%K == %@ AND %K == %@", statusString, true, parameter, true)
                fetchRequest.predicate = predicate
            case .Incomplete:
                let predicate = NSPredicate(format: "%K == %@ AND %K == %@", statusString, false, parameter, true)
                fetchRequest.predicate = predicate
            }
        case .NoFavorites:
            switch status {
            case .Complete:
                let predicate = NSPredicate(format: "%K == %@ AND %K == %@", statusString, true, parameter, false)
                fetchRequest.predicate = predicate
            case .Incomplete:
                let predicate = NSPredicate(format: "%K == %@ AND %K == %@", statusString, false, parameter, false)
                fetchRequest.predicate = predicate
            }
        case .Today:
            let today = NSDate()
            switch status {
                
            case .Complete:
                let predicate = NSPredicate(
                    format: "%K == %@ AND ((%K <= %@ AND %K >= %@))",
                    statusString, true,
                    parameter, today.endOfDay,
                    parameter, today.startOfDay
                )
                fetchRequest.predicate = predicate
            case .Incomplete:
                let predicate = NSPredicate(
                    format: "%K == %@ AND ((%K <= %@ AND %K >= %@) OR %K <= %@)",
                    statusString, false,
                    parameter, today.endOfDay,
                    parameter, today.startOfDay,
                    parameter, today
                )
                fetchRequest.predicate = predicate
            }
        case .Week:
            let today = NSDate()
            switch status {
                
            case .Complete:
                let predicate = NSPredicate(
                    format: "%K == %@ AND (%K <= %@ AND %K >= %@)",
                    statusString, true,
                    parameter, nextSevenDays(),
                    parameter, today.startOfDay
                )
                fetchRequest.predicate = predicate
            case .Incomplete:
                let predicate = NSPredicate(
                    format: "%K == %@ AND ((%K <= %@ AND %K >= %@) OR %K <= %@)",
                    statusString, false,
                    parameter, nextSevenDays(),
                    parameter, today.startOfDay,
                    parameter, today
                )
                fetchRequest.predicate = predicate
            }
        }
    }
    
    func filterBy(filter: ReminderFilter) -> String {
        switch filter {
        case .Favorite, .NoFavorites:
            return "isFavorite"
        case .Today, .Week:
            return "dueDate"
        default:
            return ""
        }
    }
    
    func filterStatus(status: ReminderStatus) -> String {
        switch status {
        case .Complete, .Incomplete:
            return "wasCompleted"
        }
    }

    // MARK: Fetching
    
    func performFetch() {
        print(#function)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    // MARK: Saving / Editing
    
    func save() {
        print(#function)
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    func delete(reminder: Reminder) {
        managedObjectContext.deleteObject(reminder)
    }

}
