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

class AddReminderViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - Cells
    
    var repeatsCell = UITableViewCell()
    var enableRepeatsCell = UITableViewCell()
    
    // MARK: Properties
    
    var dueDateIsSet = false
    var textFieldHasText = false
    
    // Instances
    
    var reminderToEdit: Reminder?
    
    // CoreData
    
    var managedObjectContext: NSManagedObjectContext!
    
    var list: List!
    
    // The Date
    
    var dueDate: NSDate?
    var datePickerVisible = false {
        
        didSet {
            print("Datepicker was set from \(oldValue) to \(datePickerVisible)")
        }
    }
    
    var reccuringPickerVisible = false {
        
        didSet {
            print("Recurring was set from \(oldValue) to \(reccuringPickerVisible)")
        }
    }
    
    var recurringAmount = 1
    var timeInterval = "minute"
    
    var reminderRepeats = false
    
    var recurringDateWasSet = false
    
    var intervalType: String?
    
    var indentationCounter = 0
    
    var everyAmount: Int?
    
    enum choiceOfDelay {
        case Hour
        case Day
        case Week
        case Month
        case Year
    }
    
    var newDate: NSDate?
    
    var delay :choiceOfDelay?

    // Delegate
    
    weak var delegate: AddReminderViewControllerDelegate?
    
    // MARK: Outlets
    
    // Fields
    
    @IBOutlet weak var reminderNameField : UITextField!
    
    // Labels
    
    @IBOutlet weak var dueDateLabel : UILabel!
    @IBOutlet weak var recurringDateLabel : UILabel!
    
    // Buttons
    
    @IBOutlet weak var doneBarButton : UIBarButtonItem!
    @IBOutlet weak var recurringButton: UIButton!
    @IBOutlet weak var completeButton: UIButton!
    
    // Switches
    
    @IBOutlet weak var enableReminderSwitch : UISwitch!
    @IBOutlet weak var reminderRepeatsSwitch: UISwitch!
    
    // Pickers
    
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var recurringPickerCell: UITableViewCell!
    @IBOutlet weak var recurringPicker: UIPickerView!
    
    // MARK: - Actions
    
    // MARK: Bar items
    
    @IBAction func cancel() {
        delegate?.addReminderViewControllerDidCancel(self)
    }
    
    @IBAction func saveReminder() {
        print(#function)
        var tempReminder: Reminder?

        if var reminder = reminderToEdit {
            getReminderDetails(&reminder)
            delegate?.addReminderViewController(self, didFinishEditingReminder: reminder)
            tempReminder = reminder
            list = reminder.list
        } else {
            var reminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: managedObjectContext) as! Reminder
            getReminderDetails(&reminder)
            reminder.isComplete = false
            reminder.list = list
            let numberOfReminders = list.numberOfReminders.integerValue
            list.numberOfReminders = NSNumber(integer: numberOfReminders + 1)
            reminder.addIDtoReminder()
            
            delegate?.addReminderViewController(self, didFinishAddingReminder: reminder)
            tempReminder = reminder
        }
        
        do {
            try managedObjectContext.save()
            
            print("Asking to schedule notification")
            if tempReminder != nil {
                tempReminder!.scheduleNotifications()
            }
            
        } catch {
            fatalCoreDataError(error)
        }
        
    }
    
    // MARK: Switches
    
    @IBAction func toggleRepeatDateForReminder() {
        reminderRepeats = reminderRepeatsSwitch.on
        if !reminderRepeats {
            recurringDateLabel.text = "Doesn't repeat"
            
            newDate = nil
            recurringDateWasSet = false
            enableDontRepeatButton()
        }
        
    }
    
    // MARK: Reminder Actions
    
    @IBAction func removeRepeatDateFromReminder() {
        recurringDateLabel.text = "Doesn't repeat"
        
        newDate = nil
        recurringDateWasSet = false
        enableDontRepeatButton()
    }
    
    @IBAction func completeReminder() {
        reminderToEdit?.isComplete = true
        
        let reminderRepeats = reminderToEdit?.reminderIsRecurring()
        
        if reminderRepeats! {
            let newDate = reminderToEdit?.setNewDueDate()
            reminderToEdit?.dueDate = newDate!
            reminderToEdit?.scheduleNotifications()
        } else {
            reminderToEdit?.deleteReminderNotifications()
            
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        
        delegate?.addReminderViewController(self, didFinishEditingReminder: reminderToEdit!)
        
    }
    
    // MARK: Date Picker
    
    @IBAction func listenToDate(datePicker: UIDatePicker) {
        print(#function)
        dueDate = roundSecondsToZero(datePicker.date)
        dueDateIsSet = true
        updateDueDateLabel()
    }
    
    // MARK: - VIEW
    
    // MARK: Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let reminder = reminderToEdit {
            prepareViewForReminder(reminder)
        }
        updateDueDateLabel()
        enableDoneButton()
        enableDontRepeatButton()
    }
    
    func prepareViewForReminder(reminder: Reminder) {
        title = "Edit"
        reminderNameField.text = reminder.name
        dueDate = reminder.dueDate
        dueDateIsSet = true
        enableReminderSwitch.on = reminder.isEnabled as Bool
        reminderRepeatsSwitch.on = reminder.isRecurring as Bool
        reminderRepeats = reminder.isRecurring as Bool
        recurringDateWasSet = reminder.isRecurring as Bool
        if let recurringDate = reminder.nextDueDate {
            newDate = recurringDate
        }
        if reminder.isComplete == 1 {
            completeButton.enabled = false
        } else {
            completeButton.enabled = true
        }
        if let interval = reminderToEdit?.typeOfInterval {
            timeInterval = interval
        }
        if let amount = reminderToEdit?.everyAmount {
            recurringAmount = amount as Int
        }
        
        updateRecurringLabel()
        setRecurringPicker()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        print(#function)
        super.viewWillAppear(animated)
        reminderNameField.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        print(#function)
        super.viewDidAppear(animated)
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
            setNotifications()
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
    
    func enableDontRepeatButton() {
        if recurringDateWasSet {
            recurringButton.enabled = true
        } else {
            recurringButton.enabled = false
        }
    }
    
    // MARK: - Prepare the reminders
    
    func getReminderDetails(inout reminder: Reminder) {
        print(#function)
        reminder.name = reminderNameField.text!
        reminder.dueDate = dueDate!
        if let nextDueDate = newDate {
            reminder.nextDueDate = nextDueDate
            reminder.typeOfInterval = timeInterval
            reminder.everyAmount = recurringAmount
        } else {
            reminder.nextDueDate = nil
            reminder.typeOfInterval = nil
            reminder.everyAmount = nil
        }
        
        reminder.isEnabled = enableReminderSwitch.on
        reminder.isRecurring = recurringDateWasSet
        
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
        
        datePicker.minimumDate = NSDate()
        
        tableView.scrollToRowAtIndexPath(indexPathDatePicker, atScrollPosition: .Middle, animated: true)
        
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
            
            let indexPathEnableRepeatRow = NSIndexPath(forRow: 2, inSection: 1)
            
            
            if let dateCell = tableView.cellForRowAtIndexPath(indexPathDateRow) {
                if dueDateIsSet {
                    dateCell.detailTextLabel!.textColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.8)
                } else {
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
        if recurringAmount != 1 {
            recurringDateLabel.text = "every " + "\(recurringAmount) " + "\(timeInterval)" + "s"
        } else {
            recurringDateLabel.text = "every " + "\(timeInterval)"
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
        
    }

    func hideRecurringPicker() {
        if reccuringPickerVisible {
            reccuringPickerVisible = false
            
            let indexPathRecurringRow = NSIndexPath(forRow: 2, inSection: 1)
            let indexPathRecurringPicker = NSIndexPath(forRow: 3, inSection: 1)
            
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
            recurringAmount = row + 1
            
        } else {
            switch row {
            case 0:
                timeInterval = "minute"
            case 1:
                timeInterval = "hour"
            case 2:
                timeInterval = "day"
            case 3:
                timeInterval = "week"
            case 4:
                timeInterval = "month"
            case 5:
                timeInterval = "year"
            default:
                print("Error")
            }
            
        }
        updateRecurringLabel()
        
        recurringDateWasSet = true
        enableDontRepeatButton()
        
        newDate = addRecurringDate(recurringAmount, delayType: timeInterval, date: dueDate!)
        
        print(newDate!)
        
        
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
