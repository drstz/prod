//
//  userDefaults.swift
//  remindMe
//
//  Created by Duane Stoltz on 02/05/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation

enum SnoozeDefaults {
    case TenSeconds
    case FiveMinutes
    case TenMinutes
    case ThirtyMinutes
    case Hour
}

enum SnoozeUnit: String {
    case Seconds = "sec"
    case Minutes = "min"
    case Hours = "hour"
    case Days = "day"
}

enum AutoSnoozeDefaults {
    case Minute
    case Hour
}
    
func registerDefaults() {
    let dictionary = [
        "FirstTime": true,
        "SnoozeTime": "10 seconds",
        "AutoSnoozeEnabled" : true,
        "AutoSnoozeTime": "1 minute",
        "SelectedTab" : 0,
        "SnoozeDuration": 30,
        "SnoozeUnit": "min",
        "UsingCustomSnooze" : false,
        "SavedSnoozeDuration" : 0,
        "SavedSnoozeUnit" : "min",
        "Filter" : "All"
    ]
    NSUserDefaults.standardUserDefaults().registerDefaults(dictionary)
}

func isFirstTime() -> Bool {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let firstTime = userDefaults.boolForKey("FirstTime")
    if firstTime {
        userDefaults.setBool(false, forKey: "FirstTime")
        userDefaults.synchronize()
        return true
    }
    return false
}

func saveFilter(filter: ReminderFilter) {
    print("Going to save filter: \(filter)")
    print("The filter's raw value is \(filter.rawValue)")
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setObject(filter.rawValue, forKey: "Filter")
    userDefaults.synchronize()
    
    print("Filter was saved to \(savedFilter())")
}

func savedFilter() -> ReminderFilter {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let filter = userDefaults.objectForKey("Filter") as! String
    return ReminderFilter(rawValue: filter)!
}

func isUsingCustomSnoozeTime() -> Bool {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let customSnooze = userDefaults.boolForKey("UsingCustomSnooze")
    return customSnooze
}

func setUsingCustomSnoozeTime(enabled: Bool) {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setBool(enabled, forKey: "UsingCustomSnooze")
    
}

func setSnoozeTime(duration: Double, unit: SnoozeUnit) {
    print(#function)
    let chosenUnit = choiceForSnoozeUnit(unit)
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setObject(chosenUnit, forKey: "SnoozeUnit")
    userDefaults.setDouble(duration, forKey: "SnoozeDuration")
    userDefaults.synchronize()
    
    let notificationHandler = NotificationHandler()
    notificationHandler.updateAllSnoozeTimes()
}

func getLabel(snoozeDuration: Double, snoozeUnit: SnoozeUnit) -> String {
    var duration = ""
    switch snoozeUnit {
    case .Seconds:
        duration = "second"
    case .Minutes:
        duration = "minute"
    case .Hours:
        duration = "hour"
    case .Days:
        duration = "day"
    }
    if snoozeDuration > 1 {
        duration += "s"
    }
    return duration
}

func saveCustomSnoozeTime(duration: Double, unit: SnoozeUnit) {
    let chosenUnit = choiceForSnoozeUnit(unit)
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setObject(chosenUnit, forKey: "SavedSnoozeUnit")
    userDefaults.setDouble(duration, forKey: "SavedSnoozeDuration")
    userDefaults.synchronize()
}

func getCustomSnoozeTime() -> (Double, SnoozeUnit) {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let duration = userDefaults.doubleForKey("SavedSnoozeDuration")
    let unit = SnoozeUnit(rawValue: userDefaults.objectForKey("SavedSnoozeUnit") as! String)
    let customSnoozeTime = (duration, unit!)
    return customSnoozeTime
}

func setAutoSnooze(enabled: Bool) {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setBool(enabled, forKey: "AutoSnoozeEnabled")
    userDefaults.synchronize()
    
    let notificationHandler = NotificationHandler()
    notificationHandler.updateAllSnoozeTimes()
}

func setDefaultAutoSnoozeTime(autoSnoozeTime: AutoSnoozeDefaults) {
    let autoSnoozeDefault = choiceForAutoSnoozeTime(autoSnoozeTime)
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setObject(autoSnoozeDefault, forKey: "AutoSnoozeTime")
    userDefaults.synchronize()
    
    let notificationHandler = NotificationHandler()
    notificationHandler.updateAllSnoozeTimes()
}

func saveSelectedTab(selectedTabIndex: Int) {
    print("")
    print(#function)
    let userDefaults = NSUserDefaults.standardUserDefaults()
    print("Going to save tab as tab #\(selectedTabIndex)")
    userDefaults.setInteger(selectedTabIndex, forKey: "SelectedTab")
    
    let savedTab = userDefaults.integerForKey("SelectedTab")
    print("Tab was saved as tab #\(savedTab)")
}

func getSavedTab() -> Int {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    let savedTab = userDefaults.integerForKey("SelectedTab")
    print("The saved tab is tab #\(savedTab)")
    return savedTab
}

func choiceForSnoozeUnit(unit: SnoozeUnit) -> String {
    return unit.rawValue
}

func choiceForAutoSnoozeTime(autoSnoozeDefaults: AutoSnoozeDefaults) -> String {
    switch autoSnoozeDefaults {
    case .Minute:
        return "1 minute"
    case .Hour:
        return "1 hour"
    }
}
