//
//  CoreDataHandler.swift
//  remindMe
//
//  Created by Duane Stoltz on 26/05/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import CoreData

class CoreDataHandler {
    var managedObjectContext: NSManagedObjectContext!
    
    func setObjectContext(mObjectContext : NSManagedObjectContext) {
        managedObjectContext = mObjectContext
    }
    
    func getReminderWithID(idFromNotification : Int) -> Reminder? {
        let fetchRequest = NSFetchRequest(entityName: "Reminder")
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
    
    
}
