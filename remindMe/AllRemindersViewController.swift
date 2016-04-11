//
//  ViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 11/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

class AllRemindersViewController: UIViewController {
    
    // MARK: - Instance Variables
    
    var reminders = [Reminder]()
    
    // MARK: - Properties
    
    var nothingDue = false
    var color: UIColor?

    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    // MARK: - Reminder list
    
    func updateList() {
        reminders = [Reminder]()
        
        if !nothingDue {
            for i in 0...9 {
                let reminder = Reminder()
                reminder.name = String(format: "Reminder #%d", i)
                reminder.occurence = "Mondays"
                reminder.countdown = "In 3 hours"
                reminders.append(reminder)
            }
        }
        
        tableView.reloadData()
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

