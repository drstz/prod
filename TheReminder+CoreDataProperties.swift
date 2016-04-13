//
//  TheReminder+CoreDataProperties.swift
//  remindMe
//
//  Created by Duane Stoltz on 13/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension TheReminder {

    @NSManaged var name: String
    @NSManaged var occurence: String
    @NSManaged var countdown: String

}
