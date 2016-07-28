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
    func customSnoozePicker(controller: CustomSnoozePickerController, didChooseTime delay: Int, unit: String)
}

class CustomSnoozePickerController: UITableViewController {
    @IBOutlet weak var snoozePicker: UIPickerView!
    @IBOutlet weak var textField: UITextField!
    
    
    var delegate: CustomSnoozePickerDelegate?
    
    var delay: Int?
    var unit: String?
    
    @IBAction func cancel() {
        delegate?.customSnoozePickerDidCancel(self)
    }
    
    @IBAction func done() {
        if textField.text != nil {
            delay = Int(textField.text!)
        }
        if let chosenDelay = delay, let chosenUnit = unit {
            delegate?.customSnoozePicker(self, didChooseTime: chosenDelay, unit: chosenUnit)
        } else {
            textField.becomeFirstResponder()
        }
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
            unit = "seconds"
        case 1:
            unit = "minutes"
        case 2:
            unit = "hours"
        case 3:
            unit = "days"
        default:
            unit = nil
        }
    }
    
}

extension CustomSnoozePickerController: UITextFieldDelegate {
    
    
}
