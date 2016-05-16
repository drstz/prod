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



class QuickViewViewController: UIViewController, AddReminderViewControllerDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var reminderNameLabel: UILabel!
    @IBOutlet weak var reminderDueDateLabel: UILabel!
    @IBOutlet weak var reminderDueTimeLabel: UILabel!
    
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var snoozeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: - Delegates
    
    weak var delegate: QuickViewViewControllerDelegate?
    
    // MARK: - Core Date
    var managedObjectContext: NSManagedObjectContext!
    
    
    // MARK: - Properties
    
    var incomingReminder: Reminder?
    
    // MARK: - Actions
    
    // Bar Buttons 
    
    @IBAction func cancel() {
        delegate?.quickViewViewControllerDidCancel(self)
    }
    
    // Bottom Buttons
    
    @IBAction func completeReminder() {
        delegate?.quickViewViewControllerDidComplete(self, didCompleteReminder: incomingReminder!)
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
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewController(controller: AddReminderViewController, didFinishEditingReminder reminder: Reminder) {
        updateLabels(with: reminder)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewController(controller: AddReminderViewController, didFinishAddingReminder reminder: Reminder) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewController(controller: AddReminderViewController, didChooseToDeleteReminder reminder: Reminder) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let reminder = incomingReminder {
            updateLabels(with: reminder)
        }
    }
    
    func updateLabels(with reminder: Reminder) {
        reminderNameLabel.text = reminder.name
        reminderDueDateLabel.text = convertDateToString(dateFromDate: reminder.dueDate)
        reminderDueTimeLabel.text = convertDateToString(timeFromDate: reminder.dueDate)
    }
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditReminder" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! AddReminderViewController
            
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext
            controller.reminderToEdit = incomingReminder
        }
    }
    
    
}
