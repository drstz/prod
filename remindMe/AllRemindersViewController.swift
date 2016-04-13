//
//  ViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 11/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

class AllRemindersViewController: UIViewController, AddReminderViewControllerDelegate {
    
    // MARK: - Instance Variables
    
    var reminders = [Reminder]()
    
    // MARK: - Properties
    
    var nothingDue = false
    var color: UIColor?
    var nbOfReminders = 0

    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddReminder" {
            // The segue first goes to the navigation controller that the new view controller is embeded in
            let navigationController = segue.destinationViewController as! UINavigationController
            // To find the view controller, you look in the navigation controller topViewController property. This is the screen that is active in this navigation controller
            let controller = navigationController.topViewController as! AddReminderViewController
            // You now have the view controller that you want and you want to access its delegate property, setting it to this pages viewController(self)
            controller.delegate = self
        }
    }
    
    // MARK: - AddReminderDelegate
    
    func addReminderViewControllerDidCancel(controller: AddReminderViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewController(controller: AddReminderViewController, didFinishAddingReminder reminder: Reminder) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - REMINDERS
    
    // MARK: Add reminders
    
    @IBAction func addReminder() {
        let reminder = Reminder()
        nbOfReminders += 1
        reminder.name = String(format: "Reminder #%d", nbOfReminders)
        reminder.occurence = "Monday"
        reminder.countdown = "In 3 Hours"
        reminders.append(reminder)
        tableView.reloadData()
    }
    
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
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

// MARK: - Extensions

extension AllRemindersViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reminders.count == 0 {
            return 1
        } else {
            return reminders.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell", forIndexPath: indexPath) as! ReminderCell
        if reminders.count == 0 {
            cell.reminderLabel.text = "Nothing Found"
            cell.occurenceLabel.text = ""
            cell.countdownLabel.text = ""
        } else {
            let reminder = reminders[indexPath.row]
            print(indexPath.row)
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
            
            
        }
        cell.backgroundColor = color
        return cell
    }
    
}

extension AllRemindersViewController: UITableViewDelegate {
    // MARK: - Selection
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if reminders.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
}

