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

class AddReminderViewController: UITableViewController, UITextFieldDelegate, DatePickerViewControllerDelegate, RepeatMethodViewControllerDelegate, ReminderCommentViewControllerDelegate {
    
    // MARK: Properties
    
    
    
    // CoreData
    var managedObjectContext: NSManagedObjectContext!
    
    var reminderToEdit: Reminder?
    var list: List!
    
    // Delegate
    weak var delegate: AddReminderViewControllerDelegate?
    
    var textFieldHasText = false
    var creatingReminder = false
    
    var comment: String?

    
    // The Date
    var selectedDate: NSDate?
    
    var selectedInterval: String?
    var selectedFrequency: Int?
    
    var dueDateIsSet = false
    
    var nextReminderDate: NSDate?
   
    var willSetNewDate = false
    
    var selectedDays = [Int]()
    
    var usingDayPattern = false
    var usingCustomPattern = false
    
    // MARK: Outlets
    
    // Unwind segue
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
        print("Unwind to Add Reminder View Controller")
    }
   
    // Fields
    
    @IBOutlet weak var reminderNameField : UITextField!
  
    
    // Comment field
    @IBOutlet weak var reminderCommentField: UILabel!
    @IBOutlet weak var reminderCommentFieldCell: UITableViewCell!
    
    // Labels
    
    @IBOutlet weak var dueDateLabel : UILabel!
    @IBOutlet weak var recurringDateLabel : UILabel!
    
    // Buttons
    
    @IBOutlet weak var doneBarButton : UIBarButtonItem!
    
    // Switches
    
    @IBOutlet weak var autoSnoozeSwitch: UISwitch!
    
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
        
        // Comment
        if let comment = comment {
            if comment.characters.count != 0 {
                reminder?.comment = comment
            } else {
                reminder?.comment = nil
            }
            
        }
        
        // Set Dates
        reminder!.setDate(selectedDate!)
        
        // Repeat Pattern
        if let frequency = selectedFrequency, let interval = selectedInterval {
            reminder!.setRepeatInterval(interval)
            reminder!.setRepeatFrequency(frequency)
            reminder!.setRecurring(true)
        }
        
        // Set Selected Days
        reminder?.selectedDays = NSMutableArray(array: selectedDays)
        
        // Update Repeat Method
        reminder?.useDays = usingDayPattern
        reminder?.usePattern = usingCustomPattern
        
        // Set if recurring
        if reminder?.useDays == true || reminder?.usePattern == true {
            reminder?.setRecurring(true)
        } else {
            reminder?.setRecurring(false)
        }
        
        // Set to incomplete
        reminder!.setCompletionStatus(false)
        
        // Set to unfavorite
        reminder!.setFavorite(false)
        
        // Add to list
        reminder!.addToList(list)
        
        // Update amount of reminders
        reminder?.list.increaseNbOfReminders()
        print("There are now \((reminder?.list.numberOfReminders)!) reminders")
//        let nbOfReminders = list.numberOfReminders.integerValue
//        list.numberOfReminders = NSNumber(integer: nbOfReminders + 1)
        
        // Set reminder ID
        reminder?.addIDtoReminder()
        
        // Autosnooze
        reminder?.autoSnooze = autoSnoozeSwitch.on
        
        // Set amount of snoozes
        reminder?.nbOfSnoozes = NSNumber(integer: 0)
        
        // Set creation date
        reminder?.creationDate = NSDate()
        
        // Create notification
        let notificationHandler = reminder!.notificationHandler
        notificationHandler.scheduleNotifications(reminder!)
    }
    
    func updateReminder(reminder: Reminder) {
        // Title
        reminder.setTitle(reminderNameField.text!)
        
        // Comment
        if let comment = comment {
            if comment.characters.count != 0 {
                reminder.comment = comment
            } else {
                reminder.comment = nil
            }
        } else {
            reminder.comment = nil
        }
        
        // Set Dates
        reminder.setDate(selectedDate!)
        
        // Repeat Pattern
        if let frequency = selectedFrequency, let interval = selectedInterval {
            reminder.setRepeatInterval(interval)
            reminder.setRepeatFrequency(frequency)
        } else {
            reminder.setRepeatInterval(nil)
            reminder.setRepeatFrequency(nil)
        }
        
        // Set Selected Days
        reminder.selectedDays = NSMutableArray(array: selectedDays)
        
        // Update Repeat Method
        reminder.useDays = usingDayPattern
        reminder.usePattern = usingCustomPattern
        
        if reminder.useDays == true || reminder.usePattern == true {
            reminder.setRecurring(true)
        } else {
            reminder.setRecurring(false)
        }
        
        // Autosnooze
        reminder.autoSnooze = autoSnoozeSwitch.on
        
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
            autoSnoozeSwitch.on = autoSnoozeSetting()
        }
        
        enableDoneButton()
        
        if comment == nil {
            reminderCommentField.text = "Enter extra details here"
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openCommentView))
        reminderCommentFieldCell.addGestureRecognizer(gestureRecognizer)
        
        reminderCommentField.textColor = UIColor.lightGrayColor()
        
    }
    
    func openCommentView() {
        performSegueWithIdentifier("AddComment", sender: nil)
    }
    
    func prepareViewForReminder(reminder: Reminder) {
        title = reminder.name
        
        // Set textfield
        reminderNameField.text = reminder.name
        
        // Set comment
        if let comment = reminder.comment {
            reminderCommentField.text = comment
            self.comment = comment
        }
        
        // Get Date into memomry
        selectedDate = reminder.dueDate
        dueDateIsSet = true
        
        // Get selected dates into mememory
        for day in reminder.selectedDays {
            selectedDays.append(Int(day as! NSNumber))
        }
        
        // Update due date label
        setDueDateLabel(with: selectedDate!)
        
        
        if reminder.isRecurring == true {
            
            // Update Repeat Method
            usingCustomPattern = reminder.usePattern as Bool
            usingDayPattern = reminder.useDays as Bool
            
            // Update repeat interval
            if let interval = reminderToEdit?.typeOfInterval, let frequency = reminderToEdit?.everyAmount {
                selectedInterval = interval
                selectedFrequency = frequency as Int
            }
        } else {
            usingCustomPattern = false
            usingDayPattern = false
        }
        
        // Auto snooze switch
        autoSnoozeSwitch.on = reminder.autoSnooze as Bool
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateRepeatLabel()
        
//        if reminderCommentField.text.characters.count == 0 {
//            reminderCommentField.hidden = true
//            reminderCommentFieldCell.hidden = true
//        } else {
//            reminderCommentField.hidden = false
//            reminderCommentFieldCell.hidden = false
//        }
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
        selectedDays = days
    }
    
    func repeatMethodViewControllerDidChooseRepeatMethod(controller: RepeatMethodViewController,
                                                         useNoPattern: Bool,
                                                         useCustomPattern: Bool,
                                                         useDayPattern: Bool) {
        if useNoPattern {
            usingCustomPattern = false
            usingDayPattern = false
        } else {
            usingDayPattern = useDayPattern
            usingCustomPattern = useCustomPattern
        }
        
    }
    
    func repeatMethodViewControllerIsDone() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func repeatMethodViewControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Comment View Controller Delegate
    func reminderCommentViewControllerDidCancel(controller: ReminderCommentViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func reminderCommentViewControllerDidSave(controller: ReminderCommentViewController, comment: String) {
        self.comment = comment
        if self.comment!.characters.count != 0 {
            reminderCommentField.text = self.comment
        } else {
            reminderCommentField.text = "Enter extra details here"
        }
        
        dismissViewControllerAnimated(true, completion: nil)
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
            let navigationController = segue.destinationViewController as? UINavigationController
            let repeatMethodViewController = navigationController?.viewControllers[0] as? RepeatMethodViewController
            
            repeatMethodViewController?.delegate = self
            
            repeatMethodViewController?.selectedInterval = selectedInterval
            repeatMethodViewController?.selectedFrequency = selectedFrequency
            
            repeatMethodViewController?.selectedDays = selectedDays
            
            if usingDayPattern {
                repeatMethodViewController?.usingDayPattern = true
                repeatMethodViewController?.usingCustomPattern = false
                repeatMethodViewController?.usingNoPattern = false
            } else if usingCustomPattern {
                repeatMethodViewController?.usingDayPattern = false
                repeatMethodViewController?.usingCustomPattern = true
                repeatMethodViewController?.usingNoPattern = false
            }
        }
        
        if segue.identifier == "AddComment" {
            let navigationController = segue.destinationViewController as? UINavigationController
            let reminderCommentViewController = navigationController?.viewControllers[0] as? ReminderCommentViewController
            
            reminderCommentViewController!.delegate = self
            
            if let comment = comment {
                reminderCommentViewController?.previousComment = comment
            } else {
                reminderCommentViewController?.previousComment = ""
            }
            
            
        }
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 {
            return 110
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
    
    func updateRepeatLabelWithCustomPattern() {
        if let frequency = selectedFrequency, let interval = selectedInterval {
            if selectedFrequency != 1 {
                recurringDateLabel.text = "every " + "\(frequency) " + "\(interval)" + "s"
            } else if selectedFrequency == 1 {
                recurringDateLabel.text = "every " + "\(interval)"
            }
        }
    }
    
    func updateRepeatLabelWithDayPattern() {
        var stringOfDays = "Every "
        if selectedDays.count > 0 {
            for day in selectedDays {
                switch day {
                case 1:
                    stringOfDays.appendContentsOf("Sun")
                case 2:
                    stringOfDays.appendContentsOf("Mon")
                case 3:
                    stringOfDays.appendContentsOf("Tue")
                case 4:
                    stringOfDays.appendContentsOf("Wed")
                case 5:
                    stringOfDays.appendContentsOf("Thu")
                case 6:
                    stringOfDays.appendContentsOf("Fri")
                case 7:
                    stringOfDays.appendContentsOf("Sat")
                default:
                    print("Error appending strings of days")
                }
                if selectedDays.count > 1 {
                    // Do not print comma after last word
                    if selectedDays.indexOf(day) < selectedDays.count - 1 {
                        stringOfDays.appendContentsOf(", ")
                    }
                }
            }
            recurringDateLabel.text = stringOfDays
        }
    }
    
    func updateRepeatLabel() {
        if usingDayPattern {
            updateRepeatLabelWithDayPattern()
        } else if usingCustomPattern {
            updateRepeatLabelWithCustomPattern()
        } else {
            recurringDateLabel.text = "Never"
        }
    }
    
    
}
