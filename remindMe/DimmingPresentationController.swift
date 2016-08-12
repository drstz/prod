//
//  DimmingPresentationController.swift
//  remindMe
//
//  Created by Duane Stoltz on 21/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    
    var blurringView: UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = containerView!.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        blurEffectView.tag = 999
        return blurEffectView
    }
    
    var blurredView: UIVisualEffectView?
    
    
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
    
    override func presentationTransitionWillBegin() {
        
        let blurEffectView = blurringView
        blurredView = blurEffectView
        
        containerView!.insertSubview(blurredView!, atIndex: 0)
        blurredView!.alpha = 0
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ _ in
                self.blurredView!.alpha = 1
                }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ _ in
                self.blurredView!.alpha = 0 } , completion: nil)
        }
    }
}
