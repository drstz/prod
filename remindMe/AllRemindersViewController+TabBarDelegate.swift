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
        print("")
        
        print("___________________")
        print(#function)
        let selectedIndex = myTabBarController.selectedIndex
        
        let navigationController = viewController as! UINavigationController
        let viewControllers = navigationController.viewControllers
        let allRemindersViewController = viewControllers[0] as! AllRemindersViewController
        
        let selectedViewControllerTag = allRemindersViewController.tabBarController?.tabBar.selectedItem?.tag
        print("CHANGING TAB \(selectedIndex) ---> \(selectedViewControllerTag!) ")
        print("Segment is \(segmentedControl.selectedSegmentIndex)")
        
        
        let messageToSend = "I came from tab \(selectedIndex)"
        allRemindersViewController.sentMessage = messageToSend
        
        
        allRemindersViewController.managedObjectContext = managedObjectContext
        allRemindersViewController.list = list
        tabBarController.delegate = allRemindersViewController
        allRemindersViewController.myTabBarController = tabBarController
        
        allRemindersViewController.selectedSegment = selectedSegment
        
        allRemindersViewController.myTabIndex = selectedViewControllerTag!
        
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        print("")
        print("")
        print("")
        print("___________________")
        print(#function)
        print("Here comes the recieved message: \(sentMessage)")
        let selectedIndex = myTabBarController.selectedIndex
        print("Current tab is \(selectedIndex).")
        print("I want to be tab \(myTabIndex).")
        print("Segment is \(segmentedControl.selectedSegmentIndex)")
        
    }
    
}
