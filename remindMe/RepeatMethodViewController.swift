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
    func repeatMethodViewControllerDidDeletePattern()
}


class RepeatMethodViewController: UITableViewController, PatternPickerViewControllerDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var patternLabel: UILabel!
    
    // MARK: Next Date Example
    
    @IBOutlet weak var nextDateExampleLabel: UILabel!
    @IBOutlet weak var deletePatternCell: UITableViewCell!
    
    // Delete Button
    @IBOutlet weak var deletePatternButton: UIButton!
    
    // MARK: Repeat pattern
    var selectedInterval: String? = "minute"
    var selectedFrequency: Int? = 1
    
    // MARK: Delegate
    
    weak var delegate: RepeatMethodViewControllerDelegate?
    
    // MARK: Delete Pattern
    
    @IBAction func deletePattern() {
        print("Deleting pattern")
        selectedInterval = nil
        selectedFrequency = nil
        
        updatePatternLabel()
        
        delegate?.repeatMethodViewControllerDidDeletePattern()
        tableView.indexPathForCell(deletePatternCell)
        tableView.selectRowAtIndexPath(tableView.indexPathForCell(deletePatternCell), animated: true, scrollPosition: .None)
        tableView.deselectRowAtIndexPath(tableView.indexPathForCell(deletePatternCell)!, animated: true)
        
        deletePatternCell.hidden = true
    }
    
    // MARK: Pattern Picker View Controller Delegate
    func patternPickerViewControllerDidChoosePattern(controller: PatternPickerViewController, frequency: Int, interval: String) {
        performSegueWithIdentifier("unwindToAddReminder", sender: self)
        print("Going back with \(interval) and \(frequency)")
        delegate?.repeatMethodViewControllerDidChooseCustomPattern(self, frequency: frequency, interval: interval )
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedInterval == nil {
            deletePatternCell.hidden = true
        } else {
            deletePatternCell.hidden = false
        }
        
        updatePatternLabel()
    }
    
    // MARK: Table View
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(#function)
        if indexPath.section == 1 && indexPath.row == 1 {
            deletePattern()
        }
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
        if let frequency = selectedFrequency, let interval = selectedInterval {
            if selectedFrequency != 1 {
                patternLabel.text = "every " + "\(frequency) " + "\(interval)" + "s"
            } else if selectedFrequency == 1 {
                patternLabel.text = "every " + "\(interval)"
            }
        } else {
            patternLabel.text = "Doesn't repeat"
        }
    }
}
