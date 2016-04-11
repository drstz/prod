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
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - The view

    override func viewDidLoad() {
        super.viewDidLoad()
        updateList()
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
            for i in 0...4 {
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
        let cellIdentifier = "SearchResultCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if reminders.count == 0 {
            cell.textLabel!.text = "No reminders are due"
            cell.detailTextLabel!.text = "Go add some!"
        } else {
            let reminder = reminders[indexPath.row]
            cell.textLabel!.text = reminder.name
            cell.detailTextLabel!.text = reminder.occurence
        }
        

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

