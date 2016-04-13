//
//  ViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 11/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit
import Foundation

class AllRemindersViewController: UIViewController, AddReminderViewControllerDelegate {
    
    // MARK: - Instance Variables
    
    var reminders = [Reminder]()
    
    
    
    required init?(coder aDecoder: NSCoder) {
        reminders = [Reminder]()
        
        let sampleReminder = Reminder()
        sampleReminder.name = "A sample"
        sampleReminder.occurence = "Monday"
        sampleReminder.countdown = "7 days left"
        
        super.init(coder: aDecoder)
    }
    
    // MARK: - Properties
    
    var nothingDue = false
    var color: UIColor?
    
    var titleString = ""
    var nbOfReminders = 0


    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Navigation
    
    func setNumberOfReminders() {
        nbOfReminders = reminders.count
        if nbOfReminders > 1 || nbOfReminders == 0 {
            titleString = "You have \(nbOfReminders) reminders"
        } else {
            titleString = "You have \(nbOfReminders) reminder"
        }
        self.title = titleString
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddReminder" {
            
            // The segue first goes to the navigation controller that the new view controller is embeded in
            let navigationController = segue.destinationViewController as! UINavigationController
            
            // To find the view controller, you look in the navigation controller topViewController property. This is the screen that is active in this navigation controller
            let controller = navigationController.topViewController as! AddReminderViewController
            
            // You now have the view controller that you want and you want to access its delegate property, setting it to this pages viewController(self)
            controller.delegate = self
            
        } else if segue.identifier == "EditReminder" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! AddReminderViewController
            controller.delegate = self
            
            if let indexPath = sender {
                controller.reminderToEdit = reminders[indexPath.row]
                controller.indexPathToEdit = indexPath.row 
            }
        }
    }
    
    // MARK: - AddReminderDelegate
    
    func addReminderViewControllerDidCancel(controller: AddReminderViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewController(controller: AddReminderViewController,
                                   didFinishAddingReminder reminder: Reminder) {
        let newRowIndex = reminders.count
        
        reminders.append(reminder)
        
        let indexPath = NSIndexPath(forRow: newRowIndex, inSection: 0)
        let indexPaths = [indexPath]
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    
    func addReminderViewController(controller: AddReminderViewController,
                                   didFinishEditingReminder reminder: Reminder,
                                   anIndex: Int?) {
        if let index = anIndex {
            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as! ReminderCell? {
                cell.reminderLabel.text = reminder.name
                cell.occurenceLabel.text = reminder.occurence
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - REMINDERS
    

    // MARK: Reminder list
    
    func updateList() {        
        tableView.reloadData()
    }
    
    // MARK: - The view

    override func viewDidLoad() {
        super.viewDidLoad()
        updateList()
        let cellNib = UINib(nibName: "ReminderCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "ReminderCell")
        tableView.rowHeight = 200
        setNumberOfReminders()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        // self.navigationController?.navigationBar.topItem?.title =
        setNumberOfReminders()
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

// MARK: - Extensions

extension AllRemindersViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return reminders.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath) as! ReminderCell

        let reminder = reminders[indexPath.row]
        
        
        cell.reminderLabel.text = reminder.name
        cell.occurenceLabel.text = reminder.occurence
        cell.countdownLabel.text = reminder.countdown
        if indexPath.row % 2 == 0 {
            print("Mod: \(indexPath.row % 2)")
            reminder.cellBackground = UIColor(red: 255/255, green: 165/255, blue: 0, alpha: 1)
            color = reminder.cellBackground
        } else {
            reminder.cellBackground = UIColor(red: 32/255, green: 178/255, blue: 170/255, alpha: 1)
            color = reminder.cellBackground
        }
        
        cell.backgroundColor = color
        return cell
    }
    
}

extension AllRemindersViewController: UITableViewDelegate {
    // MARK: - Selection
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("EditReminder", sender: indexPath)
        print("Index Path: \(indexPath)")
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if reminders.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        reminders.removeAtIndex(indexPath.row)
        
        let indexPaths = [indexPath]
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        setNumberOfReminders()
        
    }
    
}

