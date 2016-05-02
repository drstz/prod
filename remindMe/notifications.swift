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
    completeAction.authenticationRequired = true
    completeAction.destructive = false
    
    let deferAction = UIMutableUserNotificationAction()
    deferAction.identifier = "Defer"
    deferAction.title = "+10 min"
    deferAction.activationMode = UIUserNotificationActivationMode.Background
    deferAction.authenticationRequired = true
    deferAction.destructive = false
    
    let actions = [completeAction, deferAction]
    
    return actions
    
}

func setNotificationCategories(actions : [UIMutableUserNotificationAction]) -> Set<UIMutableUserNotificationCategory>  {
    
    let category = UIMutableUserNotificationCategory()
    
    category.identifier = "CATEGORY"
    category.setActions(actions, forContext: UIUserNotificationActionContext.Default)
    category.setActions(actions, forContext: UIUserNotificationActionContext.Minimal)
    
    var categoriesForSettings = Set<UIMutableUserNotificationCategory>()
    categoriesForSettings.insert(category)
    
    return categoriesForSettings
    
}






