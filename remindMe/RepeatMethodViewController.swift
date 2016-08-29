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
    func repeatMethodViewControllerDidChooseRepeatMethod(controller: RepeatMethodViewController, useNoPattern: Bool, useCustomPattern: Bool, useDayPattern: Bool)
    func repeatMethodViewControllerIsDone()
    func repeatMethodViewControllerDidCancel()
    
    
}


class RepeatMethodViewController: UITableViewController, PatternPickerViewControllerDelegate, DaysOfTheWeekPickerViewControllerDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var patternLabel: UILabel!
    @IBOutlet weak var daysLabel: UILabel!
    
    // MARK: Next Date Example
    
    @IBOutlet weak var nextDateExampleLabel: UILabel!
    
    // Cells
    @IBOutlet weak var selectCustomPatternCell: UITableViewCell!
    @IBOutlet weak var selectDayPatternCell: UITableViewCell!
    @IBOutlet weak var selectNoPatternCell: UITableViewCell!
    
    // MARK: Repeat pattern
    var selectedInterval: String? = "minute"
    var selectedFrequency: Int? = 1
    
    // MARK: Selected Days
    var selectedDays = [Int]()
    
    // MARK: Method choice
    var usingNoPattern = true
    var usingCustomPattern = false
    var usingDayPattern = false
    
    // MARK: Delegate
    
    weak var delegate: RepeatMethodViewControllerDelegate?
    
    // MARK: Actions
    
    @IBAction func done() {
        if let selectedFrequency = selectedFrequency, let selectedInterval = selectedInterval {
            delegate?.repeatMethodViewControllerDidChooseCustomPattern(self, frequency: selectedFrequency, interval: selectedInterval)
        }
        
        delegate?.repeatMethodViewControllerDidChooseWeekDayPattern(self, days: selectedDays)
        
        delegate?.repeatMethodViewControllerDidChooseRepeatMethod(self,
                                                                  useNoPattern: usingNoPattern,
                                                                  useCustomPattern: usingCustomPattern,
                                                                  useDayPattern: usingDayPattern)
        delegate?.repeatMethodViewControllerIsDone()
    }
    
    @IBAction func cancel() {
        delegate?.repeatMethodViewControllerDidCancel()
    }
    
    
    // MARK: Pattern Picker View Controller Delegate
    func patternPickerViewControllerDidChoosePattern(controller: PatternPickerViewController, frequency: Int, interval: String) {
        selectedInterval = interval
        selectedFrequency = frequency
        
        updatePatternLabel()
    }
    
    // MARK: Days of the week view controller delegate
    func daysOfTheWeekPickerViewControllerDidCancel(controller: DayOfTheWeekPickerViewController) {
        updateDayLabel()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func daysOfTheWeekPickerViewControllerDidChooseDay(controller: DayOfTheWeekPickerViewController, days: [Int]) {
        print(#function)
        
        selectedDays = days
        updateDayLabel()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePatternLabel()
        updateDayLabel()
        updateSelectedMethod()
    }
    
    // MARK: Table View
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(#function)
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                usingNoPattern = true
                usingCustomPattern = false
                usingDayPattern = false
                
                updateSelectedMethod()
            } else if indexPath.row == 1 {
                usingNoPattern = false
                usingCustomPattern = true
                usingDayPattern = false
                
                updateSelectedMethod()
            } else if indexPath.row == 2 {
                usingNoPattern = false
                usingCustomPattern = false
                usingDayPattern = true
                
                updateSelectedMethod()
            }
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
        } else if segue.identifier == "PickWeekday" {
            print("Setting delegate to weekday")
            let navigationController = segue.destinationViewController as? UINavigationController
            let dayOfTheWeekPickerViewController = navigationController?.viewControllers[0] as? DayOfTheWeekPickerViewController
            dayOfTheWeekPickerViewController?.delegate = self
            
            dayOfTheWeekPickerViewController?.selectedDays = selectedDays
            
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
            patternLabel.text = "No pattern"
        }
    }
    
    func updateDayLabel() {
        var stringOfDays = ""
        if selectedDays.count > 0 {
            for day in selectedDays {
                switch day {
                case 1:
                    stringOfDays.appendContentsOf("Sun")
                case 2:
                    stringOfDays.appendContentsOf("Mon")
                case 3:
                    stringOfDays.appendContentsOf("Tue")
                case 4:
                    stringOfDays.appendContentsOf("Wed")
                case 5:
                    stringOfDays.appendContentsOf("Thu")
                case 6:
                    stringOfDays.appendContentsOf("Fri")
                case 7:
                    stringOfDays.appendContentsOf("Sat")
                default:
                    print("Error appending strings of days")
                }
                if selectedDays.count > 1 {
                    // Do not print comma after last word
                    if selectedDays.indexOf(day) < selectedDays.count - 1 {
                        stringOfDays.appendContentsOf(", ")
                    }
                }
            }
            daysLabel.text = stringOfDays
        } else {
            daysLabel.text = "No chosen days"
        }
    }
    
    func updateSelectedMethod() {
        if usingNoPattern {
            selectNoPatternCell.accessoryType = .Checkmark
            selectCustomPatternCell.accessoryType = .None
            selectDayPatternCell.accessoryType = .None
        } else {
            selectNoPatternCell.accessoryType = .None
            if usingCustomPattern {
                selectCustomPatternCell.accessoryType = .Checkmark
                selectDayPatternCell.accessoryType = .None
            } else if usingDayPattern {
                selectCustomPatternCell.accessoryType = .None
                selectDayPatternCell.accessoryType = .Checkmark
            }
        }
        
    }
}
