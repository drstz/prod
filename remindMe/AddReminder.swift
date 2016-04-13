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

class AddReminderViewController: UITableViewController, UITextFieldDelegate {
    
    var reminderNameIsEmpty = true
    var reminderDateIsEmpty = true
    
    var reminderToEdit: Reminder?
    var indexPathToEdit: Int?
    
    weak var delegate: AddReminderViewControllerDelegate?
    
    @IBOutlet weak var reminderNameField : UITextField!
    @IBOutlet weak var reminderOccurenceField : UITextField!
    
    @IBOutlet weak var doneBarButton : UIBarButtonItem!
    
    @IBAction func cancel() {
        delegate?.addReminderViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        
        if let reminder = reminderToEdit {
            reminder.name = reminderNameField.text!
            reminder.occurence = reminderOccurenceField.text!
            if let index = indexPathToEdit {
                delegate?.addReminderViewController(self, didFinishEditingReminder: reminder, anIndex: index)
            }
            
        } else {
            let reminder = Reminder()
            reminder.name = reminderNameField.text!
            reminder.occurence = reminderOccurenceField.text!
            reminder.countdown = "5 minutes"
            
            delegate?.addReminderViewController(self, didFinishAddingReminder: reminder)
        }
    }
    
    // Prevent rows from being selected
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        return nil 
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Put curser into textfield immediately
        reminderNameField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let reminder = reminderToEdit {
            title = "Edit reminder"
            doneBarButton.enabled = true
            reminderNameField.text = reminder.name
            reminderOccurenceField.text = reminder.occurence
        }
    }
    
    // MARK: - Text Field
    
    func textField(textField: UITextField,
                   shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool {
        
        let oldText: NSString = textField.text!
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        

        
        if newText.length > 0 {
            if textField.tag == 1 {
                reminderNameIsEmpty = false
            } else if textField.tag == 2 {
                reminderDateIsEmpty = false
            }
        } else {
            if textField.tag == 1 {
                reminderNameIsEmpty = true
            } else if textField.tag == 2 {
                reminderDateIsEmpty = true
            }
        }
        fieldsAreEmpty()
        
        return true
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 2 {
            if reminderNameIsEmpty {
                textField.returnKeyType = .Next
            } else {
                textField.returnKeyType = .Done
            }
            
        }
        
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 1 {
            reminderOccurenceField.becomeFirstResponder()
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
    
    func fieldsAreEmpty() {
        if !reminderNameIsEmpty && !reminderDateIsEmpty {
            doneBarButton.enabled = true
        } else {
            doneBarButton.enabled = false
        }
    }


    
}
