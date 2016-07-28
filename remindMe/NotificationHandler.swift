//
//  NotificationHandler.swift
//  remindMe
//
//  Created by Duane Stoltz on 26/05/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import UIKit

class NotificationHandler {
    
    deinit {
        print("")
        print(#function)
        print("Notification Handler was deallocated")
    }
    
    // MARK: - Basic Set-Up
    
    func setNotifications() {
        let actions = setNotificationActions()
        let categories = setNotificationCategories(actions)
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories:  categories)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    func setNotificationActions() -> [UIMutableUserNotificationAction]  {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let time = userDefaults.objectForKey("SnoozeUnit") as! String
        let snoozeDuration = userDefaults.doubleForKey("SnoozeDuration")
        let deferAmount = getDeferString(time, duration: snoozeDuration)
        
        let completeAction = UIMutableUserNotificationAction()
        completeAction.identifier = "Complete"
        completeAction.title = "Complete"
        completeAction.activationMode = UIUserNotificationActivationMode.Background
        completeAction.authenticationRequired = false
        completeAction.destructive = false
        
        let deferAction = UIMutableUserNotificationAction()
        deferAction.identifier = "Defer"
        deferAction.title = deferAmount
        deferAction.activationMode = UIUserNotificationActivationMode.Background
        deferAction.authenticationRequired = false
        deferAction.destructive = false
        
        let actions = [completeAction, deferAction]
        
        return actions
    }
    
    func getDeferString(deferAmount: String, duration: Double) -> String {
        let unit = SnoozeUnit(rawValue: deferAmount)
        var unitString = ""
        switch unit! {
        case .Seconds:
            unitString = "s"
        case .Minutes:
            unitString = "min"
        case .Days:
            if duration > 1 {
                unitString = "days"
            } else {
                unitString = "day"
            }
        case .Hours:
            unitString = "h"
        }
        
        return "+\(Int(duration))" + unitString
        
    }
    
    func setNotificationCategories(actions : [UIMutableUserNotificationAction]) -> Set<UIMutableUserNotificationCategory>  {
        print(#function)
        
        let category = UIMutableUserNotificationCategory()
        
        category.identifier = "Category"
        category.setActions(actions, forContext: UIUserNotificationActionContext.Default)
        category.setActions(actions, forContext: UIUserNotificationActionContext.Minimal)
        
        var categoriesForSettings = Set<UIMutableUserNotificationCategory>()
        categoriesForSettings.insert(category)
        
        return categoriesForSettings
    }
    
    // MARK: - Handling Notifications
    
    func scheduleNotifications(reminder: Reminder, snooze isBeingDeferred: Bool = false) {
        print(#function)
        var localNotification = UILocalNotification()
        
        deleteReminderNotifications(reminder)
        
        let now = NSDate()
        let earlierDate = reminder.dueDate.earlierDate(now)
        
        if earlierDate == now {
            if isBeingDeferred {
                print("Snoozing notification for \(reminder.name)")
                localNotification = snoozeNotification()
            } else {
                print("Setting notification for \(reminder.name)")
                localNotification = scheduleNotification(forDate: reminder.dueDate)
            }
            localNotification = setNotificationSettings(localNotification, reminder: reminder)
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            
            let numberOfNotifications = countAllNotifications()
            print("Total of \(numberOfNotifications) notifications" )
        } else {
            print("No notification was set")
        }
    }
    
//    func deferNotification() -> UILocalNotification {
//        print(#function)
//        let userDefaults = NSUserDefaults.standardUserDefaults()
//        let time = userDefaults.objectForKey("SnoozeTime") as! String
//        let deferAmount = getDeferAmount(time)
//        
//        let localNotification = UILocalNotification()
//        localNotification.fireDate = NSDate(timeIntervalSinceNow: deferAmount)
//        
//        setAutoSnooze(localNotification)
//        
//        return localNotification
//    }
    
    func snoozeNotification() -> UILocalNotification {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let chosenDuration = userDefaults.doubleForKey("SnoozeDuration")
        let snoozeUnit = userDefaults.objectForKey("SnoozeUnit") as! String
        let unit = SnoozeUnit(rawValue: snoozeUnit)
        
        let duration = snoozeDuration(chosenDuration, unit: unit!)
        
        let localNotification = UILocalNotification()
        localNotification.fireDate = NSDate(timeIntervalSinceNow: duration)
        
        return localNotification
    }
    
    func scheduleNotification(forDate date: NSDate) -> UILocalNotification {
        print(#function)
        let dueDate = date
        
        let localNotification = UILocalNotification()
        localNotification.fireDate = dueDate
        
        setAutoSnooze(localNotification)
        
        return localNotification
        
    }
    
    func setAutoSnooze(notification: UILocalNotification) {
        print(#function)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let autoSnoozeOn = userDefaults.boolForKey("AutoSnoozeEnabled")
        if autoSnoozeOn {
            let anInterval = userDefaults.objectForKey("AutoSnoozeTime") as! String
            let repeatInterval = getRepeatInterval(anInterval)
            notification.repeatInterval = repeatInterval
        }
        
    }
    
    func getRepeatInterval(repeatInterval: String) -> NSCalendarUnit {
        switch repeatInterval {
        case "1 minute":
            return .Minute
        case "1 hour":
            return .Hour
        default:
            return .Month
        }
    }
    
    func setNotificationSettings(notification: UILocalNotification, reminder: Reminder) -> UILocalNotification {
        let localNotification = notification
        
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        
        localNotification.alertBody = reminder.name
        localNotification.alertTitle = reminder.name
        
        localNotification.category = "Category"
        localNotification.soundName = UILocalNotificationDefaultSoundName
        
        localNotification.userInfo = ["ReminderID": reminder.idNumber]
        
        return localNotification
    }

    func deleteReminderNotifications(reminder: Reminder)  {
        let notifications = notificationsForReminder(reminder)
        
        for notification in notifications {
            UIApplication.sharedApplication().cancelLocalNotification(notification)
            print("Deleted notification for \(reminder.name)")
        }
        
        let numberOfNotifications = countReminderNotifications(reminder)
        print("\(numberOfNotifications) notifications for \(reminder.name)")
    }
    
    func allNotifications() -> [UILocalNotification] {
        let allNotifications = UIApplication.sharedApplication().scheduledLocalNotifications!
        return allNotifications
    }
    
    func notificationsForReminder(reminder: Reminder) -> [UILocalNotification] {
        let notifications = allNotifications()
        var notificationsForReminder = [UILocalNotification]()
        
        for notification in notifications {
            if let reminderID = notification.userInfo?["ReminderID"] as? Int where reminderID == reminder.idNumber {
                notificationsForReminder.append(notification)
            }
        }
        return notificationsForReminder
    }
    
    func countReminderNotifications(reminder: Reminder) -> Int {
        let notifications = notificationsForReminder(reminder)
        return notifications.count
    }
    
    func countAllNotifications() -> Int {
        let notifications = allNotifications()
        return notifications.count
    }
    
    func reminderID(localNotification: UILocalNotification) -> Int {
        let idFromNotification = localNotification.userInfo!["ReminderID"] as! Int
        return idFromNotification
    }
    
    func recieveLocalNotificationWithState(state: UIApplicationState) {
        print(#function)
        if state == .Inactive {
            print("---------------------")
            print("Handling notification from the background")
            print("Notification was tapped")
            NSNotificationCenter.defaultCenter().postNotificationName("viewReminder", object: nil)
        } else {
            print("Handling notification from app: doing nothing")
            // NSNotificationCenter.defaultCenter().postNotificationName("showNotificationHasGoneOff", object: nil)
        }
    }
    
    func handleActionInCategory(notification: UILocalNotification, actionIdentifier: String) {
        if notification.category == "Category" {
            if actionIdentifier == "Complete" {
                NSNotificationCenter.defaultCenter().postNotificationName("completeReminder", object: nil)
            } else if actionIdentifier == "Defer" {
                NSNotificationCenter.defaultCenter().postNotificationName("deferReminder", object: nil)
            }
        }
        
    }
}