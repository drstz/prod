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
        let time = userDefaults.objectForKey("SnoozeTime") as! String
        let deferAmount = getDeferString(time)
        
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
    
    func getDeferString(deferAmount: String) -> String {
        switch deferAmount {
        case "10 seconds":
            return "+10s"
        case "5 minutes":
            return "+5m"
        case "10 minutes":
            return "+10m"
        case "30 minutes":
            return "+30m"
        case "1 hour":
            return "+1h"
        default:
            return "!!!"
        }
    }
    
    
    func setNotificationCategories(actions : [UIMutableUserNotificationAction]) -> Set<UIMutableUserNotificationCategory>  {
        
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
        var localNotification = UILocalNotification()
        
        deleteReminderNotifications(reminder)
        
        if isBeingDeferred {
            print("Snoozing notification for \(reminder.name)")
            localNotification = deferNotification()
        } else {
            print("Setting notification for \(reminder.name)")
            localNotification = scheduleNotification(forDate: reminder.dueDate)
        }
        
        localNotification = setNotificationSettings(localNotification, reminder: reminder)
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
        let numberOfNotifications = countAllNotifications()
        print("Total of \(numberOfNotifications) notifications" )
    }
    
    func deferNotification() -> UILocalNotification {
        
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let autoSnoozeOn = userDefaults.boolForKey("AutoSnoozeEnabled")
        let time = userDefaults.objectForKey("SnoozeTime") as! String
        let anInterval = userDefaults.objectForKey("AutoSnoozeTime") as! String
        let repeatInterval = getRepeatInterval(anInterval)
        let deferAmount = getDeferAmount(time)
        
        
        let localNotification = UILocalNotification()
        
        localNotification.fireDate = NSDate(timeIntervalSinceNow: deferAmount)
        if autoSnoozeOn {
            localNotification.repeatInterval = repeatInterval
        }
        
        
        return localNotification
    }
    
    func scheduleNotification(forDate date: NSDate) -> UILocalNotification {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let autoSnoozeOn = userDefaults.boolForKey("AutoSnoozeEnabled")
        
        let anInterval = userDefaults.objectForKey("AutoSnoozeTime") as! String
        let repeatInterval = getRepeatInterval(anInterval)
        
        let localNotification = UILocalNotification()
        let dueDate = date

        localNotification.fireDate = dueDate
        if autoSnoozeOn {
            localNotification.repeatInterval = repeatInterval
        }
        
        return localNotification
        
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
        if state == .Inactive {
            print("Handling notification from the background")
            NSNotificationCenter.defaultCenter().postNotificationName("viewReminder", object: nil)
        } else {
            print("Handling notification from app")
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