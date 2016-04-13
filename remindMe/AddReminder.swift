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
    
    weak var delegate: AddReminderViewControllerDelegate?
    
    // MARK: Outlets
    
    @IBOutlet weak var reminderNameField : UITextField!
    @IBOutlet weak var reminderOccurenceField : UITextField!
    
    @IBOutlet weak var doneBarButton : UIBarButtonItem!
    
    // MARK: - Actions
    
    @IBAction func cancel() {
        print(#function)
        delegate?.addReminderViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        print(#function)
        
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
    
    // MARK: - VIEW
    
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        // Prevent rows from being selected
        print(#function)
        return nil
    }
    
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
            reminderOccurenceField.text = reminder.occurence
        }
        
        reminderOccurenceField.enabled = false
        

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
                reminderOccurenceField.enabled = false
            }
        } else {
            reminderOccurenceField.enabled = true
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
    



    
}
