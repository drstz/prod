//
//  AllRemindersViewController+TabBarDelegate.swift
//  remindMe
//
//  Created by Duane Stoltz on 05/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import UIKit

extension AllRemindersViewController: UITabBarControllerDelegate, PremiumUserViewControllerDelegate  {
    // MARK: TabBar
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print(#function)
        
        if viewController.tabBarItem.tag == 1 {
            
            if isPremium() {
                print("Selecting Profile Tab")
                let navigationController = viewController as! UINavigationController
                let statisticViewController = navigationController.viewControllers[0] as! ProductivityViewController
                
                // Make sure only one view controller is the delegate
                statisticViewController.tabBarController?.delegate = statisticViewController
                statisticViewController.coreDataHandler = coreDataHandler
                statisticViewController.list = list
                
                return true
            } else {
                presentPremiumView()
                return false
            }
            
            
        } else {
            print("Selecting Reminders Tab")
            return false
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print(#function)
    }
    
    func presentPremiumView() {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        
        
        let premiumView = storyboard.instantiateViewController(withIdentifier: "PremiumView") as! PremiumUserViewController
        premiumView.delegate = self
        
        let navigationController = UINavigationController()
        navigationController.viewControllers.append(premiumView)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    func premiumUserViewControllerDelegateDidCancel(controller: PremiumUserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}
