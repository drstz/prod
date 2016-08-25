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
    
    // MARK: Outlets
    @IBOutlet weak var patternLabel: UILabel!
    
    // MARK: Repeat pattern
    var selectedInterval: String? = "minute"
    var selectedFrequency: Int? = 1
    
    // MARK: Delegate
    
    weak var delegate: RepeatMethodViewControllerDelegate?
    
    // MARK: Pattern Picker View Controller Delegate
    func patternPickerViewControllerDidChoosePattern(controller: PatternPickerViewController, frequency: Int, interval: String) {
        performSegueWithIdentifier("unwindToAddReminder", sender: self)
        delegate?.repeatMethodViewControllerDidChooseCustomPattern(self, frequency: frequency, interval: interval )
    }
    
    // MARK: Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePatternLabel()
    }
    
    // MARK: Table View
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickPattern" {
            let controller = segue.destinationViewController as? PatternPickerViewController
            
            controller?.delegate = self
            controller?.selectedFrequency = selectedFrequency
            controller?.selectedInterval = selectedInterval
        }
    }
    
    // MARK: Helper methods
    func updatePatternLabel() {
        if selectedFrequency != 1 {
            patternLabel.text = "every " + "\(selectedFrequency!) " + "\(selectedInterval!)" + "s"
        } else if selectedFrequency == 1 {
            patternLabel.text = "every " + "\(selectedInterval!)"
        } else {
            patternLabel.text = "Doesn't repeat"
        }
    }
}
