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
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        print(#function)
    }
    
}
