//
//  AddReminder.swift
//  remindMe
//
//  Created by Duane Stoltz on 12/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

// MARK: - Protocols

protocol AddReminderViewControllerDelegate: class {
    func addReminderViewControllerDidCancel(controller: AddReminderViewController)
    
    func addReminderViewController(controller: AddReminderViewController,
                                   didFinishAddingReminder reminder: Reminder)
    
    func addReminderViewController(controller: AddReminderViewController,
                                   didFinishEditingReminder reminder: Reminder,
                                                            anIndex: Int?)
}

// MARK: - Class

class AddReminderViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    var reminderNameIsEmpty = true
    var reminderDateIsEmpty = true
    
    var reminderToEdit: Reminder?
    var indexPathToEdit: Int?
    
    // The Date Picker
    var datePickerVisible = false
    
    weak var delegate: AddReminderViewControllerDelegate?
    
    // MARK: Outlets
    
    // Fields
    
    @IBOutlet weak var reminderNameField : UITextField!
    @IBOutlet weak var reminderOccurenceField : UITextField!
    
    // Buttons
    
    @IBOutlet weak var doneBarButton : UIBarButtonItem!
    
    // Date Picker
    
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: - Actions
    
    @IBAction func cancel() {
        print(#function)
        delegate?.addReminderViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        print(#function)
        
        if let reminder = reminderToEdit {
            reminder.name = reminderNameField.text!

            if let index = indexPathToEdit {
                delegate?.addReminderViewController(self, didFinishEditingReminder: reminder, anIndex: index)
            }
            
        } else {
            let reminder = Reminder()
            reminder.name = reminderNameField.text!

            reminder.countdown = "5 minutes"
            
            delegate?.addReminderViewController(self, didFinishAddingReminder: reminder)
        }
    }
    
    // Date Picker
    

    
    // MARK: - VIEW
    
    

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(#function)
        
        // Put curser into textfield immediately
        reminderNameField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
        if let reminder = reminderToEdit {
            title = "Edit reminder"
            doneBarButton.enabled = true
            reminderNameField.text = reminder.name

        }
    }
    
    // MARK: - Date Picker
    
    func showDatePicker() {
        print(#function)
        datePickerVisible = true
        
        let indexPathDatePicker = NSIndexPath(forRow: 1, inSection: 1)
        tableView.insertRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
    }
    
    func hideDatePicker() {
        if datePickerVisible {
            datePickerVisible = false
            let indexPathDateRow = NSIndexPath(forRow: 0, inSection: 1)
            let indexPathDatePicker = NSIndexPath(forRow: 1, inSection: 1)
            
            tableView.beginUpdates()
            tableView.reloadRowsAtIndexPaths([indexPathDateRow], withRowAnimation: .None)
            tableView.deleteRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
            tableView.endUpdates()
        }
        
        
    }
    
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print(#function)
        if indexPath.section == 1 && indexPath.row == 1 {
            return datePickerCell
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(#function)
        if section == 1 && datePickerVisible {
            return 2
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        print(#function)
        if indexPath.section == 1 && indexPath.row == 1 {
            return 217
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(#function)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        reminderNameField.resignFirstResponder()
        
        if indexPath.section == 1 && indexPath.row == 0 {
            if !datePickerVisible {
                showDatePicker()
            } else {
                hideDatePicker()
            }
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        // Prevent rows from being selected
        print(#function)
        print("Section: \(indexPath.section)")
        print("Row: \(indexPath.row)")
        if indexPath.section == 1 && indexPath.row == 0 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, var indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        print(#function)
        if indexPath.section == 1 && indexPath.row == 1 {
            indexPath = NSIndexPath(forRow: 0, inSection: indexPath.section)
        }
        return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
    }
    
    // MARK: - Text Field
    
    // Listen to textfield
    
    func textField(textField: UITextField,
                   shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool {
        
        let oldText: NSString = textField.text!
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        
    
        chooseEmptyTextField(textField, isEmpty: textFieldIsEmpty(newText))
        if reminderNameIsEmpty {
            if reminderDateIsEmpty {
 
            }
        } else {

        }
        fieldsAreEmpty()
        print(#function)
        return true
    }
    
    func textFieldIsEmpty(text : NSString) -> Bool {
        return text.length == 0
    }
    
    func chooseEmptyTextField(textFieldtoCheck : UITextField, isEmpty: Bool) {
        switch textFieldtoCheck.tag {
        case 1:
            reminderNameIsEmpty = isEmpty
            if reminderNameIsEmpty {
            }
        case 2:
            reminderDateIsEmpty = isEmpty
        default:
            print("ERROR")
        }
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        print(#function)
        hideDatePicker()
        if textField.tag == 2 {
            if reminderNameIsEmpty {
                textField.returnKeyType = .Next
            } else {
                textField.returnKeyType = .Done
            }
        }
    }
    

    
    func fieldsAreEmpty() {
        print(#function)
        if !reminderNameIsEmpty && !reminderDateIsEmpty {
            doneBarButton.enabled = true
        } else {
            doneBarButton.enabled = false
        }
    }
    

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print(#function)
        if textField.tag == 1 {
            return false
        } else {
            if doneBarButton.enabled == true {
                return true
            } else if doneBarButton.enabled == false {
                if reminderNameIsEmpty {
                    reminderNameField.becomeFirstResponder()
                }
                return false
            }
            
        }
        return false
        
    }
    



    
}
