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
                                   didFinishEditingReminder reminder: Reminder)
    
    func addReminderViewControllerDidFinishAdding(controller: AddReminderViewController)
    
    func addReminderViewController(controller: AddReminderViewController,
                                   didChooseToDeleteReminder reminder: Reminder)
    
}

class AddReminderViewController: UITableViewController, UITextFieldDelegate, DatePickerViewControllerDelegate, RepeatMethodViewControllerDelegate {
    
    // MARK: Properties
    
    // CoreData
    var managedObjectContext: NSManagedObjectContext!
    
    var reminderToEdit: Reminder?
    var list: List!
    
    // Delegate
    weak var delegate: AddReminderViewControllerDelegate?
    
    var textFieldHasText = false
    var creatingReminder = false

    
    // The Date
    var selectedDate: NSDate?
    
    var selectedInterval: String?
    var selectedFrequency: Int?
    
    var dueDateIsSet = false
    
    var nextReminderDate: NSDate?
   
    var willSetNewDate = false
    
    // MARK: Outlets
    
    // Unwind segue
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
        print("Unwind to Add Reminder View Controller")
    }
   
    // Fields
    
    @IBOutlet weak var reminderNameField : UITextField!
    
    // Labels
    
    @IBOutlet weak var dueDateLabel : UILabel!
    @IBOutlet weak var recurringDateLabel : UILabel!
    
    // Buttons
    
    @IBOutlet weak var doneBarButton : UIBarButtonItem!
    
    // Switches
    
    // @IBOutlet weak var reminderRepeatsSwitch: UISwitch!
    
    // Pickers
    
    var repeatsCell = UITableViewCell()
    var enableRepeatsCell = UITableViewCell()
    
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var datePickerVisible = false {
        didSet {
            print("Datepicker was set from \(oldValue) to \(datePickerVisible)")
        }
    }
    
    @IBOutlet weak var recurringPickerCell: UITableViewCell!
    @IBOutlet weak var recurringPicker: UIPickerView!
    
    var reccuringPickerVisible = false {
        didSet {
            print("Recurring was set from \(oldValue) to \(reccuringPickerVisible)")
        }
    }
    
    // MARK: - Actions
    
    // MARK: Bar items
    
    @IBAction func cancel() {
        NSLog(#function)
        reminderNameField.resignFirstResponder()
        
        let alert = UIAlertController(title: "Are you sure?", message: "You will lose all changes", preferredStyle: .Alert)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let confirm = UIAlertAction(title: "Confirm", style: .Default, handler: {
            action in
            self.delegate?.addReminderViewControllerDidCancel(self)
        })
        alert.addAction(cancel)
        alert.addAction(confirm)
        if textFieldHasText {
            presentViewController(alert, animated: true, completion: nil)
        } else {
            delegate?.addReminderViewControllerDidCancel(self)
        }
    }
    
    @IBAction func saveReminder() {
        reminderNameField.resignFirstResponder()
        
        // Save or update Reminder
        if let reminder = reminderToEdit {
            updateReminder(reminder)
            
            // Save MOC
            do {
                try managedObjectContext.save()
                delegate?.addReminderViewController(self, didFinishEditingReminder: reminder)
            } catch {
                fatalCoreDataError(error)
            }
        } else {
            createReminder()
            
            // Save MOC
            do {
                try managedObjectContext.save()
                delegate?.addReminderViewControllerDidFinishAdding(self)
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    
    func createReminder() {
        let reminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder",
                                                                           inManagedObjectContext: managedObjectContext) as? Reminder
        
        // Title
        reminder!.setTitle(reminderNameField.text!)
        
        // Set Dates
        reminder!.setDate(selectedDate!)
        
        // Repeat Pattern
        if let frequency = selectedFrequency, let interval = selectedInterval {
            reminder!.setRepeatInterval(interval)
            reminder!.setRepeatFrequency(frequency)
            reminder!.setRecurring(true)
        } else {
            reminder!.setRecurring(false)
        }
        
        // Set to incomplete
        reminder!.setCompletionStatus(false)
        
        // Set to unfavorite
        reminder!.setFavorite(false)
        
        // Add to list
        reminder!.addToList(list)
        
        // Update amount of reminders
        let nbOfReminders = list.numberOfReminders.integerValue
        list.numberOfReminders = NSNumber(integer: nbOfReminders + 1)
        
        // Set reminder ID
        reminder?.addIDtoReminder()
        
        // Create notification
        let notificationHandler = reminder!.notificationHandler
        notificationHandler.scheduleNotifications(reminder!)
    }
    
    func updateReminder(reminder: Reminder) {
        // Title
        reminder.setTitle(reminderNameField.text!)
        
        // Set Dates
        reminder.setDate(selectedDate!)
        
        // Repeat Pattern
        if let frequency = selectedFrequency, let interval = selectedInterval {
            reminder.setRepeatInterval(interval)
            reminder.setRepeatFrequency(frequency)
            reminder.setRecurring(true)
        } else {
            reminder.setRepeatInterval(nil)
            reminder.setRepeatFrequency(nil)
            reminder.setRecurring(false)
        }
        
        // Do not set past reminders to incomplete
        // Do not set notifications for reminders that are already in the past
        if reminder.dueDate.isPresent() {
            
            // Set completion status
            reminder.setCompletionStatus(false)
            
            // Create notification
            let notificationHandler = reminder.notificationHandler
            notificationHandler.scheduleNotifications(reminder)
        }
    }
    
    // MARK: - Deinit 
    
    deinit {
        print(#function)
        print(self)
    }
    
    // MARK: - VIEW
    
    // MARK: Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let reminder = reminderToEdit {
            prepareViewForReminder(reminder)
        } else {
            creatingReminder = true
            // reminderRepeatsSwitch.enabled = false
        }
        
        enableDoneButton()
    }
    
    func prepareViewForReminder(reminder: Reminder) {
        title = reminder.name
        
        // Set textfield
        reminderNameField.text = reminder.name
        
        // Get Date into memomry
        selectedDate = reminder.dueDate
        dueDateIsSet = true
        
        // Update due date label
        setDueDateLabel(with: selectedDate!)
        
        // Update repeat interval
        if reminder.isRecurring == true {
            if let interval = reminderToEdit?.typeOfInterval, let frequency = reminderToEdit?.everyAmount {
                selectedInterval = interval
                selectedFrequency = frequency as Int
            }
            updateRecurringLabel()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateRecurringLabel()
    }
    
    // MARK: - Date Picker View Controller Delegate
    
    func datePickerViewControllerDidChooseDate(controller: DatePickerViewController, date: NSDate) {
        dismissViewControllerAnimated(true, completion: nil)
        selectedDate = date
        setDueDateLabel(with: selectedDate!)
        
        dueDateIsSet = true
        enableDoneButton()
    }
    
    // MARK: - Repeat Method View Controller Delegate
    func repeatMethodViewControllerDidChooseCustomPattern(controller: RepeatMethodViewController, frequency: Int, interval: String) {
        print("Arrived  with \(interval) and \(frequency)")
        selectedInterval = interval
        selectedFrequency = frequency
        // What if I set date after setting how I want the reminder to repeat itself?
        // nextReminderDate = addRecurringDate(selectedFrequency!, delayType: selectedInterval!, date: selectedDate!)
    }
    
    func repeatMethodViewControllerDidChooseWeekDayPattern(controller: RepeatMethodViewController, days: [Int]) {
        
    }
    
    func repeatMethodViewControllerDidDeletePattern() {
        selectedInterval = nil
        selectedFrequency = nil
        updateRecurringLabel()
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "OpenDatePicker" {
            let datePickerViewController = segue.destinationViewController as? DatePickerViewController
            datePickerViewController?.delegate = self
            
            // Send date
            datePickerViewController?.date = selectedDate
        }
        
        if segue.identifier == "PickRepeatMethod" {
            let repeatMethodViewController = segue.destinationViewController as? RepeatMethodViewController
            repeatMethodViewController?.delegate = self
            
            repeatMethodViewController?.selectedInterval = selectedInterval
            repeatMethodViewController?.selectedFrequency = selectedFrequency
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 {
            return 100
        } else {
            return 50
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let notificationHandler = NotificationHandler()
        notificationHandler.setNotifications()
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        reminderNameField.resignFirstResponder()
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 1 && indexPath.row == 2 {
            return nil
        } else {
            return indexPath
        }
    }
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Do not highlight auto snooze line
        if indexPath.section == 1 && indexPath.row == 2 {
            return false
        } else {
            return true
        }
    }

    // MARK: - Interface
    
    func enableDoneButton() {
        if dueDateIsSet && textFieldHasText {
            doneBarButton.enabled = true
        } else {
            doneBarButton.enabled = false
        }
    }

    // MARK: - Text Field
    
    // Listen to textfield
    
    func textField(textField: UITextField,
                   shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool {
        
        let oldText: NSString = textField.text!
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)

        textFieldHasText = newText.length > 0
        
        if textFieldHasText {
            textField.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.1)
        }

        enableDoneButton()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        let someText: NSString = textField.text!
        textFieldHasText = someText.length > 0
        enableDoneButton()
        //hideDatePicker()
        if textFieldHasText {
            textField.returnKeyType = .Next
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textFieldHasText {
            textField.resignFirstResponder()
        } else {
            textField.placeholder = "You have to give your reminder a name"
            textField.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.1)
        }
        return false
    }
    
    // MARK: - Date Picker
    
    func setDueDateLabel(with date: NSDate) {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        
        dueDateLabel.text = formatter.stringFromDate(date)
        enableDoneButton()
        
    }
    
    // MARK: - Reccurring Picker
    
    func updateRecurringLabel() {
        if let frequency = selectedFrequency, let interval = selectedInterval {
            if selectedFrequency != 1 {
                recurringDateLabel.text = "every " + "\(frequency) " + "\(interval)" + "s"
            } else if selectedFrequency == 1 {
                recurringDateLabel.text = "every " + "\(interval)"
            }
        } else {
            recurringDateLabel.text = "Doesn't repeat"
        }
    }
}
