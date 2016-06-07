//
//  userDefaults.swift
//  remindMe
//
//  Created by Duane Stoltz on 02/05/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
    
func registerDefaults() {
    let dictionary = ["FirstTime": true,
                      "SnoozeTime": "10 seconds"]
    
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

func setDefaultSnoozeTime(snoozeTime: String) {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setObject(snoozeTime, forKey: "SnoozeTime")
    userDefaults.synchronize()
}


