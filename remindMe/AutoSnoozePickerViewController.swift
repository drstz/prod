//
//  AutoSnoozePickerViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 13/06/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

class AutoSnoozePickerViewController: UITableViewController {
    var selectedAutoSnoozeTimeIndex = 0
    var selectedAutoSnoozeTime = ""
    
    let autoSnoozeTime = [
        "1 minute",
        "1 hour"
    ]
    
    var selectedIndexPath = NSIndexPath()
    
    override func viewDidLoad() {
        print(#function)
        super.viewDidLoad()
        for i in 0..<autoSnoozeTime.count {
            if autoSnoozeTime[i] == selectedAutoSnoozeTime {
                selectedIndexPath = NSIndexPath(forRow: i, inSection: 0)
                break
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(#function)
        return autoSnoozeTime.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print(#function)
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let autoSnoozeTime = self.autoSnoozeTime[indexPath.row]
        cell.textLabel!.text = autoSnoozeTime
        
        if autoSnoozeTime == selectedAutoSnoozeTime {
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
        if segue.identifier == "PickedAutoSnoozeTime" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell) {
                selectedAutoSnoozeTimeIndex = indexPath.row
                switch selectedAutoSnoozeTimeIndex {
                case 0:
                    setDefaultAutoSnoozeTime(.Minute)
                case 1:
                    setDefaultAutoSnoozeTime(.Hour)
                default:
                    break
                    
                }
                
            }
        }
    }
}

