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
        let settings = UIUserNotificationSettings(types: [.alert, .sound], categories:  categories)
        
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    func setNotificationActions() -> [UIMutableUserNotificationAction]  {
        let userDefaults = UserDefaults.standard
        let time = userDefaults.object(forKey: "SnoozeUnit") as! String
        let snoozeDuration = userDefaults.double(forKey: "SnoozeDuration")
        let deferAmount = getDeferString(time, duration: snoozeDuration)
        
        let completeAction = UIMutableUserNotificationAction()
        completeAction.identifier = "Complete"
        completeAction.title = "Complete"
        completeAction.activationMode = UIUserNotificationActivationMode.background
        completeAction.isAuthenticationRequired = false
        completeAction.isDestructive = false
        
        let deferAction = UIMutableUserNotificationAction()
        deferAction.identifier = "Defer"
        deferAction.title = deferAmount
        deferAction.activationMode = UIUserNotificationActivationMode.background
        deferAction.isAuthenticationRequired = false
        deferAction.isDestructive = false
        
        let actions = [completeAction, deferAction]
        
        return actions
    }
    
    func getDeferString(_ deferAmount: String, duration: Double) -> String {
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
    
    func setNotificationCategories(_ actions : [UIMutableUserNotificationAction]) -> Set<UIMutableUserNotificationCategory>  {
        print(#function)
        
        let category = UIMutableUserNotificationCategory()
        
        category.identifier = "Category"
        category.setActions(actions, for: UIUserNotificationActionContext.default)
        category.setActions(actions, for: UIUserNotificationActionContext.minimal)
        
        var categoriesForSettings = Set<UIMutableUserNotificationCategory>()
        categoriesForSettings.insert(category)
        
        return categoriesForSettings
    }
    
    func updateAllSnoozeTimes() {
        let oldNotifications = allNotifications()
        let programmedNotifications = allNotifications()
        for notification in programmedNotifications {
            UIApplication.shared.cancelLocalNotification(notification)
        }
        var numberOfNotifications = countAllNotifications()
        print("Total of \(numberOfNotifications) notifications" )
        
        setNotifications()
        
        let userDefaults = UserDefaults.standard
        let autoSnoozeOn = userDefaults.bool(forKey: "AutoSnoozeEnabled")
        let anInterval = userDefaults.object(forKey: "AutoSnoozeTime") as! String
        let repeatInterval = getRepeatInterval(anInterval)
        
        for notification in oldNotifications {
            let newNotification = UILocalNotification()
            
            // Time
            if !(notification.fireDate?.isPresent())! {
                print("Setting notification to now")
                let now = Date()
                newNotification.fireDate = now.addMinutes(1)
            } else {
                newNotification.fireDate = notification.fireDate
            }
            newNotification.timeZone = notification.timeZone
            if autoSnoozeOn {
                newNotification.repeatInterval = repeatInterval
            }
            newNotification.repeatCalendar = notification.repeatCalendar
            
            // Alert
            newNotification.alertBody = notification.alertBody
            newNotification.alertAction = notification.alertAction
            newNotification.alertTitle = notification.alertTitle
            newNotification.hasAction = notification.hasAction
            newNotification.alertLaunchImage = notification.alertLaunchImage
            newNotification.category = notification.category
            newNotification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber
            newNotification.soundName = notification.soundName
            newNotification.userInfo = notification.userInfo
            
            UIApplication.shared.scheduleLocalNotification(newNotification)
            
        }
        numberOfNotifications = countAllNotifications()
        print("Total of \(numberOfNotifications) notifications" )
        
        
    }
    
    
    
    // MARK: - Handling Notifications
    
    func scheduleNotifications(_ reminder: Reminder, snooze isBeingDeferred: Bool = false) {
        print(#function)
        var localNotification = UILocalNotification()
        
        deleteReminderNotifications(reminder)
        
        let now = Date()
        let earlierDate = (reminder.dueDate as NSDate).earlierDate(now)
        
        if earlierDate == now {
            if isBeingDeferred {
                print("Snoozing notification for \(reminder.name)")
                localNotification = snoozeNotification()
            } else {
                print("Setting notification for \(reminder.name)")
                localNotification = scheduleNotification(forDate: reminder.dueDate as Date, reminder: reminder)
            }
            localNotification = setNotificationSettings(localNotification, reminder: reminder)
            
            UIApplication.shared.scheduleLocalNotification(localNotification)
            
            let numberOfNotifications = countAllNotifications()
            print("Total of \(numberOfNotifications) notifications" )
        } else {
            print("No notification was set")
        }
    }
    
    func snoozeNotification() -> UILocalNotification {
        let userDefaults = UserDefaults.standard
        let chosenDuration = userDefaults.double(forKey: "SnoozeDuration")
        let snoozeUnit = userDefaults.object(forKey: "SnoozeUnit") as! String
        let unit = SnoozeUnit(rawValue: snoozeUnit)
        
        let duration = snoozeDuration(chosenDuration, unit: unit!)
        
        let localNotification = UILocalNotification()
        localNotification.fireDate = Date(timeIntervalSinceNow: duration)
        
        return localNotification
    }
    
    func scheduleNotification(forDate date: Date, reminder: Reminder) -> UILocalNotification {
        print(#function)
        let dueDate = date
        
        let localNotification = UILocalNotification()
        localNotification.fireDate = dueDate
        
        setAutoSnooze(localNotification, reminder: reminder)
        
        return localNotification
        
    }
    
    func setAutoSnooze(_ notification: UILocalNotification, reminder: Reminder) {
        print(#function)
        let userDefaults = UserDefaults.standard
        let autoSnoozeOn = reminder.willAutoSnooze as Bool
        if autoSnoozeOn {
            let anInterval = userDefaults.object(forKey: "AutoSnoozeTime") as! String
            let repeatInterval = getRepeatInterval(anInterval)
            notification.repeatInterval = repeatInterval
        }
        
    }
    
    func getRepeatInterval(_ repeatInterval: String) -> NSCalendar.Unit {
        switch repeatInterval {
        case "1 minute":
            return .minute
        case "1 hour":
            return .hour
        default:
            return .month
        }
    }
    
    func setNotificationSettings(_ notification: UILocalNotification, reminder: Reminder) -> UILocalNotification {
        let localNotification = notification
        
        localNotification.timeZone = TimeZone.current
        
        localNotification.alertBody = reminder.name
        localNotification.alertTitle = reminder.name
        
        localNotification.category = "Category"
        localNotification.soundName = UILocalNotificationDefaultSoundName
        
        localNotification.userInfo = ["ReminderID": reminder.idNumber]
        
        return localNotification
        
    }

    func deleteReminderNotifications(_ reminder: Reminder)  {
        let notifications = notificationsForReminder(reminder)
        
        for notification in notifications {
            UIApplication.shared.cancelLocalNotification(notification)
            print("Deleted notification for \(reminder.name)")
        }
        
        let numberOfNotifications = countReminderNotifications(reminder)
        print("\(numberOfNotifications) notifications for \(reminder.name)")
    }
    
    func allNotifications() -> [UILocalNotification] {
        let allNotifications = UIApplication.shared.scheduledLocalNotifications!
        return allNotifications
    }
    
    func notificationsForReminder(_ reminder: Reminder) -> [UILocalNotification] {
        let notifications = allNotifications()
        var notificationsForReminder = [UILocalNotification]()
        
        for notification in notifications {
            if let reminderID = notification.userInfo?["ReminderID"] as? Int , reminderID == reminder.idNumber as Int {
                notificationsForReminder.append(notification)
            }
        }
        return notificationsForReminder
    }

    
    func countReminderNotifications(_ reminder: Reminder) -> Int {
        let notifications = notificationsForReminder(reminder)
        return notifications.count
    }
    
    func countAllNotifications() -> Int {
        let notifications = allNotifications()
        return notifications.count
    }
    
    func reminderID(_ localNotification: UILocalNotification) -> Int {
        let idFromNotification = localNotification.userInfo!["ReminderID"] as! Int
        return idFromNotification
    }
    
//    func recieveLocalNotificationWithState(state: UIApplicationState) {
//        print(#function)
//        if state == .Inactive {
//            print("Notification was tapped")
//            NSNotificationCenter.defaultCenter().postNotificationName("viewReminder", object: nil)
//        } else {
//            print("Handling notification from app")
//            NSNotificationCenter.defaultCenter().postNotificationName("setBadgeForTodayTab", object: nil)
//            NSNotificationCenter.defaultCenter().postNotificationName("refresh", object: nil)
//        }
//    }
    
    func handleActionInCategory(_ notification: UILocalNotification, actionIdentifier: String) {
        NSLog(#function)
        if notification.category == "Category" {
            if actionIdentifier == "Complete" {
                NSLog("Identifer is Complete")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "completeReminder"), object: nil)
            } else if actionIdentifier == "Defer" {
                NSLog("Identifer is Defer")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "snoozeReminder"), object: nil)
            }
        }
    }
    
    func handleAction(_ reminder: Reminder, category: String, identifier: String) {
        if category == "Category" {
            if identifier == "Complete" {
                reminder.complete()
            } else  if identifier == "Defer" {
                reminder.snooze()
            }
        }
    }
}
