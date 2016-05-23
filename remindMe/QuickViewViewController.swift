//
//  quickViewViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 13/05/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit
import CoreData

protocol QuickViewViewControllerDelegate: class {
    func quickViewViewControllerDidCancel(controller: QuickViewViewController)
    func quickViewViewControllerDidDelete(controller: QuickViewViewController,
                                          didDeleteReminder reminder: Reminder)
    func quickViewViewControllerDidComplete(controller: QuickViewViewController,
                                            didCompleteReminder reminder: Reminder)
    func quickViewViewControllerDidSnooze(controller: QuickViewViewController,
                                          didSnoozeReminder reminder: Reminder)
}

class QuickViewViewController: UIViewController, AddReminderViewControllerDelegate, AllRemindersViewControllerDelegate {
    
    // MARK: - Outlets
    
    // MARK: Labels
    
    @IBOutlet weak var reminderNameLabel: UILabel!
    @IBOutlet weak var reminderDueDateLabel: UILabel!
    @IBOutlet weak var reminderDueTimeLabel: UILabel!
    
    // MARK: Buttons
    
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var snoozeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: - Delegates
    
    weak var delegate: QuickViewViewControllerDelegate?
    
    // MARK: - Core Date
    var managedObjectContext: NSManagedObjectContext!
    
    // MARK: - Properties
    
    var incomingReminder: Reminder?
    
    var notifiedReminder: Reminder? {
        didSet {
            print("QuickView Controller now has the notified reminder")
        }
    }
    
    var willSetNewDate = false
    
    var notificationHasGoneOff = false
    
    // MARK: - Actions
    
    // Bar Buttons 
    
    @IBAction func cancel() {
        delegate?.quickViewViewControllerDidCancel(self)
    }
    
    // Bottom Buttons
    
    @IBAction func completeReminder() {
        if let reminder = incomingReminder {
            if reminder.isComplete == true {
                willSetNewDate = true
                performSegueWithIdentifier("EditReminder", sender: nil)
            } else {
                delegate?.quickViewViewControllerDidComplete(self, didCompleteReminder: reminder)
            }
        }
    }
    
    @IBAction func snoozeReminder() {
        delegate?.quickViewViewControllerDidSnooze(self, didSnoozeReminder: incomingReminder!)
    }
    
    @IBAction func deleteReminder() {
        delegate?.quickViewViewControllerDidDelete(self, didDeleteReminder: incomingReminder!)
    }
    
    // MARK: - Delegate Methods
    
    // MARK: AddReminder
    
    func addReminderViewControllerDidCancel(controller: AddReminderViewController) {
        print(#function)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewController(controller: AddReminderViewController, didFinishEditingReminder reminder: Reminder) {
        print(#function)
        updateLabels(with: reminder)
        setCompleteButton(with: reminder)
        super.viewDidLoad()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewController(controller: AddReminderViewController, didFinishAddingReminder reminder: Reminder) {
        print(#function)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewController(controller: AddReminderViewController, didChooseToDeleteReminder reminder: Reminder) {
        print(#function)
        dismissViewControllerAnimated(true, completion: nil)
    }
    // MARK: AllReminder
    
    func allRemindersViewControllerDelegateDidReceiveNotification(controller: AllRemindersViewController, reminder: Reminder) {
        showNotificationHasGoneOffAlert(reminder)
    }
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        print(#function)
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(addSnoozeButton),
            name: UIApplicationWillEnterForegroundNotification,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(showNotificationHasGoneOffAlert),
            name: "showNotificationHasGoneOff",
            object: nil
        )
        
        if let reminder = incomingReminder {
            if !notificationHasGoneOff {
                snoozeButton.hidden = true
                let superViewTrailingAnchor = completeButton.superview?.trailingAnchor
                completeButton.trailingAnchor.constraintEqualToAnchor(superViewTrailingAnchor).active = true
            }
            updateLabels(with: reminder)
            setCompleteButton(with: reminder)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        print(#function)
        super.viewDidAppear(animated)
    }
    
    func showNotificationHasGoneOffAlert(reminder: Reminder) {
        let alert = UIAlertController(
            title: "You have a reminder",
            message: reminder.name,
            preferredStyle: .Alert
        )
        
        var actions: [UIAlertAction] = []
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        actions.append(cancelAction)
        
        let viewAction = UIAlertAction(title: "View", style: .Default, handler: { viewAction in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("QuickView") as! QuickViewViewController
            controller.incomingReminder = reminder
            
            controller.delegate = self.delegate
            
            let navigationItem = UINavigationItem()
            navigationItem.title = "Here is your reminder"
            let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 44))
            let leftButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: nil)
            
            navigationItem.leftBarButtonItem = leftButton
            
            navigationBar.items = [navigationItem]
            
            
            controller.view.addSubview(navigationBar)
            
            
            
            self.presentViewController(controller, animated: true, completion: nil)
            
        })
        actions.append(viewAction)
        
        for action in actions {
            alert.addAction(action)
        }
        
        alert.preferredAction = alert.actions[1]
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func addSnoozeButton() {
        print(#function)
        snoozeButton.hidden = false
        let snoozeButtonLeadingAnchor = snoozeButton.leadingAnchor
        completeButton.trailingAnchor.constraintEqualToAnchor(snoozeButtonLeadingAnchor).active = true
        
    }
    
    func updateLabels(with reminder: Reminder) {
        reminderNameLabel.text = reminder.name
        reminderDueDateLabel.text = convertDateToString(dateFromDate: reminder.dueDate)
        reminderDueTimeLabel.text = convertDateToString(timeFromDate: reminder.dueDate)
    }
    
    func setCompleteButton(with reminder: Reminder) {
        var newTitle = ""
        if reminder.isComplete == true {
            newTitle = "Set new date"
        } else {
            newTitle = "Complete"
        }
       completeButton.setTitle(newTitle, forState: .Normal)
    }
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditReminder" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! AddReminderViewController
            
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext
            controller.reminderToEdit = incomingReminder
            
            if willSetNewDate {
                controller.willSetNewDate = willSetNewDate
            }
        }
    }
}
