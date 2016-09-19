//
//  PremiumUserViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 19/09/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import UIKit

protocol PremiumUserViewControllerDelegate {
    func premiumUserViewControllerDelegateDidCancel(controller: PremiumUserViewController)
}

class PremiumUserViewController: UIViewController {
    // MARK: - Properties
    var delegate: PremiumUserViewControllerDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var goPremiumButton: UIButton!
    @IBOutlet weak var restorePurchaseButton: UIButton!
    
    // MARK: - Actions
    @IBAction func cancel() {
        delegate?.premiumUserViewControllerDelegateDidCancel(controller: self)
    }
    
    // MARK: - View Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goPremiumButton.layer.cornerRadius = 5
        restorePurchaseButton.layer.cornerRadius = 5
    }
    
}
