//
//  notifications.swift
//  remindMe
//
//  Created by Duane Stoltz on 21/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import UIKit



func setNotifications() {
    let myAction = UIMutableUserNotificationAction()
    myAction.identifier = "HELLO"
    myAction.title = "Say hello"
    myAction.activationMode = UIUserNotificationActivationMode.Background
    myAction.authenticationRequired = true
    myAction.destructive = false
    
    let actions = [myAction]
    
    let category = UIMutableUserNotificationCategory()
    
    category.identifier = "CATEGORY"
    category.setActions(actions, forContext: UIUserNotificationActionContext.Default)
    category.setActions(actions, forContext: UIUserNotificationActionContext.Minimal)
    
    var categoriesForSettings = Set<UIMutableUserNotificationCategory>()
    categoriesForSettings.insert(category)
    
    let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories:  categoriesForSettings)
    UIApplication.sharedApplication().registerUserNotificationSettings(settings)

}






