//
//  RepeatMethodViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 25/08/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

protocol RepeatMethodViewControllerDelegate: class {
    func repeatMethodViewControllerDidChooseCustomPattern(controller: RepeatMethodViewController, frequency: Int, interval: String)
    func repeatMethodViewControllerDidChooseWeekDayPattern(controller: RepeatMethodViewController, days: [Int])
}


class RepeatMethodViewController: UITableViewController, PatternPickerViewControllerDelegate {
    
    // MARK: Delegate
    
    weak var delegate: RepeatMethodViewControllerDelegate?
    
    // MARK: Pattern Picker View Controller Delegate
    func patternPickerViewControllerDidChoosePattern(controller: PatternPickerViewController, frequency: Int, interval: String) {
        print("Going to dismiss pattern view controller")
        // dismissViewControllerAnimated(true, completion: nil)
        
        performSegueWithIdentifier("unwindToAddReminder", sender: self)
        delegate?.repeatMethodViewControllerDidChooseCustomPattern(self, frequency: frequency, interval: interval )
    }
    
    // MARK: Lifecycle
    
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickPattern" {
            print("Repeat method is delegate of pattern view controller")
            let controller = segue.destinationViewController as? PatternPickerViewController
            controller?.delegate = self
        }
    }
}
