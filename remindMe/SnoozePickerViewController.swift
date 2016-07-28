//
//  SnoozePickerViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 07/06/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

class SnoozePickerViewController: UITableViewController {
    @IBOutlet weak var customSnoozeLabel: UILabel!
    
    var selectedSnoozeTimeIndex = 0
    var selectedSnoozeTime = ""
    
    var customSnoozeTime: String {
        return (customSnoozeDelay + customSnoozeUnit)
    }
    var customSnoozeUnit = ""
    var customSnoozeDelay = "None"
    
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
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        
        switch section {
        case 0:
            rowCount = snoozeTime.count
        case 1:
            rowCount = 1
        default:
            break
        }
        
        return rowCount
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print(#function)
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("snoozeChoice", forIndexPath: indexPath)
            let snoozeTime = self.snoozeTime[indexPath.row]
            cell.textLabel!.text = snoozeTime
            
            if snoozeTime == selectedSnoozeTime {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("customSnoozeButton", forIndexPath: indexPath)
            cell.detailTextLabel?.text = customSnoozeTime
            return cell
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(#function)
        if indexPath.section == 0 {
            if indexPath.row != selectedIndexPath.row {
                if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
                    newCell.accessoryType = .Checkmark
                }
                
                if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
                    oldCell.accessoryType = .None
                }
                selectedIndexPath = indexPath
                
            }
            
        } else {
            //performSegueWithIdentifier("setCustomSnoozeTime", sender: self)
        }
        
    }
    
    // MARK: - Segues
    
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
        } else if segue.identifier == "setCustomSnoozeTime" {
            print("Sending data to custom snooze time")
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! CustomSnoozePickerController
            controller.delegate = self
        }
    }
}

extension SnoozePickerViewController: CustomSnoozePickerDelegate {
    func customSnoozePickerDidCancel(controller: CustomSnoozePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func customSnoozePicker(controller: CustomSnoozePickerController, didChooseTime delay: Int, unit: String) {
        dismissViewControllerAnimated(true, completion: nil)
        customSnoozeDelay = "\(delay) "
        customSnoozeUnit = unit
        tableView.reloadData()
        
        
    }
}
