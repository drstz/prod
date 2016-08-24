//
//  AllRemindersViewController+TabBarDelegate.swift
//  remindMe
//
//  Created by Duane Stoltz on 05/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import UIKit

extension AllRemindersViewController: UITabBarControllerDelegate  {
    // MARK: TabBar
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        print(#function)
        
        if viewController.tabBarItem.tag == 1 {
            print("Selecting Profile Tab")
            let navigationController = viewController as! UINavigationController
            let statisticViewController = navigationController.viewControllers[0] as! StatisticsViewController
            
            // Make sure only one view controller is the delegate
            statisticViewController.tabBarController?.delegate = statisticViewController
            statisticViewController.coreDataHandler = coreDataHandler
            statisticViewController.list = list 
            
            return true
        } else {
            print("Selecting Reminders Tab")
            return false
        }
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        print(#function)
    }
    
}
