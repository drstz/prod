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
    
    func addReminderViewController(controller: AddReminderViewController,
                                   didChooseToDeleteReminder reminder: Reminder)
    
}

class AddReminderViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    
    var selectedInterval: String? = "minute"
    var selectedFrequency: Int? = 1
    
    var dueDateIsSet = false
    
    var nextReminderDate: NSDate?
    var reminderRepeats = false
    var recurringDateWasSet = false
    
    
    var willSetNewDate = false
    
    // MARK: Outlets
   
    // Fields
    
    @IBOutlet weak var reminderNameField : UITextField!
    
    // Labels
    
    @IBOutlet weak var dueDateLabel : UILabel!
    @IBOutlet weak var recurringDateLabel : UILabel!
    
    // Buttons
    
    @IBOutlet weak var doneBarButton : UIBarButtonItem!
    @IBOutlet weak var completeButton: UIButton!
    
    // Switches
    
    @IBOutlet weak var reminderRepeatsSwitch: UISwitch!
    
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
        
        var reminder : Reminder?
        
        func getReminderDetails(inout reminder: Reminder) {
            
            reminder.setTitle(reminderNameField.text!)
            reminder.setDate(selectedDate!)
            
            if let nextDueDate = nextReminderDate {
                reminder.setNextDate(nextDueDate)
                reminder.setRepeatInterval(selectedInterval)
                reminder.setRepeatFrequency(selectedFrequency)
            } else {
                reminder.setNextDate(nil)
                reminder.setRepeatInterval(nil)
                reminder.setRepeatFrequency(nil)
            }
            reminder.setRecurring(recurringDateWasSet)
            reminder.setCompletionStatus(false)
        }

        if reminderToEdit != nil {
            reminder = reminderToEdit
        } else {
            reminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: managedObjectContext) as? Reminder
            reminder?.setCompletionStatus(false)
            reminder?.setFavorite(false)
            reminder?.addToList(list)
            
            let nbOfReminders = list.numberOfReminders.integerValue
            list.numberOfReminders = NSNumber(integer: nbOfReminders + 1)
            reminder?.addIDtoReminder()
        }
        getReminderDetails(&reminder!)
        
        do {
            try managedObjectContext.save()
            if reminder != nil {
                let reminderNotificationHandler = reminder!.notificationHandler
                reminderNotificationHandler.scheduleNotifications(reminder!)
                delegate?.addReminderViewController(self, didFinishEditingReminder: reminder!)
            } else {
                print("Failure to schedule notification: no reminder")
            }
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    // MARK: Switches
    
    @IBAction func toggleRepeatDateForReminder() {
        reminderRepeats = reminderRepeatsSwitch.on
        if !reminderRepeats {
            if reccuringPickerVisible {
                hideRecurringPicker()
            }
            recurringDateLabel.text = "Doesn't repeat"
            
            nextReminderDate = nil
            recurringDateWasSet = false
        } else {
            showReccurringPicker()
        }
        
    }
    
    // MARK: Reminder Actions
    
    // MARK: Date Picker
    
    @IBAction func listenToDate(datePicker: UIDatePicker) {
        print(#function)
        selectedDate = datePicker.date.roundSecondsToZero()
        dueDateIsSet = true
        reminderRepeatsSwitch.enabled = true
        setDueDateLabel(with: selectedDate!)
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
            reminderRepeatsSwitch.enabled = false
        }
        
        enableDoneButton()
    }
    
    func prepareViewForReminder(reminder: Reminder) {
        title = reminder.name
        
        reminderNameField.text = reminder.name
        
        selectedDate = reminder.dueDate
        dueDateIsSet = true
        setDueDateLabel(with: selectedDate!)
        
        reminderRepeatsSwitch.enabled = true
        
        reminderRepeatsSwitch.on = reminder.isRecurring as Bool
        
        reminderRepeats = reminder.isRecurring as Bool
        recurringDateWasSet = reminder.isRecurring as Bool
        
        if let recurringDate = reminder.nextDueDate {
            nextReminderDate = recurringDate
            
            if let interval = reminderToEdit?.typeOfInterval {
                selectedInterval = interval
            }
            
            if let amount = reminderToEdit?.everyAmount {
                selectedFrequency = amount as Int
            }
            
            setRecurringPicker()
            updateRecurringLabel()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if willSetNewDate {
            showDatePicker()
        } else {
            reminderNameField.becomeFirstResponder()

        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && (datePickerVisible || reccuringPickerVisible){
            return 4
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 1 && indexPath.row == 1 && datePickerVisible {
            return 217
        } else if indexPath.section == 1 && indexPath.row == 3 && reccuringPickerVisible {
            return 217
        } else {
            return 50
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 1 && datePickerVisible {
            let notificationHandler = NotificationHandler()
            notificationHandler.setNotifications()
            return datePickerCell
        } else if indexPath.section == 1 && indexPath.row == 4 {
            return recurringPickerCell
        } else if indexPath.section == 1 && indexPath.row == 3 && datePickerVisible {
            return repeatsCell
        } else if indexPath.section == 1 && indexPath.row == 2 && datePickerVisible {
            return enableRepeatsCell
        } else if indexPath.section == 1 && indexPath.row == 3 && reccuringPickerVisible {
            return recurringPickerCell
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        var indexPathMod = indexPath
        
        if indexPathMod.section == 1 && indexPathMod.row == 1 && datePickerVisible {
            indexPathMod = NSIndexPath(forRow: 0, inSection: indexPathMod.section)
            
        } else if indexPathMod.section == 1 && indexPathMod.row == 4 {
            indexPathMod = NSIndexPath(forRow: 0, inSection: indexPathMod.section)
        } else if indexPathMod.section == 1 && indexPathMod.row == 3 {
            indexPathMod = NSIndexPath(forRow: 0, inSection: indexPathMod.section)
        }
        return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPathMod)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        reminderNameField.resignFirstResponder()
        
        if indexPath.section == 1 && indexPath.row == 0 {
            if !datePickerVisible {
                showDatePicker()
            } else {
                hideDatePicker()
            }
        }
        
        if indexPath.section == 1 && indexPath.row == 2 && dueDateIsSet && reminderRepeatsSwitch.on {
            if !reccuringPickerVisible {
                showReccurringPicker()
            } else {
                hideRecurringPicker()
            }
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 1 && indexPath.row == 0 && textFieldHasText {
            return indexPath
        } else if !textFieldHasText {
            reminderNameField.becomeFirstResponder()
        }
        
        if indexPath.section == 1 && indexPath.row == 2 && textFieldHasText {
            return indexPath
        } else if !textFieldHasText {
            reminderNameField.becomeFirstResponder()
        }
        return nil
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
        //print(#function)
        let someText: NSString = textField.text!
        textFieldHasText = someText.length > 0
        enableDoneButton()
        hideDatePicker()
        if textFieldHasText {
            textField.returnKeyType = .Next
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //print(#function)
        if textFieldHasText {
            textField.resignFirstResponder()
            showDatePicker()
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
    
    func showDatePicker() {
        hideRecurringPicker()
        
        datePickerVisible = true
        
        let indexPathDateRow = NSIndexPath(forRow: 0, inSection: 1)
        let indexPathDatePicker = NSIndexPath(forRow: 1, inSection: 1)
        let indexPathEnableRepeatRow = NSIndexPath(forRow: 1, inSection: 1)
        let repeatsCellIndexPath = NSIndexPath(forRow: 2, inSection: 1)
        
        repeatsCell = tableView.cellForRowAtIndexPath(repeatsCellIndexPath)!
        enableRepeatsCell = tableView.cellForRowAtIndexPath(indexPathEnableRepeatRow)!
        
        
        if let dateCell = tableView.cellForRowAtIndexPath(indexPathDateRow) {
            dateCell.detailTextLabel!.textColor = dateCell.detailTextLabel!.tintColor
        }
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
        tableView.reloadRowsAtIndexPaths([indexPathDateRow], withRowAnimation: .None)
        tableView.endUpdates()
        
        tableView.scrollToRowAtIndexPath(indexPathDatePicker, atScrollPosition: .Middle, animated: true)
        
        // datePicker.minimumDate = NSDate()
        
        if let date = selectedDate {
            datePicker.setDate(date, animated: false)
        } else {
            let now = NSDate()

            datePicker.setDate(now, animated: false)
            
            selectedDate = datePicker.date
            dueDateIsSet = true
            setDueDateLabel(with: datePicker.date)
            reminderRepeatsSwitch.enabled = true
            
        }
    }
    
    func hideDatePicker() {
        if datePickerVisible {
            datePickerVisible = false
            let indexPathDateRow = NSIndexPath(forRow: 0, inSection: 1)
            let indexPathDatePicker = NSIndexPath(forRow: 1, inSection: 1)
            
            let indexPathEnableRepeatRow = NSIndexPath(forRow: 2, inSection: 1)
            
            
            if let dateCell = tableView.cellForRowAtIndexPath(indexPathDateRow) {
                if dueDateIsSet {
                    dateCell.detailTextLabel!.textColor = UIColor(white: 0, alpha: 0.5)
                }
            }
            
            tableView.beginUpdates()
            tableView.reloadRowsAtIndexPaths([indexPathDateRow, indexPathEnableRepeatRow], withRowAnimation: .None)
            tableView.deleteRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
            tableView.endUpdates()
            enableDoneButton()
        }
    }
    
    // MARK: - Reccurring Picker
    
    func updateRecurringLabel() {
        if selectedFrequency != 1 {
            recurringDateLabel.text = "every " + "\(selectedFrequency!) " + "\(selectedInterval!)" + "s"
        } else if selectedFrequency == 1 {
            recurringDateLabel.text = "every " + "\(selectedInterval!)"
        } else {
            recurringDateLabel.text = "Doesn't repeat"
        }
        
    }
    
    func showReccurringPicker() {
        hideDatePicker()
        reccuringPickerVisible = true
        
        let indexPathRecurringRow = NSIndexPath(forRow: 2, inSection: 1)
        let indexPathRecurringPicker = NSIndexPath(forRow: 3, inSection: 1)
        
        if let recurringCell = tableView.cellForRowAtIndexPath(indexPathRecurringRow) {
            recurringCell.detailTextLabel!.textColor = recurringCell.detailTextLabel!.tintColor
        }
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([indexPathRecurringPicker], withRowAnimation: .Fade)
        tableView.endUpdates()
        
        tableView.scrollToRowAtIndexPath(indexPathRecurringPicker, atScrollPosition: .Middle, animated: true)
        
        updateRecurringLabel()
        recurringDateWasSet = true
        
        nextReminderDate = addRecurringDate(selectedFrequency!, delayType: selectedInterval!, date: selectedDate!)
        
    }

    func hideRecurringPicker() {
        if reccuringPickerVisible {
            reccuringPickerVisible = false
            
            let indexPathRecurringRow = NSIndexPath(forRow: 2, inSection: 1)
            let indexPathRecurringPicker = NSIndexPath(forRow: 3, inSection: 1)
            
            if let recurringCell = tableView.cellForRowAtIndexPath(indexPathRecurringRow) {
                if reminderRepeats {
                    recurringCell.detailTextLabel!.textColor = UIColor(white: 0, alpha: 0.5)
                }
            }
            
            tableView.beginUpdates()
            tableView.reloadRowsAtIndexPaths([indexPathRecurringRow], withRowAnimation: .None)
            tableView.deleteRowsAtIndexPaths([indexPathRecurringPicker], withRowAnimation: .Fade)
            tableView.endUpdates()
            enableDoneButton()
        }
    }
    
    // MARK: Delegates
    
    // MARK: Data Source
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 20
        } else {
            return 6
        }
    }
    
    // MARK: Delegates
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
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
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
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
        updateRecurringLabel()
        
        recurringDateWasSet = true
        
        nextReminderDate = addRecurringDate(selectedFrequency!, delayType: selectedInterval!, date: selectedDate!)
        
        print(nextReminderDate!)
        
        
    }
    
    func setRecurringPicker() {
        let amount = reminderToEdit?.everyAmount!
        let interval = reminderToEdit?.typeOfInterval!
        var intervalRow = 0
        
        recurringPicker.selectRow((amount?.integerValue)! - 1, inComponent: 0, animated: false)
        
        switch interval! {
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
        recurringPicker.selectRow(intervalRow, inComponent: 1, animated: false)
    }
}
