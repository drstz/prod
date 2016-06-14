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

enum AutoSnoozeDefaults {
    case Minute
    case Hour
}
    
func registerDefaults() {
    let dictionary = [
        "FirstTime": true,
        "SnoozeTime": "10 seconds",
        "AutoSnoozeEnabled" : true,
        "AutoSnoozeTime": "1 minute"
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

func setDefaultSnoozeTime(snoozeTime: SnoozeDefaults) {
    let snoozeDefault = choiceForSnoozeTime(snoozeTime)
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setObject(snoozeDefault, forKey: "SnoozeTime")
    userDefaults.synchronize()
}

func setAutoSnooze(enabled: Bool) {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setBool(enabled, forKey: "AutoSnoozeEnabled")
    userDefaults.synchronize()
}

func setDefaultAutoSnoozeTime(autoSnoozeTime: AutoSnoozeDefaults) {
    let autoSnoozeDefault = choiceForAutoSnoozeTime(autoSnoozeTime)
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setObject(autoSnoozeDefault, forKey: "AutoSnoozeTime")
    userDefaults.synchronize()
}

func choiceForSnoozeTime(snoozeDefaults: SnoozeDefaults) -> String {
    switch snoozeDefaults {
    case .TenSeconds:
        return "10 seconds"
    case .FiveMinutes:
        return "5 minutes"
    case .TenMinutes:
        return "10 minutes"
    case .ThirtyMinutes:
        return "30 minutes"
    case .Hour:
        return "1 hour"
    }
}

func choiceForAutoSnoozeTime(autoSnoozeDefaults: AutoSnoozeDefaults) -> String {
    switch autoSnoozeDefaults {
    case .Minute:
        return "1 minute"
    case .Hour:
        return "1 hour"
    }
}
