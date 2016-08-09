//
//  AboutViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 08/08/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var htmlFile: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let somehtmlFile = htmlFile {
            if let htmlData = NSData(contentsOfFile: somehtmlFile) {
                let baseURL = NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath)
                webView.loadData(htmlData, MIMEType: "text/html", textEncodingName: "UTF-8", baseURL: baseURL)
            }
        }
        
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // Allows app to open links from a webview
        // Must be made a delegate first
        if let url = request.URL where navigationType == .LinkClicked {
            UIApplication.sharedApplication().openURL(url)
            return false
        }
        return true
    }
    
    
    
}
