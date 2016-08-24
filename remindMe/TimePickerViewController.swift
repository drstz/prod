//
//  TimePickerViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 24/08/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

class TimePickerViewController: UITableViewController {
    @IBOutlet weak var intervalLabel: UILabel!
    
    var selectedIntervalIndex = 0
    var selectedInterval = 1
    
    var selectedIndexPath = NSIndexPath()
    
    let intervals = [
        1,
        5,
        10,
        15,
        30,
        60
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0 ..< intervals.count {
            if intervals[i] == selectedInterval {
                selectedIndexPath = NSIndexPath(forRow: i, inSection: 0)
                break
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intervals.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("interval", forIndexPath: indexPath)
        let intervalForRow = intervals[indexPath.row]
        
        var minuteString = ""
        if intervalForRow == 1 {
            minuteString = "minute"
        } else {
            minuteString = "minutes"
        }
        
        cell.textLabel?.text = String(intervalForRow) + " " + minuteString
        
        if intervalForRow == selectedInterval {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
            newCell.accessoryType = .Checkmark
        }
        
        if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
            oldCell.accessoryType = .None
        }
        
        selectedIndexPath = indexPath
        
        // Get Interval from row
        let interval = intervalFromRow(selectedIndexPath.row)
        
        // Save interval here
        saveTimePickerInterval(interval)
        print("Interval was set to \(timePickerInterval())")
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func intervalFromRow(row: Int) -> Int {
        switch row {
        case 0:
            return 1
        case 1:
            return 5
        case 2:
            return 10
        case 3:
            return 15
        case 4:
            return 30
        case 5:
            return 60
        default:
            print("Problem finding interval from row \(row)")
            print("Returning 1")
            return 1
        }
    }
    
}
