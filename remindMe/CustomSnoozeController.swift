//
//  customDateController.swift
//  remindMe
//
//  Created by Duane Stoltz on 27/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

protocol CustomSnoozePickerDelegate: class {
    func customSnoozePickerDidCancel(_ controller: CustomSnoozePickerController)
    func customSnoozePicker(_ controller: CustomSnoozePickerController, didChooseTime delay: Double, unit: SnoozeUnit)
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
    
    func setColorTheme() {
        // Table view background
        tableView.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        
        // Table view separator
        tableView.separatorColor = UIColor.white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setColorTheme()
        snoozePicker.backgroundColor = UIColor.clear
        
        textField.backgroundColor = UIColor.clear
        textField.borderStyle = .none
        textField.textColor = UIColor.white
        textField.attributedPlaceholder = NSAttributedString(string: "Please enter a number",
                                                             attributes: [NSForegroundColorAttributeName:UIColor.white])
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        tableView.addGestureRecognizer(gesture)
    }
    
    func dismissKeyboard() {
        print(#function)
        textField.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textField.becomeFirstResponder()
        textField.keyboardType = .numberPad
        
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
        doneButton.isEnabled = false
    }
    
    func enableDoneButton() {
        doneButton.isEnabled = true
    }
    
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
        if indexPath.row == 1 && indexPath.section == 1 {
            textField.resignFirstResponder()
        }
    }
    
}

extension CustomSnoozePickerController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
//    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        switch row {
//        case 0:
//            return "seconds"
//        case 1:
//            return "minutes"
//        case 2:
//            return "hours"
//        case 3:
//            return "days"
//        default:
//            return "Error"
//        }
//    }
    
    // Use this to be able to set color
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = ""
        switch row {
        case 0:
            title = "seconds"
        case 1:
            title = "minutes"
        case 2:
            title = "hours"
        case 3:
            title = "days"
        default:
            title = "Error"
        }
        
        return NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName:UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
    
    func selectUnit(_ unit: SnoozeUnit) {
        switch unit {
        case .Seconds:
            snoozePicker.selectRow(0, inComponent: 0, animated: false)
        case .Minutes:
            snoozePicker.selectRow(1, inComponent: 0, animated: false)
        case .Hours:
            snoozePicker.selectRow(2, inComponent: 0, animated: false)
        case .Days:
            snoozePicker.selectRow(3, inComponent: 0, animated: false)
        }
    }
    
    
    
}

extension CustomSnoozePickerController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print(#function)
        
        if Int(string) != nil || range.length == 1 {
            let oldText: NSString = textField.text! as NSString
            let newText: NSString = oldText.replacingCharacters(in: range, with: string) as NSString
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
