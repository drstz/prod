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
    case complete
    case incomplete
}

enum FetchingError: Error {
    case cannotRetrieveReminder
}

class CoreDataHandler {
    
    // MARK: - Object Context
    
    lazy var managedObjectContext:NSManagedObjectContext = {
        // Here you create an NSURL object pointing at this the DataModel.momd folder
        guard let modelURL = Bundle.main.url(forResource: "DataModel", withExtension: "momd") else {
            fatalError("Could not find data model in app bundle")
        }
        // You create an NSManagadObjectmodel from the URL. This represents the data during runtime
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing model from: \(modelURL)")
        }
        // Data is stored in an SQLite database inside the app's documents folder. Here you create an NSURL pointing at the DataStore.sqlite file
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let documentsDirectory = urls[0]
        
        let storeURL = documentsDirectory.appendingPathComponent("DataStore.sqlite")
        
        do {
            // This object is in charge of the SQLITE database
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            // The databse is added to the coordinator
            let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
            // The NSManagedObjectContext is created and returned
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            
            context.persistentStoreCoordinator = coordinator
            return context
        } catch {
            fatalError("Error adding persistent store at \(storeURL): \(error)")
        }
    }()
    
    var fetchedResultsController: NSFetchedResultsController<Reminder>?
    
    deinit {
        print("")
        print(#function)
        print("Coredata handler was deallocated")
    }
    
    // MARK: - Methods
    
    func setObjectContext(_ mObjectContext : NSManagedObjectContext) {
        managedObjectContext = mObjectContext
    }
    
    // MARK: Search Reminder
    
    func getReminderWithID(_ idFromNotification : Int, from entity: String) -> Reminder? {
        
        let fetchRequest = NSFetchRequest<Reminder>(entityName: entity)
        
        let predicate = NSPredicate(format: "%K == %@", "idNumber", "\(idFromNotification)" )
        fetchRequest.predicate = predicate
        
        var reminder: Reminder?
        
        do {
            let result = try self.managedObjectContext.fetch(fetchRequest)
            reminder = result[0] as NSManagedObject as? Reminder
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
        return reminder
    }
    
    func reminderFromIndexPath(_ indexPath: IndexPath) -> Reminder {
        print(fetchedResultsController.debugDescription)
        let reminder = fetchedResultsController?.object(at: indexPath)
        return reminder!
    }
    
    // MARK: Fetch Request
    
    func setFetchedResultsController(_ entity: String, cacheName: String, filterBy filter: ReminderFilter, status: ReminderStatus){
        let fetchRequest = prepareFetchRequest(entity, filter: filter, status: status)
        
        let newFetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            // This allows the app to seperate reminders into sections
            sectionNameKeyPath: nil, // Switch to "section" when ready
            cacheName: nil
        )
        
        fetchedResultsController = newFetchedResultsController
    }
    
    func prepareFetchRequest(_ entity: String, filter: ReminderFilter, status: ReminderStatus) -> NSFetchRequest<Reminder> {
        let fetchRequest = NSFetchRequest<Reminder>(entityName: entity)
        fetchRequest.fetchBatchSize = 20
        
        setEntity(entity, fetchRequest: fetchRequest)
        setSortDescriptors(fetchRequest)
        setPredicate(fetchRequest, filter: filter, status: status)
        
        return fetchRequest
    }
    
    func setEntity(_ entity: String, fetchRequest: NSFetchRequest<Reminder>) {
        let entity = NSEntityDescription.entity(forEntityName: entity, in: managedObjectContext)
        fetchRequest.entity = entity
    }
    
    func setSortDescriptors(_ fetchRequest: NSFetchRequest<Reminder>) {
        let sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
    }
    
    func setPredicate(_ fetchRequest: NSFetchRequest<Reminder>, filter: ReminderFilter, status: ReminderStatus){
        let parameter = filterBy(filter)
        let statusString = filterStatus(status)

        switch filter {
        case .All:
            switch status {
            case .complete:
                let predicate = NSPredicate(format: "%K == %@", statusString, true as CVarArg)
                fetchRequest.predicate = predicate
            case .incomplete:
                let predicate = NSPredicate(format: "%K == %@", statusString, false as CVarArg)
                fetchRequest.predicate = predicate
            }
        case .Favorite:
            switch status {
            case .complete:
                let predicate = NSPredicate(format: "%K == %@ AND %K == %@", statusString, true as CVarArg, parameter, true as CVarArg)
                fetchRequest.predicate = predicate
            case .incomplete:
                let predicate = NSPredicate(format: "%K == %@ AND %K == %@", statusString, false as CVarArg, parameter, true as CVarArg)
                fetchRequest.predicate = predicate
            }
        case .NoFavorites:
            switch status {
            case .complete:
                let predicate = NSPredicate(format: "%K == %@ AND %K == %@", statusString, true as CVarArg, parameter, false as CVarArg)
                fetchRequest.predicate = predicate
            case .incomplete:
                let predicate = NSPredicate(format: "%K == %@ AND %K == %@", statusString, false as CVarArg, parameter, false as CVarArg)
                fetchRequest.predicate = predicate
            }
        case .Today:
            let today = Date()
            switch status {
                
            case .complete:
                let predicate = NSPredicate(
                    format: "%K == %@ AND ((%K <= %@ AND %K >= %@))",
                    statusString, true as CVarArg,
                    parameter, today.endOfDay as CVarArg,
                    parameter, today.startOfDay as CVarArg
                )
                fetchRequest.predicate = predicate
            case .incomplete:
                let predicate = NSPredicate(
                    format: "%K == %@ AND ((%K <= %@ AND %K >= %@) OR %K <= %@)",
                    statusString, false as CVarArg,
                    parameter, today.endOfDay as CVarArg,
                    parameter, today.startOfDay as CVarArg,
                    parameter, today as CVarArg
                )
                fetchRequest.predicate = predicate
            }
        case .Week:
            let today = Date()
            switch status {
                
            case .complete:
                let predicate = NSPredicate(
                    format: "%K == %@ AND (%K <= %@ AND %K >= %@)",
                    statusString, true as CVarArg,
                    parameter, nextSevenDays() as CVarArg,
                    parameter, today.startOfDay as CVarArg
                )
                fetchRequest.predicate = predicate
            case .incomplete:
                let predicate = NSPredicate(
                    format: "%K == %@ AND ((%K <= %@ AND %K >= %@) OR %K <= %@)",
                    statusString, false as CVarArg,
                    parameter, nextSevenDays() as CVarArg,
                    parameter, today.startOfDay as CVarArg,
                    parameter, today as CVarArg
                )
                fetchRequest.predicate = predicate
            }
        }
    }
    
    func filterBy(_ filter: ReminderFilter) -> String {
        switch filter {
        case .Favorite, .NoFavorites:
            return "isFavorite"
        case .Today, .Week:
            return "dueDate"
        default:
            return ""
        }
    }
    
    func filterStatus(_ status: ReminderStatus) -> String {
        switch status {
        case .complete, .incomplete:
            return "wasCompleted"
        }
    }

    // MARK: Fetching
    
    func performFetch() {
        print(#function)
        do {
            try fetchedResultsController?.performFetch()
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
    
    func delete(_ reminder: Reminder) {
        managedObjectContext.delete(reminder)
    }

}
