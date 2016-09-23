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
import Fabric
import Crashlytics

protocol PremiumUserViewControllerDelegate {
    func premiumUserViewControllerDelegateDidCancel(controller: PremiumUserViewController)
}

class PremiumUserViewController: UIViewController, SKProductsRequestDelegate {
    // MARK: - Properties
    var delegate: PremiumUserViewControllerDelegate?
    
    // MARK: Products
    var unlockPremiumProduct: SKProduct?
    let unlockPremiumProductIdentifier = "com.coconutdust.prod.unlockPremium"
    
    // MARK: - Outlets
    
    // MARK: Buttons
    @IBOutlet weak var goPremiumButton: UIButton!
    @IBOutlet weak var restorePurchaseButton: UIButton!
    
    
    // MARK: Labels
    @IBOutlet weak var introSentenceLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func cancel() {
        delegate?.premiumUserViewControllerDelegateDidCancel(controller: self)
    }
    
    @IBAction func buy() {
        if let product = unlockPremiumProduct {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    @IBAction func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    // MARK: - Delegates
    
    // MARK: Product Request Delegate
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(#function)
        for product in response.products {
            print("Title: \(product.localizedTitle)")
            print("price: \(product.price)")
        }
        unlockPremiumProduct = response.products[0]
        
        if let product = unlockPremiumProduct {
            print("Got product")
            let productTitle = product.localizedTitle
            let price = format(price: product.price, for: product.priceLocale)

            let buttonTitle = productTitle + " " + price
            goPremiumButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    // MARK: - View Lifecyle
    
    deinit {
        print("Premium view was deallocated")
        delegate = nil
        print("All is deallocated")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        goPremiumButton.layer.cornerRadius = 5
        restorePurchaseButton.layer.cornerRadius = 5
        
        print("User is premium: \(isPremium())")
        
        if isPremium() {
            introSentenceLabel.text = "Thank you for your support. You now have access to the following features."
            
            goPremiumButton.isHidden = true
            restorePurchaseButton.isHidden = true
        } else {
            introSentenceLabel.text = "Go premium and access the following features."
            
            goPremiumButton.isHidden = false
            restorePurchaseButton.isHidden = false
            
            // Request Product
            let productIdentifiers: Set<String> = [unlockPremiumProductIdentifier]
            let request = SKProductsRequest(productIdentifiers: productIdentifiers)
            request.delegate = self
            request.start()
        }
        
        // Tracking
        Answers.logCustomEvent(withName: "Open Premium View", customAttributes: nil)
    }
    
    // MARK: - Functions
    
    func format(price: NSDecimalNumber, for locale: Locale) -> String {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        
        
        let formattedPrice = formatter.string(from: price as NSNumber)
        
        if let price = formattedPrice {
            return price
        } else {
            return "Error"
        }
    }
}
