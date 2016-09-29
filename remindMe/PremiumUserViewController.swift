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

class PremiumUserViewController: UIViewController, SKProductsRequestDelegate, SKRequestDelegate {
    // MARK: - Properties
    var delegate: PremiumUserViewControllerDelegate?
    
    var isRequestForPurchase = false
    var isRequestForRestore = false
    
    // MARK: Products
    var unlockPremiumProduct: SKProduct?
    let unlockPremiumProductIdentifier = "com.coconutdust.prod.unlockPremium"
    
    // MARK: Request
    var requestForProducts: SKRequest?
    
    // MARK: Activity View
    var activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    // MARK: - Outlets
    
    // MARK: Buttons
    @IBOutlet weak var goPremiumButton: UIButton!
    @IBOutlet weak var restorePurchaseButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    // MARK: Labels
    @IBOutlet weak var introSentenceLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func cancel() {
        requestForProducts?.cancel()
        requestForProducts?.delegate = nil
        delegate?.premiumUserViewControllerDelegateDidCancel(controller: self)
    }
    
    @IBAction func buy() {
        isRequestForPurchase = true
        isRequestForRestore = false
        fetchProducts()
        
    }
    
    @IBAction func restore() {
        isRequestForRestore = true
        isRequestForPurchase = false
        fetchProducts()
        
    }
    
    // MARK: - Delegates
    
    // MARK: Storekit Request Delegate
    
    func requestDidFinish(_ request: SKRequest) {
        print(#function)
        if isRequestForPurchase {
            if let product = unlockPremiumProduct {
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(payment)
                delegate?.premiumUserViewControllerDelegateDidCancel(controller: self)
            }
            isRequestForPurchase = false
        } else if isRequestForRestore {
            SKPaymentQueue.default().restoreCompletedTransactions()
            isRequestForRestore = false
            delegate?.premiumUserViewControllerDelegateDidCancel(controller: self)
        }
        
        activityView.stopAnimating()
        activityView.removeFromSuperview()
        
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        // Reset request type
        isRequestForPurchase = false
        isRequestForRestore = false
        
        activityView.stopAnimating()
        activityView.removeFromSuperview()
        
        print("Request failed: \(error)")
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
   
    }
    
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
            fetchProducts()
        }
        
        // Tracking
        Answers.logCustomEvent(withName: "Open Premium View", customAttributes: nil)
    }
    
    // MARK: - Functions
    
    // MARK: Storekit
    
    func fetchProducts() {
        let productIdentifiers: Set<String> = [unlockPremiumProductIdentifier]
        requestForProducts = SKProductsRequest(productIdentifiers: productIdentifiers)
        requestForProducts?.delegate = self
        requestForProducts?.start()
        
        
        
        activityView.center = self.view.center
        
        activityView.startAnimating()
        
        self.view.addSubview(activityView)
        
        
    }
    
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
