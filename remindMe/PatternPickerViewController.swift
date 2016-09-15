//
//  PatternPickerViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 25/08/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

protocol PatternPickerViewControllerDelegate: class {
    func patternPickerViewControllerDidChoosePattern(_ controller: PatternPickerViewController, frequency: Int, interval: String)
}

class PatternPickerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var patternPopup: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    // MARK: Datepicker
    
    @IBOutlet weak var patternPicker: UIPickerView!
    
    // MARK: Buttons
    
    @IBOutlet weak var doneButton: UIButton!
    
    
    
    // MARK: - Delegates
    
    weak var delegate: PatternPickerViewControllerDelegate?
    
    // MARK: Pattern
    var selectedFrequency: Int?
    var selectedInterval: String?
    
    // MARK: Actions
    
    @IBAction func done() {
        print(#function)
        if let interval = selectedInterval, let frequency = selectedFrequency {
            print("Going back with \(interval) and \(frequency)")
            delegate?.patternPickerViewControllerDidChoosePattern(self, frequency: frequency, interval: interval)
            dismiss(animated: true, completion: nil)
            
        }
    }
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
        if let interval = selectedInterval, let frequency = selectedFrequency {
            print("Going back with \(interval) and \(frequency)")
            delegate?.patternPickerViewControllerDidChoosePattern(self, frequency: frequency, interval: interval)
            dismiss(animated: true, completion: nil)
            
        }
    }
    
    
    
    // MARK: Picker View Data Source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 59
        } else {
            return 6
        }
    }
    
    // MARK: Picker View Delegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let number = row
        if component == 0 {
            return "\(number + 1)"
        } else {
            switch row {
            case 0:
                return "minutes"
            case 1:
                return "hours"
            case 2:
                return "days"
            case 3:
                return "weeks"
            case 4:
                return "months"
            case 5:
                return "years"
            default:
                return "No idea"
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedFrequency = row + 1
            
        } else {
            switch row {
            case 0:
                selectedInterval = "minute"
            case 1:
                selectedInterval = "hour"
            case 2:
                selectedInterval = "day"
            case 3:
                selectedInterval = "week"
            case 4:
                selectedInterval = "month"
            case 5:
                selectedInterval = "year"
            default:
                print("Error")
            }
        }
        // updateRecurringLabel()
        
        //recurringDateWasSet = true
        
        //nextReminderDate = addRecurringDate(selectedFrequency!, delayType: selectedInterval!, date: selectedDate!)
        
        //print(nextReminderDate!)
    }
    
    
    // MARK: Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        patternPopup.layer.masksToBounds = true
        patternPopup.layer.cornerRadius = 10
        
        doneButton.layer.cornerRadius = 5
        doneButton.layer.borderWidth = 1
        doneButton.layer.borderColor = doneButton.tintColor.cgColor
        doneButton.backgroundColor = UIColor.white
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            backgroundView.backgroundColor = UIColor.clear
        } else {
            backgroundView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
        }
        
        // Select date automatically
        if selectedInterval == nil && selectedFrequency == nil {
            selectedInterval = "minute"
            selectedFrequency = 1
        }
        
        setPatternPicker()
    }
    
     // MARK: Picker Helper Methods
    func setPatternPicker() {
        var frequency = 1
        var interval = "minute"
        
        if let selectedFrequency = selectedFrequency , let selectedInterval = selectedInterval {
            frequency = selectedFrequency
            interval = selectedInterval
        }
        var intervalRow = 0
        
        patternPicker.selectRow((frequency) - 1, inComponent: 0, animated: false)
        
        switch interval {
        case "minute":
            intervalRow = 0
        case "hour":
            intervalRow = 1
        case "day":
            intervalRow = 2
        case "week":
            intervalRow = 3
        case "month":
            intervalRow = 4
        case "year":
            intervalRow = 5
        default:
            print("Date picking error")
            
        }
        patternPicker.selectRow(intervalRow, inComponent: 1, animated: false)
    }
    
    
}

extension PatternPickerViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                                          presenting: UIViewController?,
                                                                                   source: UIViewController) -> UIPresentationController? {
        
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension PatternPickerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
