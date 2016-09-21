//
//  PremiumUserViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 19/09/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

protocol PremiumUserViewControllerDelegate {
    func premiumUserViewControllerDelegateDidCancel(controller: PremiumUserViewController)
}

class PremiumUserViewController: UIViewController, SKProductsRequestDelegate {
    // MARK: - Properties
    var delegate: PremiumUserViewControllerDelegate?
    
    var premiumProduct: SKProduct?
    var ncProduct: SKProduct?
    
    // MARK: - Outlets
    @IBOutlet weak var goPremiumButton: UIButton!
    @IBOutlet weak var restorePurchaseButton: UIButton!
    // @IBOutlet weak var ncPremiumButton: UIButton!
    
    @IBOutlet weak var introSentenceLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func cancel() {
        delegate?.premiumUserViewControllerDelegateDidCancel(controller: self)
    }
    
    @IBAction func buy() {
        if let product = premiumProduct {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
//    @IBAction func buyNC() {
//        if let product = ncProduct {
//            let payment = SKPayment(product: product)
//            SKPaymentQueue.default().add(payment)
//        }
//    }
    
    @IBAction func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - View Lifecyle
    
    deinit {
        print("Premium view was deallocated")
        delegate = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        goPremiumButton.layer.cornerRadius = 5
        restorePurchaseButton.layer.cornerRadius = 5
        
        print("User is premium: \(isPremium())")
        
        if isPremium() {
            goPremiumButton.isHidden = true
            restorePurchaseButton.isHidden = true
            introSentenceLabel.text = "Thank you for your support. You now have access to the following features."
        } else {
            introSentenceLabel.text = "Go premium and access the following features."
            goPremiumButton.isHidden = false
            restorePurchaseButton.isHidden = false
            let productIdentifiers: Set<String> = ["com.coconutdust.prod.unlockPremium"]
            let request = SKProductsRequest(productIdentifiers: productIdentifiers)
            request.delegate = self
            request.start()
        }
    }
    
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(#function)
        for product in response.products {
            print("Title: \(product.localizedTitle)")
            print("price: \(product.price)")
        }
        premiumProduct = response.products[0]
        
        if let product = premiumProduct {
            print("Got product")
            let price = product.price
            goPremiumButton.titleLabel?.text = "\(product.localizedTitle) (\(price))"
        }
        
    }
}
