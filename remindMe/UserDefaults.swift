//
//  userDefaults.swift
//  remindMe
//
//  Created by Duane Stoltz on 02/05/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation

enum SnoozeDefaults {
    case tenSeconds
    case fiveMinutes
    case tenMinutes
    case thirtyMinutes
    case hour
}

enum SnoozeUnit: String {
    case Seconds = "sec"
    case Minutes = "min"
    case Hours = "hour"
    case Days = "day"
}

enum AutoSnoozeDefaults {
    case minute
    case hour
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
        "Filter" : "All",
        "TimePickerInterval" : 1,
        "Premium" : false
    ] as [String : Any]
    UserDefaults.standard.register(defaults: dictionary)
}

func disablePremium() {
    let userDefaults = UserDefaults.standard
    userDefaults.set(false, forKey: "Premium")
    userDefaults.synchronize()
}

func enablePremium() {
    let userDefaults = UserDefaults.standard
    userDefaults.set(true, forKey: "Premium")
    userDefaults.synchronize()
}

func isPremium() -> Bool {
    let userDefaults = UserDefaults.standard
    return userDefaults.bool(forKey: "Premium")
}

func isFirstTime() -> Bool {
    let userDefaults = UserDefaults.standard
    let firstTime = userDefaults.bool(forKey: "FirstTime")
    if firstTime {
        userDefaults.set(false, forKey: "FirstTime")
        userDefaults.synchronize()
        return true
    }
    return false
}

func save(_ filter: ReminderFilter) {
    print("Going to save filter: \(filter)")
    print("The filter's raw value is \(filter.rawValue)")
    
    let userDefaults = UserDefaults.standard
    userDefaults.set(filter.rawValue, forKey: "Filter")
    userDefaults.synchronize()
    
    print("Filter was saved to \(savedFilter())")
}

func savedFilter() -> ReminderFilter {
    let userDefaults = UserDefaults.standard
    let filter = userDefaults.object(forKey: "Filter") as! String
    return ReminderFilter(rawValue: filter)!
}

func isUsingCustomSnoozeTime() -> Bool {
    let userDefaults = UserDefaults.standard
    let customSnooze = userDefaults.bool(forKey: "UsingCustomSnooze")
    return customSnooze
}

func setUsingCustomSnoozeTime(_ enabled: Bool) {
    let userDefaults = UserDefaults.standard
    userDefaults.set(enabled, forKey: "UsingCustomSnooze")
    
}

func setSnoozeTime(_ duration: Double, unit: SnoozeUnit) {
    print(#function)
    let chosenUnit = choiceForSnoozeUnit(unit)
    let userDefaults = UserDefaults.standard
    userDefaults.set(chosenUnit, forKey: "SnoozeUnit")
    userDefaults.set(duration, forKey: "SnoozeDuration")
    userDefaults.synchronize()
    
    let notificationHandler = NotificationHandler()
    notificationHandler.updateAllSnoozeTimes()
}

func getLabel(_ snoozeDuration: Double, snoozeUnit: SnoozeUnit) -> String {
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

func saveCustomSnoozeTime(_ duration: Double, unit: SnoozeUnit) {
    let chosenUnit = choiceForSnoozeUnit(unit)
    let userDefaults = UserDefaults.standard
    userDefaults.set(chosenUnit, forKey: "SavedSnoozeUnit")
    userDefaults.set(duration, forKey: "SavedSnoozeDuration")
    userDefaults.synchronize()
}

func getCustomSnoozeTime() -> (Double, SnoozeUnit) {
    let userDefaults = UserDefaults.standard
    let duration = userDefaults.double(forKey: "SavedSnoozeDuration")
    let unit = SnoozeUnit(rawValue: userDefaults.object(forKey: "SavedSnoozeUnit") as! String)
    let customSnoozeTime = (duration, unit!)
    return customSnoozeTime
}

func setAutoSnooze(_ enabled: Bool) {
    let userDefaults = UserDefaults.standard
    userDefaults.set(enabled, forKey: "AutoSnoozeEnabled")
    userDefaults.synchronize()
}

func setDefaultAutoSnoozeTime(_ autoSnoozeTime: AutoSnoozeDefaults) {
    let autoSnoozeDefault = choiceForAutoSnoozeTime(autoSnoozeTime)
    let userDefaults = UserDefaults.standard
    userDefaults.set(autoSnoozeDefault, forKey: "AutoSnoozeTime")
    userDefaults.synchronize()
    
    let notificationHandler = NotificationHandler()
    notificationHandler.updateAllSnoozeTimes()
}

func saveSelectedTab(_ selectedTabIndex: Int) {
    print("")
    print(#function)
    let userDefaults = UserDefaults.standard
    print("Going to save tab as tab #\(selectedTabIndex)")
    userDefaults.set(selectedTabIndex, forKey: "SelectedTab")
    
    let savedTab = userDefaults.integer(forKey: "SelectedTab")
    print("Tab was saved as tab #\(savedTab)")
}

func getSavedTab() -> Int {
    let userDefaults = UserDefaults.standard
    let savedTab = userDefaults.integer(forKey: "SelectedTab")
    print("The saved tab is tab #\(savedTab)")
    return savedTab
}

func choiceForSnoozeUnit(_ unit: SnoozeUnit) -> String {
    return unit.rawValue
}

func choiceForAutoSnoozeTime(_ autoSnoozeDefaults: AutoSnoozeDefaults) -> String {
    switch autoSnoozeDefaults {
    case .minute:
        return "1 minute"
    case .hour:
        return "1 hour"
    }
}

func timePickerInterval() -> Int {
    let userDefaults = UserDefaults.standard
    let interval = userDefaults.integer(forKey: "TimePickerInterval")
    return interval
}

func saveTimePickerInterval(_ interval: Int) {
    let userDefaults = UserDefaults.standard
    userDefaults.set(interval, forKey: "TimePickerInterval")
    userDefaults.synchronize()
}

func autoSnoozeSetting() -> Bool {
    let userDefaults = UserDefaults.standard
    return userDefaults.bool(forKey: "AutoSnoozeEnabled")
}
