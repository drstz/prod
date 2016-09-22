//
//  AddReminder.swift
//  remindMe
//
//  Created by Duane Stoltz on 12/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit
import CoreData

import Fabric
import Crashlytics


fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


// MARK: - Protocols

protocol AddReminderViewControllerDelegate: class {
    func addReminderViewControllerDidCancel(_ controller: AddReminderViewController)
    
    func addReminderViewController(_ controller: AddReminderViewController,
                                   didFinishEditingReminder reminder: Reminder)
    
    func addReminderViewControllerDidFinishAdding(_ controller: AddReminderViewController)
    
    func addReminderViewController(_ controller: AddReminderViewController,
                                   didChooseToDeleteReminder reminder: Reminder)
    
}

class AddReminderViewController: UITableViewController, UITextFieldDelegate, DatePickerViewControllerDelegate, RepeatMethodViewControllerDelegate, ReminderCommentViewControllerDelegate, PremiumUserViewControllerDelegate {
    
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
    var selectedDate: Date?
    
    var selectedInterval: String?
    var selectedFrequency: Int?
    
    var dueDateIsSet = false
    
    var nextReminderDate: Date?
   
    var willSetNewDate = false
    
    var selectedDays = [Int]()
    
    var usingDayPattern = false
    var usingCustomPattern = false
    
    // MARK: Outlets
    
    // Unwind segue
    @IBAction func unwindToRootViewController(_ segue: UIStoryboardSegue) {
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
    @IBOutlet weak var autoSnoozeLabel: UILabel!
    
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
        
        let alert = UIAlertController(title: "Are you sure?", message: "You will lose all changes", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirm = UIAlertAction(title: "Confirm", style: .default, handler: {
            action in
            self.delegate?.addReminderViewControllerDidCancel(self)
        })
        alert.addAction(cancel)
        alert.addAction(confirm)
        if textFieldHasText {
            present(alert, animated: true, completion: nil)
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
        let reminder = NSEntityDescription.insertNewObject(forEntityName: "Reminder",
                                                                           into: managedObjectContext) as? Reminder
        
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
        reminder?.usesDayPattern = usingDayPattern as NSNumber
        reminder?.usesCustomPattern = usingCustomPattern as NSNumber
        
        // Set if recurring
        if reminder?.usesDayPattern == true || reminder?.usesCustomPattern == true {
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
        reminder?.willAutoSnooze = autoSnoozeSwitch.isOn as NSNumber
        
        // Set amount of snoozes
        reminder?.timesSnoozed = NSNumber(value: 0 as Int)
        
        // Set creation date
        reminder?.creationDate = Date()
        
        // Create notification
        let notificationHandler = reminder!.notificationHandler
        notificationHandler.scheduleNotifications(reminder!)
        
        let nameLength = (reminder?.name.characters.count)! as Int
        let nameLengthAsNSNumber = NSNumber(value: nameLength)
        Answers.logCustomEvent(withName: "Created Reminder", customAttributes: ["Length": nameLengthAsNSNumber])
    }
    
    func updateReminder(_ reminder: Reminder) {
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
        reminder.usesDayPattern = usingDayPattern as NSNumber
        reminder.usesCustomPattern = usingCustomPattern as NSNumber
        
        if reminder.usesDayPattern == true || reminder.usesCustomPattern == true {
            reminder.setRecurring(true)
        } else {
            reminder.setRecurring(false)
        }
        
        // Autosnooze
        reminder.willAutoSnooze = autoSnoozeSwitch.isOn as NSNumber
        
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
            autoSnoozeSwitch.isOn = autoSnoozeSetting()
        }
        
        enableDoneButton()
        
        if comment == nil {
            reminderCommentField.text = "Tap to enter extra details here"
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openCommentView))
        reminderCommentFieldCell.addGestureRecognizer(gestureRecognizer)
        
        reminderCommentField.textColor = UIColor.white
        // reminderCommentField.backgroundColor = UIColor(red: 68/255, green: 140/255, blue: 183/255, alpha: 1)
        reminderNameField.textColor = UIColor.white
        reminderNameField.backgroundColor = UIColor.clear
        reminderNameField.attributedPlaceholder = NSAttributedString(string: "What would you like to remember?",
                                                                     attributes: [NSForegroundColorAttributeName:UIColor.lightGray])
        setColorTheme()
        
        reminderNameField.borderStyle = .none
        
        autoSnoozeLabel.textColor = UIColor.white
        
        // Switch
        autoSnoozeSwitch.onTintColor = UIColor(red: 68/255, green: 140/255, blue: 183/255, alpha: 1)
        autoSnoozeSwitch.tintColor = UIColor(red: 68/255, green: 140/255, blue: 183/255, alpha: 1)
        
    }
    
    func setColorTheme() {
        // Table view background
        tableView.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        
        // Table view separator
        tableView.separatorColor = UIColor.white
    }
    
    func openCommentView() {
        if isPremium() {
            performSegue(withIdentifier: "AddComment", sender: nil)
        } else {
            presentPremiumView()
        }
        
    }
    
    func prepareViewForReminder(_ reminder: Reminder) {
        title = reminder.name
        
        // Set textfield
        reminderNameField.text = reminder.name
        
        // Set comment
        if let comment = reminder.comment {
            reminderCommentField.text = comment
            self.comment = comment
        }
        
        // Get Date into memomry
        selectedDate = reminder.dueDate as Date
        dueDateIsSet = true
        
        // Get selected dates into mememory
        for day in reminder.selectedDays {
            selectedDays.append(Int(day as! NSNumber))
        }
        
        // Update due date label
        setDueDateLabel(with: selectedDate!)
        
        
        if reminder.repeats == true {
            
            // Update Repeat Method
            usingCustomPattern = reminder.usesCustomPattern as Bool
            usingDayPattern = reminder.usesDayPattern as Bool
            
            // Update repeat interval
            if let interval = reminderToEdit?.interval, let frequency = reminderToEdit?.frequency {
                selectedInterval = interval
                selectedFrequency = frequency as Int
            }
        } else {
            usingCustomPattern = false
            usingDayPattern = false
        }
        
        // Auto snooze switch
        autoSnoozeSwitch.isOn = reminder.willAutoSnooze as Bool
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateRepeatLabel()
        
        if reminderToEdit != nil {
            doneBarButton.isEnabled = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if reminderNameField.text?.characters.count == 0 {
            reminderNameField.becomeFirstResponder()
        }
    }
    
    // MARK: - Premium View Controller delegate
    func presentPremiumView() {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        
        
        let premiumView = storyboard.instantiateViewController(withIdentifier: "PremiumView") as! PremiumUserViewController
        premiumView.delegate = self
        
        let navigationController = UINavigationController()
        navigationController.viewControllers.append(premiumView)
        
        present(navigationController, animated: true, completion: nil)
    }
    
    func premiumUserViewControllerDelegateDidCancel(controller: PremiumUserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Date Picker View Controller Delegate
    
    func datePickerViewControllerDidChooseDate(_ controller: DatePickerViewController, date: Date) {
        dismiss(animated: true, completion: nil)
        selectedDate = date
        setDueDateLabel(with: selectedDate!)
        
        dueDateIsSet = true
        enableDoneButton()
    }
    
    // MARK: - Repeat Method View Controller Delegate
    func repeatMethodViewControllerDidChooseCustomPattern(_ controller: RepeatMethodViewController, frequency: Int, interval: String) {
        print("Arrived  with \(interval) and \(frequency)")
        selectedInterval = interval
        selectedFrequency = frequency
        
        // What if I set date after setting how I want the reminder to repeat itself?
        // nextReminderDate = addRecurringDate(selectedFrequency!, delayType: selectedInterval!, date: selectedDate!)
    }
    
    func repeatMethodViewControllerDidChooseWeekDayPattern(_ controller: RepeatMethodViewController, days: [Int]) {
        selectedDays = days
    }
    
    func repeatMethodViewControllerDidChooseRepeatMethod(_ controller: RepeatMethodViewController,
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
        dismiss(animated: true, completion: nil)
    }
    
    func repeatMethodViewControllerDidCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Comment View Controller Delegate
    func reminderCommentViewControllerDidCancel(_ controller: ReminderCommentViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func reminderCommentViewControllerDidSave(_ controller: ReminderCommentViewController, comment: String) {
        self.comment = comment
        if self.comment!.characters.count != 0 {
            reminderCommentField.text = self.comment
        } else {
            reminderCommentField.text = "Tap to enter extra details here"
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenDatePicker" {
            let datePickerViewController = segue.destination as? DatePickerViewController
            datePickerViewController?.delegate = self
            
            // Send date
            datePickerViewController?.date = selectedDate
        }
        
        if segue.identifier == "PickRepeatMethod" {
            let navigationController = segue.destination as? UINavigationController
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
            let navigationController = segue.destination as? UINavigationController
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            return 110
        } else {
            return 50
        }
        
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let notificationHandler = NotificationHandler()
        notificationHandler.setNotifications()
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        return super.tableView(tableView, indentationLevelForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function)
        tableView.deselectRow(at: indexPath, animated: true)
        reminderNameField.resignFirstResponder()
        if indexPath.section == 2 && indexPath.row == 1 {
            if isPremium() {
                performSegue(withIdentifier: "PickRepeatMethod", sender: nil)
            } else {
                presentPremiumView()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 2 {
            return nil
        } else {
            return indexPath
        }
        
        
    
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        // Do not highlight auto snooze line
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 2 {
            return false
        } else {
            return true
        }
    }

    // MARK: - Interface
    
    func enableDoneButton() {
        if dueDateIsSet && textFieldHasText {
            doneBarButton.isEnabled = true
        } else {
            doneBarButton.isEnabled = false
        }
        
        if reminderToEdit != nil && reminderNameField.text?.characters.count != 0 {
            doneBarButton.isEnabled = true
        }
    }

    // MARK: - Text Field
    
    // Listen to textfield
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        let oldText: NSString = textField.text! as NSString
        let newText: NSString = oldText.replacingCharacters(in: range, with: string) as NSString

        textFieldHasText = newText.length > 0
        

        enableDoneButton()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let someText: NSString = textField.text! as NSString
        textFieldHasText = someText.length > 0
        enableDoneButton()
        if textFieldHasText {
            textField.returnKeyType = .done
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        reminderNameField.resignFirstResponder()
        return true
    }
    
    
    // MARK: - Date Picker
    
    func setDueDateLabel(with date: Date) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        dueDateLabel.text = formatter.string(from: date)
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
                    var day = "Sunday"
                    if selectedDays.count != 1 {
                        day = "Sun"
                    }
                    stringOfDays.append(day)
                case 2:
                    var day = "Monday"
                    if selectedDays.count != 1 {
                        day = "M"
                    }
                    stringOfDays.append(day)
                case 3:
                    var day = "Tuesday"
                    if selectedDays.count != 1 {
                        day = "T"
                    }
                    stringOfDays.append(day)
                case 4:
                    var day = "Wednesday"
                    if selectedDays.count != 1 {
                        day = "W"
                    }
                    stringOfDays.append(day)
                case 5:
                    var day = "Thursday"
                    if selectedDays.count != 1 {
                        day = "Th"
                    }
                    stringOfDays.append(day)
                case 6:
                    var day = "Friday"
                    if selectedDays.count != 1 {
                        day = "F"
                    }
                    stringOfDays.append(day)
                case 7:
                    var day = "Saturday"
                    if selectedDays.count != 1 {
                        day = "Sat"
                    }
                    stringOfDays.append(day)
                default:
                    print("Error appending strings of days")
                }
                if selectedDays.count > 1 {
                    // Do not print comma after last word
                    if selectedDays.index(of: day) < selectedDays.count - 1 {
                        stringOfDays.append(", ")
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
