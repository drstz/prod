//
//  CoreDataHandler.swift
//  remindMe
//
//  Created by Duane Stoltz on 26/05/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import CoreData

enum ReminderFilter {
    case Complete
    case Incomplete
    case Date
    case ID
    case None
}

class CoreDataHandler {
    
    // MARK: - Object Context
    
    var managedObjectContext: NSManagedObjectContext!
    
    var fetchedResultsController: NSFetchedResultsController!
    
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
    
    func setFetchedResultsController(entity: String, cacheName: String, filterBy filter: ReminderFilter){
        let fetchRequest = prepareFetchRequest(entity, filter: filter)
        
        let newFetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController = newFetchedResultsController
    }
    
    func prepareFetchRequest(entity: String, filter: ReminderFilter) -> NSFetchRequest {
        let fetchRequest = NSFetchRequest()
        fetchRequest.fetchBatchSize = 20
        
        setEntity(entity, fetchRequest: fetchRequest)
        setSortDescriptors(fetchRequest)
        setPredicate(fetchRequest, filter: filter)
        
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
    
    func setPredicate(fetchRequest: NSFetchRequest, filter: ReminderFilter){
        switch filter {
        case .Complete:
            let comparer = filterBy(filter)
            let predicate = NSPredicate(format: "%K == %@", comparer, true)
            fetchRequest.predicate = predicate
        case .Incomplete:
            let comparer = filterBy(filter)
            let predicate = NSPredicate(format: "%K == %@", comparer, false)
            fetchRequest.predicate = predicate
        default:
            break
        }
    }
    
    func filterBy(filter: ReminderFilter) -> String {
        switch filter {
        case .Complete, .Incomplete:
            return "isComplete"
        case .ID:
            return "idNumber"
        case .Date:
            return "dueDate"
        case .None:
            return ""
        }
    }

    // MARK: Fetching
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    // MARK: Saving / Editing
    
    func save() {
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
