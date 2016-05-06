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

class AddReminderViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
    
    // Switch
    
    @IBOutlet weak var enableSwitch : UISwitch!
    
    // Date Picker
    
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // Recurring Picker
    
    @IBOutlet weak var recurringPickerCell: UITableViewCell!
    @IBOutlet weak var recurringPicker: UIPickerView!
    
    // MARK: - Actions
    
    @IBAction func cancel() {
        delegate?.addReminderViewControllerDidCancel(self)
    }
    
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
        
        reminder.isEnabled = enableSwitch.on
        reminder.isRecurring = recurringDateWasSet
    }
    
    @IBAction func done() {
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
    
    @IBAction func dontRepeat() {
        recurringDateLabel.text = "Doesn't repeat"
        newDate = nil
        recurringDateWasSet = false
        enableDontRepeatButton()
    }
    
    @IBAction func complete() {
        print("Going to complete reminder")
        reminderToEdit?.isComplete = true
        
        let reminderReccurs = reminderToEdit?.reminderIsRecurring()
        
        if reminderReccurs! {
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
    
    // Date Picker
    
    @IBAction func dateChanged(datePicker: UIDatePicker) {
        dueDate = roundSecondsToZero(datePicker.date)
        dueDateIsSet = true
        updateDueDateLabel()
    }
    
    // MARK: - Enable Done Button
    
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
    
    // MARK: - VIEW

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reminderNameField.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print(#function)
        print("----------------------------------------------------")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(#function)
  
        if let reminder = reminderToEdit {
            title = "Edit"
            reminderNameField.text = reminder.name
            dueDate = reminder.dueDate
            dueDateIsSet = true
            enableSwitch.on = reminder.isEnabled as Bool
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
        updateDueDateLabel()
        enableDoneButton()
        enableDontRepeatButton()
        
        
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
        print("Inserted row")
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
        //print(#function)
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
            print("Deleted row")
            tableView.endUpdates()
            enableDoneButton()
        }
        
        
    }
    
    // MARK: - Reccurring Picker
    
    func updateRecurringLabel() {
        if recurringAmount != 1 {
            recurringDateLabel.text = "Repeat every " + "\(recurringAmount) " + "\(timeInterval)" + "s"
        } else {
            recurringDateLabel.text = "Repeat every " + "\(timeInterval)"
        }
        
    }
    
    func showReccurringPicker() {
        //print(#function)
        reccuringPickerVisible = true
        
        let indexPathRecurringRow = NSIndexPath(forRow: 0, inSection: 2)
        let indexPathRecurringPicker = NSIndexPath(forRow: 1, inSection: 2)
        
        if let recurringCell = tableView.cellForRowAtIndexPath(indexPathRecurringRow) {
            recurringCell.detailTextLabel!.textColor = recurringCell.detailTextLabel!.tintColor
        }
        
        
        tableView.beginUpdates()
        tableView.insertRowsAtIndexPaths([indexPathRecurringPicker], withRowAnimation: .Fade)
        tableView.reloadRowsAtIndexPaths([indexPathRecurringRow], withRowAnimation: .None)
        tableView.endUpdates()

    }
    
    
    
    func hideRecurringPicker() {
        if reccuringPickerVisible {
            reccuringPickerVisible = false
            
            let indexPathRecurringRow = NSIndexPath(forRow: 0, inSection: 2)
            let indexPathRecurringPicker = NSIndexPath(forRow: 1, inSection: 2)
            
            
            
            tableView.beginUpdates()
            tableView.reloadRowsAtIndexPaths([indexPathRecurringRow], withRowAnimation: .None)
            tableView.deleteRowsAtIndexPaths([indexPathRecurringPicker], withRowAnimation: .Fade)
            tableView.endUpdates()
            enableDoneButton()
        }
        
        
    }
    
    
    // MARK: - Table View
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print(" ")
        print("---------------------RETURN CELL S:\(indexPath.section) R:\(indexPath.row) ------------------------------  ")
        //print(#function)
        if indexPath.section == 1 && indexPath.row == 1 {
            setNotifications()
//            let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil)
//            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
            return datePickerCell
        } else if indexPath.section == 2 && indexPath.row == 1 {
            return recurringPickerCell
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("--------------------------------------------------- NB OF ROWS S: \(section)")
        //print(#function)
        if section == 1 && datePickerVisible {
            print("Changing number of rows in section")
            return 2
        } else if section == 2 && reccuringPickerVisible {
            return 2
        } else {
            print("--------------------------------------------------- = \(super.tableView(tableView, numberOfRowsInSection: section)) ")
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //print(#function)
        print("--------------------------------------------------- HEIGHT S:\(indexPath.section) R:\(indexPath.row)")
        if indexPath.section == 1 && indexPath.row == 1 {
            print("Getting the new Height")
            return 217
        } else if indexPath.section == 2 && indexPath.row == 1 {
            print("Getting the new Height")
            return 217
        } else {
            print("--------------------------------------------------- = \(super.tableView(tableView, heightForRowAtIndexPath: indexPath))")
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
            
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print(#function)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        reminderNameField.resignFirstResponder()
        
        if indexPath.section == 1 && indexPath.row == 0 {
            print("--------------------------------------------------- TAPPED DATE S:\(indexPath.section) R:\(indexPath.row) ")
            if !datePickerVisible {
                showDatePicker()
            } else {
                hideDatePicker()
            }
        }
        
        if indexPath.section == 2 && indexPath.row == 0 {
            if !reccuringPickerVisible {
                showReccurringPicker()
            } else {
                hideRecurringPicker()
            }
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        //print(#function)
        //print("Section: \(indexPath.section)")
        //print("Row: \(indexPath.row)")
        if indexPath.section == 1 && indexPath.row == 0 && textFieldHasText {
            return indexPath
        } else if !textFieldHasText {
            reminderNameField.becomeFirstResponder()
        }
        
        if indexPath.section == 2 && indexPath.row == 0 && textFieldHasText {
            return indexPath
        } else if !textFieldHasText {
            reminderNameField.becomeFirstResponder()
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
       // print(#function)
        indentationCounter += 1
        print("--------------------------------------------------- INDENTATION  S:\(indexPath.section) R:\(indexPath.row) ")
        print("This function has been called \(indentationCounter) times")
        var indexPathMod = indexPath
        
        print("Calling row \(indexPathMod.row) in section: \(indexPathMod.section)")
        
        
        if indexPathMod.section == 1 && indexPathMod.row == 1 {
            indexPathMod = NSIndexPath(forRow: 0, inSection: indexPathMod.section)

        } else if indexPathMod.section == 2 && indexPathMod.row == 1 {
            indexPathMod = NSIndexPath(forRow: 0, inSection: indexPathMod.section)
        } else {
            print("No change in indexPath")
        }
        print("Returning row \(indexPathMod.row) in section: \(indexPathMod.section) at level \(super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPathMod) )")
        
        
        

        return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPathMod)
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
    
    // MARK: - Picker Delegates
    
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
