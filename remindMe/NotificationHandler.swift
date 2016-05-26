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
        
        let completeAction = UIMutableUserNotificationAction()
        completeAction.identifier = "Complete"
        completeAction.title = "Complete"
        completeAction.activationMode = UIUserNotificationActivationMode.Background
        completeAction.authenticationRequired = false
        completeAction.destructive = false
        
        let deferAction = UIMutableUserNotificationAction()
        deferAction.identifier = "Defer"
        deferAction.title = "+10 min"
        deferAction.activationMode = UIUserNotificationActivationMode.Background
        deferAction.authenticationRequired = false
        deferAction.destructive = false
        
        let actions = [completeAction, deferAction]
        
        return actions
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
            print("Deferring notification for \(reminder.name)")
            localNotification = deferNotification()
        } else {
            print("Setting notification for \(reminder.name)")
            localNotification = scheduleNotification()
        }
        
        localNotification = setNotificationSettings(localNotification, reminder: reminder)
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
        let numberOfNotifications = countAllNotifications()
        print("Total of \(numberOfNotifications) notifications" )
    }
    
    func deferNotification() -> UILocalNotification {
        let timeInterval: NSTimeInterval = 10
        let localNotification = UILocalNotification()
        // For testing
        
        localNotification.fireDate = NSDate(timeIntervalSinceNow: timeInterval)
        localNotification.repeatInterval = .Minute
        
        return localNotification
    }
    
    func scheduleNotification() -> UILocalNotification {
        
        let timeInterval: NSTimeInterval = 10
        let localNotification = UILocalNotification()
        let dueDate = NSDate(timeIntervalSinceNow: timeInterval)
        
        // For testing
        localNotification.fireDate = dueDate
        localNotification.repeatInterval = .Minute
        
        return localNotification
        
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
}