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
        
        for i in 0...4 {
            let reminder = Reminder()
            reminder.name = String(format: "Reminder #%d", i)
            reminder.occurence = "Mondays"
            reminder.countdown = "In 3 hours"
            reminders.append(reminder)
        }
        tableView.reloadData()
    }
}

// MARK: - Extensions

extension AllRemindersViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchResultCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let reminder = reminders[indexPath.row]
        cell.textLabel!.text = reminder.name
        cell.detailTextLabel!.text = reminder.occurence
        return cell
    }
    
}

extension AllRemindersViewController: UITableViewDelegate {
    
}

