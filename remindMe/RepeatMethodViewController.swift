//
//  RepeatMethodViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 25/08/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol RepeatMethodViewControllerDelegate: class {
    func repeatMethodViewControllerDidChooseCustomPattern(_ controller: RepeatMethodViewController, frequency: Int, interval: String)
    func repeatMethodViewControllerDidChooseWeekDayPattern(_ controller: RepeatMethodViewController, days: [Int])
    func repeatMethodViewControllerDidChooseRepeatMethod(_ controller: RepeatMethodViewController, useNoPattern: Bool, useCustomPattern: Bool, useDayPattern: Bool)
    func repeatMethodViewControllerIsDone()
    func repeatMethodViewControllerDidCancel()
    
    
}


class RepeatMethodViewController: UITableViewController, PatternPickerViewControllerDelegate, DaysOfTheWeekPickerViewControllerDelegate {
    
    // MARK: Outlets
    
    
    // MARK: Next Date Example
    
    @IBOutlet weak var nextDateExampleLabel: UILabel!
    
    // Cells
    @IBOutlet weak var selectCustomPatternCell: UITableViewCell!
    @IBOutlet weak var selectDayPatternCell: UITableViewCell!
    @IBOutlet weak var selectNoPatternCell: UITableViewCell!
    
    // Labels
    @IBOutlet weak var customPatternLabel: UILabel!
    @IBOutlet weak var dayPatternLabel: UILabel!
    
    @IBOutlet weak var createCustomPatternLabel: UILabel!
    @IBOutlet weak var createDaysPatternLabel: UILabel!
    
    // Subtitles
    @IBOutlet weak var customPatternSubtitleLabel: UILabel!
    @IBOutlet weak var dayPatternSubtitleLabel: UILabel!
    
    // MARK: Repeat pattern
    var selectedInterval: String?
    var selectedFrequency: Int?
    
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
    func patternPickerViewControllerDidChoosePattern(_ controller: PatternPickerViewController, frequency: Int, interval: String) {
        selectedInterval = interval
        selectedFrequency = frequency
        
        updatePatternLabel()
        updateRepeatMethodCells()
        updatePatternCreationLabels()
    }
    
    // MARK: Days of the week view controller delegate
    func daysOfTheWeekPickerViewControllerDidCancel(_ controller: DayOfTheWeekPickerViewController) {
        updateDayLabel()
        updateRepeatMethodCells()
        updatePatternCreationLabels()
        
        if selectedDays.count == 0 {
            selectMethodWithDate()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func daysOfTheWeekPickerViewControllerDidChooseDay(_ controller: DayOfTheWeekPickerViewController, days: [Int]) {
        print(#function)
        
        selectedDays = days
        updateDayLabel()
        updateRepeatMethodCells()
        updatePatternCreationLabels()
        
        if selectedDays.count == 0 {
            selectMethodWithDate()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func selectMethodWithDate() {
        if selectedDays.count == 0 {
            if selectedInterval != nil {
                let indexPath = IndexPath(row: 1, section: 0)
                tableView.selectRow(at: indexPath, animated: true , scrollPosition: .none)
                tableView(tableView, didSelectRowAt: indexPath)
            } else {
                let indexPath = IndexPath(row: 0, section: 0)
                tableView.selectRow(at: indexPath, animated: true , scrollPosition: .none)
                tableView(tableView, didSelectRowAt: indexPath)
            }
        } else if selectedInterval == nil {
            if selectedDays.count != 0 {
                let indexPath = IndexPath(row: 2, section: 0)
                tableView.selectRow(at: indexPath, animated: true , scrollPosition: .none)
                tableView(tableView, didSelectRowAt: indexPath)
            } else {
                let indexPath = IndexPath(row: 0, section: 0)
                tableView.selectRow(at: indexPath, animated: true , scrollPosition: .none)
                tableView(tableView, didSelectRowAt: indexPath)
            }
            
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColorTheme()
    }
    
    func setColorTheme() {
        // Table view background
        tableView.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        
        // Table view separator
        tableView.separatorColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updatePatternLabel()
        updateDayLabel()
        updateSelectedMethod()
        updateRepeatMethodCells()
        updatePatternCreationLabels()
    }
    
    // MARK: Table View
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        // header.titleLabel.textColor = UIColor.whiteColor()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red: 40/255, green: 82/255, blue: 108/255, alpha: 1)
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        cell.tintColor = UIColor.white
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function)
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 0 {
                usingNoPattern = true
                usingCustomPattern = false
                usingDayPattern = false
                
                updateSelectedMethod()
            } else if (indexPath as NSIndexPath).row == 1 {
                usingNoPattern = false
                usingCustomPattern = true
                usingDayPattern = false
                
                updateSelectedMethod()
                
                if selectedInterval == nil && selectedFrequency == nil {
                    performSegue(withIdentifier: "PickPattern", sender: nil)
                }
            } else if (indexPath as NSIndexPath).row == 2 {
                usingNoPattern = false
                usingCustomPattern = false
                usingDayPattern = true
                
                updateSelectedMethod()
                
                if selectedDays.count == 0 {
                    performSegue(withIdentifier: "PickWeekday", sender: nil)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickPattern" {
            let controller = segue.destination as? PatternPickerViewController
            
            controller?.delegate = self
            controller?.selectedFrequency = selectedFrequency
            controller?.selectedInterval = selectedInterval
        } else if segue.identifier == "PickWeekday" {
            print("Setting delegate to weekday")
            let navigationController = segue.destination as? UINavigationController
            let dayOfTheWeekPickerViewController = navigationController?.viewControllers[0] as? DayOfTheWeekPickerViewController
            dayOfTheWeekPickerViewController?.delegate = self
            
            dayOfTheWeekPickerViewController?.selectedDays = selectedDays
            
        }
    }
    
    // MARK: Helper methods
    func updatePatternLabel() {
        if let frequency = selectedFrequency, let interval = selectedInterval {
            if selectedFrequency != 1 {
                customPatternSubtitleLabel.text = "every " + "\(frequency) " + "\(interval)" + "s"
            } else if selectedFrequency == 1 {
                customPatternSubtitleLabel.text = "every " + "\(interval)"
            }
        }
    }
    
    func updateDayLabel() {
        var stringOfDays = ""
        if selectedDays.count > 0 {
            for day in selectedDays {
                switch day {
                case 1:
                    stringOfDays.append("Sun")
                case 2:
                    stringOfDays.append("Mon")
                case 3:
                    stringOfDays.append("Tue")
                case 4:
                    stringOfDays.append("Wed")
                case 5:
                    stringOfDays.append("Thu")
                case 6:
                    stringOfDays.append("Fri")
                case 7:
                    stringOfDays.append("Sat")
                default:
                    print("Error appending strings of days")
                }
                if selectedDays.count > 1 {
                    // Do not print comma after last word
                    if selectedDays.index(of: day) < selectedDays.count - 1 {
                        stringOfDays.append(", ")
                    }
                }
            }
            dayPatternSubtitleLabel.text = stringOfDays
        }
    }
    
    func updateSelectedMethod() {
        if usingNoPattern {
            selectNoPatternCell.accessoryType = .checkmark
            selectCustomPatternCell.accessoryType = .none
            selectDayPatternCell.accessoryType = .none
        } else {
            selectNoPatternCell.accessoryType = .none
            if usingCustomPattern {
                selectCustomPatternCell.accessoryType = .checkmark
                selectDayPatternCell.accessoryType = .none
            } else if usingDayPattern {
                selectCustomPatternCell.accessoryType = .none
                selectDayPatternCell.accessoryType = .checkmark
            }
        }
        
    }
    
    func updateRepeatMethodCells() {
        if selectedDays.count > 0 {
            dayPatternLabel.text = "Repeat every"
        } else {
            dayPatternLabel.text = "Repeat on selected days of the week"
            dayPatternSubtitleLabel.text = ""
        }
        
        if selectedInterval != nil && selectedInterval != nil {
            customPatternLabel.text = "Repeat every"
        } else {
            customPatternLabel.text = "Repeat using a custom interval"
            customPatternSubtitleLabel.text = ""
        }
    }
    
    func updatePatternCreationLabels() {
        if selectedDays.count > 0 {
            createDaysPatternLabel.text = "Modify selected days of the week"
        } else {
            createDaysPatternLabel.text = "Choose days of the week"
        }
        
        if selectedInterval != nil && selectedInterval != nil {
            createCustomPatternLabel.text = "Modify custom interval"
        } else {
            createCustomPatternLabel.text = "Set custom interval"
        }
    }
}
