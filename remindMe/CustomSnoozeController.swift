//
//  customDateController.swift
//  remindMe
//
//  Created by Duane Stoltz on 27/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

protocol CustomSnoozePickerDelegate: class {
    func customSnoozePickerDidCancel(controller: CustomSnoozePickerController)
    func customSnoozePicker(controller: CustomSnoozePickerController, didChooseTime delay: Double, unit: SnoozeUnit)
}

class CustomSnoozePickerController: UITableViewController {
    @IBOutlet weak var snoozePicker: UIPickerView!
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    
    var delegate: CustomSnoozePickerDelegate?
    
    var delay: Double?
    var unit: SnoozeUnit?
    
    
    
    @IBAction func cancel() {
        delegate?.customSnoozePickerDidCancel(self)
    }
    
    @IBAction func done() {
        if textField.text != nil {
            textField.resignFirstResponder()
            delay = Double(textField.text!)
        }
        if let chosenDelay = delay, let chosenUnit = unit {
            delegate?.customSnoozePicker(self, didChooseTime: chosenDelay, unit: chosenUnit)
        } else {
            textField.becomeFirstResponder()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        textField.becomeFirstResponder()
        textField.keyboardType = .NumberPad
        
        if let unitToSelect = unit, let durationToAdd = delay {
            selectUnit(unitToSelect)
            if delay == 0 {
                textField.placeholder = "Please enter a number"
                textField.text = nil
            } else {
                textField.text = String(Int(durationToAdd))
            }
            
        }
        
        checkTextFieldLength()
        
    }
    
    func disableDoneButton() {
        doneButton.enabled = false
    }
    
    func enableDoneButton() {
        doneButton.enabled = true
    }
    
}

extension CustomSnoozePickerController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0:
            return "seconds"
        case 1:
            return "minutes"
        case 2:
            return "hours"
        case 3:
            return "days"
        default:
            return "Error"
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            unit = .Seconds
        case 1:
            unit = .Minutes
        case 2:
            unit = .Hours
        case 3:
            unit = .Days
        default:
            unit = nil
        }
    }
    
    func selectUnit(unit: SnoozeUnit) {
        switch unit {
        case .Seconds:
            snoozePicker.selectRow(0, inComponent: 0, animated: false)
        case .Minutes:
            snoozePicker.selectRow(1, inComponent: 0, animated: false)
        case .Hours:
            snoozePicker.selectRow(2, inComponent: 0, animated: false)
        case .Days:
            snoozePicker.selectRow(3, inComponent: 0, animated: false)
        default:
            snoozePicker.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    
    
}

extension CustomSnoozePickerController: UITextFieldDelegate {
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        print(#function)
        
        if Int(string) != nil || range.length == 1 {
            let oldText: NSString = textField.text!
            let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
            if newText.length > 0 {
                enableDoneButton()
            } else {
                disableDoneButton()
            }
            print(oldText)
            print(newText)
            print(string)
            return true
        } else {
            return false
        }
    }
    
    func checkTextFieldLength() {
        if textField.text?.characters.count == 0 {
            disableDoneButton()
        } else {
            enableDoneButton()
        }
    }
    
    
}
