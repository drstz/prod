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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let somehtmlFile = htmlFile {
            if let htmlData = try? Data(contentsOf: URL(fileURLWithPath: somehtmlFile)) {
                let baseURL = URL(fileURLWithPath: Bundle.main.bundlePath)
                webView.load(htmlData, mimeType: "text/html", textEncodingName: "UTF-8", baseURL: baseURL)
            }
        }
        
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // Allows app to open links from a webview
        // Must be made a delegate first
        if let url = request.url , navigationType == .linkClicked {
            UIApplication.shared.openURL(url)
            return false
        }
        return true
    }
}
