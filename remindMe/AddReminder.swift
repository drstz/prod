//
//  AddReminder.swift
//  remindMe
//
//  Created by Duane Stoltz on 12/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Protocols

protocol AddReminderViewControllerDelegate: class {
    func addReminderViewControllerDidCancel(controller: AddReminderViewController)
    
    func addReminderViewController(controller: AddReminderViewController,
                                   didFinishAddingReminder reminder: Reminder)
    
    func addReminderViewController(controller: AddReminderViewController,
                                   didFinishEditingReminder reminder: Reminder)
}

// MARK: - Class

class AddReminderViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    var reminderNameIsValid = false
    var dueDateIsSet = false
    
    var inEditMode = false
    
    var textFieldisValid = false
    
    // Instances
    
    var reminderToEdit: Reminder?
    var indexPathToEdit: Int?
    
    // CoreData
    
    var managedObjectContext: NSManagedObjectContext!
    
    // The Date
    
    var dueDate: NSDate?
    var datePickerVisible = false

    // Delegate
    
    weak var delegate: AddReminderViewControllerDelegate?
    
    // MARK: Outlets
    
    // Fields
    
    @IBOutlet weak var reminderNameField : UITextField!
    
    // Labels
    
    @IBOutlet weak var dueDateLabel : UILabel!
    
    // Buttons
    
    @IBOutlet weak var doneBarButton : UIBarButtonItem!
    
    // Switch
    
    @IBOutlet weak var enableSwitch : UISwitch!
    
    // Date Picker
    
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: - Actions
    
    @IBAction func cancel() {
        //print(#function)
        delegate?.addReminderViewControllerDidCancel(self)
    }
    
    func getReminderDetails(inout reminder: Reminder) {
        print(#function)
        reminder.name = reminderNameField.text!
        reminder.dueDate = dueDate!
        reminder.isEnabled = enableSwitch.on
    }
    
    @IBAction func done() {
        print(#function)
        
        if var reminder = reminderToEdit {
            getReminderDetails(&reminder)

            inEditMode = false
            delegate?.addReminderViewController(self, didFinishEditingReminder: reminder)
        } else {
            var reminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: managedObjectContext) as! Reminder
            getReminderDetails(&reminder)
            
            reminder.isComplete = false 
            delegate?.addReminderViewController(self, didFinishAddingReminder: reminder)
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    // Date Picker
    
    @IBAction func dateChanged(datePicker: UIDatePicker) {
        dueDate = datePicker.date
        dueDateIsSet = true
        updateDueDateLabel()
    }
    
    // MARK: - Enable Done Button
    
    func enableDoneButton() {
        if dueDateIsSet && reminderNameIsValid || inEditMode {
            doneBarButton.enabled = true
        } else {
            doneBarButton.enabled = false
        }
    }

    
    // MARK: - VIEW
    
    

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //print(#function)
        
        // Put curser into textfield immediately
        reminderNameField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(#function)
        
        if let reminder = reminderToEdit {
            inEditMode = true
            title = "Edit reminder"
            doneBarButton.enabled = true
            reminderNameField.text = reminder.name
            dueDate = reminder.dueDate
            enableSwitch.on = reminder.isEnabled as Bool
        }
        updateDueDateLabel()
    }
    
    // MARK: - Date Picker
    
    func updateDueDateLabel() {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        if let date = dueDate {
            dueDateLabel.text = formatter.stringFromDate(date)
            enableDoneButton()
        } else {
            dueDateLabel.text = "Please Set a Date"
        }
        
    }
    
    func showDatePicker() {
        //print(#function)
        datePickerVisible = true
        
        let indexPathDateRow = NSIndexPath(forRow: 0, inSection: 1)
        let indexPathDatePicker = NSIndexPath(forRow: 1, inSection: 1)
        
        if let dateCell = tableView.cellForRowAtIndexPath(indexPathDateRow) {
            dateCell.detailTextLabel!.textColor = dateCell.detailTextLabel!.tintColor
        }
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
        tableView.reloadRowsAtIndexPaths([indexPathDateRow], withRowAnimation: .None)
        tableView.endUpdates()
        
        datePicker.minimumDate = NSDate()
        
        if let date = dueDate {
            datePicker.setDate(date, animated: false)
        } else {
            datePicker.setDate(NSDate(), animated: false)
        }
    }
    
    func hideDatePicker() {
        if datePickerVisible {
            datePickerVisible = false
            let indexPathDateRow = NSIndexPath(forRow: 0, inSection: 1)
            let indexPathDatePicker = NSIndexPath(forRow: 1, inSection: 1)
            
            if let dateCell = tableView.cellForRowAtIndexPath(indexPathDateRow) {
                if dueDateIsSet {
                    dateCell.detailTextLabel!.textColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.8)
                } else {
                    dateCell.detailTextLabel!.textColor = UIColor(white: 0, alpha: 0.5)
                }
            }
            
            tableView.beginUpdates()
            tableView.reloadRowsAtIndexPaths([indexPathDateRow], withRowAnimation: .None)
            tableView.deleteRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
            tableView.endUpdates()
            enableDoneButton()
        }
        
        
    }
    
    
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //print(#function)
        if indexPath.section == 1 && indexPath.row == 1 {
            return datePickerCell
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(#function)
        if section == 1 && datePickerVisible {
            return 2
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //print(#function)
        if indexPath.section == 1 && indexPath.row == 1 {
            return 217
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print(#function)
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
        //print(#function)
        print("Section: \(indexPath.section)")
        print("Row: \(indexPath.row)")
        if indexPath.section == 1 && indexPath.row == 0 && textFieldHasText(reminderNameField.text! as NSString) {
            return indexPath
        } else if !textFieldHasText(reminderNameField.text! as NSString) {
            reminderNameField.becomeFirstResponder()
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, var indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
       // print(#function)
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
        
        reminderNameIsValid = textFieldHasText(newText)
        textFieldisValid = textFieldHasText(oldText)
        
        if textFieldHasText(reminderNameField.text! as NSString) {
            textField.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.1)
        }
        //print(reminderNameIsValid)
        enableDoneButton()
        return true
    }
    
    func textFieldHasText(text : NSString) -> Bool {
        //print(#function)
        return text.length > 0
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //print(#function)
        hideDatePicker()
        if textFieldHasText(reminderNameField.text! as NSString) {
            textField.returnKeyType = .Next
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //print(#function)
        if textFieldHasText(reminderNameField.text! as NSString) {
            showDatePicker()
            textField.resignFirstResponder()
        } else {
            print(reminderNameIsValid)
            textField.placeholder = "You have to give your reminder a name"
            textField.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.1)
        }
        return false
    }
}
