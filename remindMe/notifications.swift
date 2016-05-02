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
    let completeAction = UIMutableUserNotificationAction()
    completeAction.identifier = "Complete"
    completeAction.title = "Complete"
    completeAction.activationMode = UIUserNotificationActivationMode.Background
    completeAction.authenticationRequired = true
    completeAction.destructive = false
    
    let actions = [completeAction]
    
    let category = UIMutableUserNotificationCategory()
    
    category.identifier = "CATEGORY"
    category.setActions(actions, forContext: UIUserNotificationActionContext.Default)
    category.setActions(actions, forContext: UIUserNotificationActionContext.Minimal)
    
    var categoriesForSettings = Set<UIMutableUserNotificationCategory>()
    categoriesForSettings.insert(category)
    
    let settings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories:  categoriesForSettings)
    UIApplication.sharedApplication().registerUserNotificationSettings(settings)

}






