//
//  SnoozePickerViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 07/06/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

class SnoozePickerViewController: UITableViewController {
    var selectedSnoozeTimeIndex = 0
    var selectedSnoozeTime = ""
    
    let snoozeTime = [
        "10 seconds",
        "5 minutes",
        "10 minutes",
        "30 minutes",
        "1 hour"
    ]
    
    var selectedIndexPath = NSIndexPath()
    
    override func viewDidLoad() {
        print(#function)
        super.viewDidLoad()
        for i in 0..<snoozeTime.count {
            if snoozeTime[i] == selectedSnoozeTime {
                selectedIndexPath = NSIndexPath(forRow: i, inSection: 0)
                break
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(#function)
        return snoozeTime.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print(#function)
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let snoozeTime = self.snoozeTime[indexPath.row]
        cell.textLabel!.text = snoozeTime
        
        if snoozeTime == selectedSnoozeTime {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(#function)
        if indexPath.row != selectedIndexPath.row {
            if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
                newCell.accessoryType = .Checkmark
            }
            
            if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
                oldCell.accessoryType = .None
            }
            selectedIndexPath = indexPath
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(#function)
        if segue.identifier == "PickedSnoozeTime" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell) {
                selectedSnoozeTimeIndex = indexPath.row
                switch selectedSnoozeTimeIndex {
                case 0:
                    setDefaultSnoozeTime(.TenSeconds)
                case 1:
                    setDefaultSnoozeTime(.FiveMinutes)
                case 2:
                    setDefaultSnoozeTime(.TenMinutes)
                case 3:
                    setDefaultSnoozeTime(.ThirtyMinutes)
                case 4:
                    setDefaultSnoozeTime(.Hour)
                default:
                    break
                    
                }
                
            }
        }
    }
}
