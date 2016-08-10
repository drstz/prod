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
    var selectedSnoozeTimeTuple: (Double, SnoozeUnit)?
    
    var chosenDuration: Double?
    var chosenUnit: SnoozeUnit?
    
    var customSnoozeTime: String {
        return (customSnoozeDelay + " " + customSnoozeUnit)
    }
    
    var customSnoozeUnit = ""
    var customSnoozeDelay = "None"
    
    let snoozeTimes: [(Double, SnoozeUnit)] = [
        (10, .Seconds),
        (5, .Minutes),
        (10, .Minutes),
        (30, .Minutes),
        (1, .Hours)
    ]
    
    var selectedIndexPath = NSIndexPath()
    
    override func viewDidLoad() {
        print(#function)
        super.viewDidLoad()
        var foundSomething = false
        updateCustomSnoozeLabel()
        
        let durationAndUnit = (chosenDuration!, chosenUnit!)
        
        for i in 0..<snoozeTimes.count {
            print("Checking index path")
            print(durationAndUnit)
            print(snoozeTimes[i] == durationAndUnit)
            if snoozeTimes[i] == durationAndUnit && !isUsingCustomSnoozeTime() {
                print("Got in if")
                foundSomething = true
                selectedIndexPath = NSIndexPath(forRow: i, inSection: 0)
                break
            }
        }
        if !foundSomething {
            selectedIndexPath = NSIndexPath(forRow: 0, inSection: 1)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        print(#function)
        super.viewWillAppear(animated)
    }
    
    
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        
        switch section {
        case 0:
            rowCount = snoozeTimes.count
        case 1:
            rowCount = 2
        default:
            break
        }
        
        return rowCount
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Custom Snooze Time"
        } else {
            return "Defaut Snooze Times"
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        print(#function)
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("snoozeChoice", forIndexPath: indexPath)
            let snoozeTime = self.snoozeTimes[indexPath.row]
            let unitString = getLabel(snoozeTime.0, snoozeUnit: snoozeTime.1)
            let durationString = Int(snoozeTime.0)
            
            cell.textLabel!.text = "\(durationString) \(unitString)"
            
            if snoozeTime == selectedSnoozeTimeTuple! && !isUsingCustomSnoozeTime() {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
            
            
        } else if indexPath.section == 1 && indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("customSnoozeButton", forIndexPath: indexPath)
            cell.textLabel?.text = customSnoozeTime
            //cell.detailTextLabel?.text = customSnoozeTime
            if isUsingCustomSnoozeTime() {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
            
        } else if indexPath.section == 1 && indexPath.row == 1 {
            cell = tableView.dequeueReusableCellWithIdentifier("addCustomSnooze", forIndexPath: indexPath)
        }
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(#function)
        if indexPath.section == 0 {
            setUsingCustomSnoozeTime(false)
            print(selectedIndexPath)
            
            if indexPath.section == selectedIndexPath.section {
                if indexPath.row != selectedIndexPath.row {
                    if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
                        newCell.accessoryType = .Checkmark
                    }
                    
                    if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
                        print("Old cell : section \(selectedIndexPath.section) row \(selectedIndexPath.row)")
                        oldCell.accessoryType = .None
                    }
                    selectedIndexPath = indexPath
                    setUsingCustomSnoozeTime(false)
                    
                    saveSnoozeTime(indexPath)
                    
                    
                    tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
            } else {
                if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
                    newCell.accessoryType = .Checkmark
                }
                
                if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
                    print("Old cell : section \(selectedIndexPath.section) row \(selectedIndexPath.row)")
                    oldCell.accessoryType = .None
                }
                selectedIndexPath = indexPath
                
                
                saveSnoozeTime(indexPath)
                
                
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                
            }
            
        }
        
        if indexPath.section == 1 {
            
            if indexPath.section == selectedIndexPath.section {
                if indexPath.row != selectedIndexPath.row {
                    if indexPath.row == 0 {
                        let customSnoozeTime = getCustomSnoozeTime()
                        if customSnoozeTime.0 != 0 {
                            setUsingCustomSnoozeTime(true)
                            
                            setSnoozeTime(customSnoozeTime.0, unit: customSnoozeTime.1)
                            if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
                                newCell.accessoryType = .Checkmark
                            }
                            
                            if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
                                print("Old cell : section \(selectedIndexPath.section) row \(selectedIndexPath.row)")
                                oldCell.accessoryType = .None
                            }
                            selectedIndexPath = indexPath
                        }
                    }
                }
            } else {
                if indexPath.row == 0 {
        
                    
                    let customSnoozeTime = getCustomSnoozeTime()
                    if  customSnoozeTime.0 != 0 {
                        setUsingCustomSnoozeTime(true)
                        setSnoozeTime(customSnoozeTime.0, unit: customSnoozeTime.1)
                        if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
                            newCell.accessoryType = .Checkmark
                        }
                        
                        if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
                            print("Old cell : section \(selectedIndexPath.section) row \(selectedIndexPath.row)")
                            oldCell.accessoryType = .None
                        }
                        selectedIndexPath = indexPath
                    }
                    
                }
                
                if indexPath.row == 1 {
                    performSegueWithIdentifier("setCustomSnoozeTime", sender: self)
                }
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)

        }
        
    }
    
    func updateCustomSnoozeLabel() {
        let customSnoozeTime = getCustomSnoozeTime()
        if customSnoozeTime.0 == 0 {
            customSnoozeUnit = ""
            customSnoozeDelay = "None"
        } else {
            customSnoozeUnit = getLabel(customSnoozeTime.0, snoozeUnit: customSnoozeTime.1)
            customSnoozeDelay = "\(Int(customSnoozeTime.0))"
        }
        
        
    }
    
    func saveSnoozeTime(indexPath: NSIndexPath) {
        selectedSnoozeTimeIndex = indexPath.row
        switch selectedSnoozeTimeIndex {
        case 0:
            setSnoozeTime(10, unit: .Seconds)
            overwriteOldTimes(10, unit: .Seconds)
        case 1:
            setSnoozeTime(5, unit: .Minutes)
            overwriteOldTimes(5, unit: .Minutes)
        case 2:
            setSnoozeTime(10, unit: .Minutes)
            overwriteOldTimes(10, unit: .Minutes)
        case 3:
            setSnoozeTime(30, unit: .Minutes)
            overwriteOldTimes(30, unit: .Minutes)
        case 4:
            setSnoozeTime(1, unit: .Hours)
            overwriteOldTimes(1, unit: .Hours)
        default:
            break
            
        }
        
    }
    
    func overwriteOldTimes(duration: Double, unit: SnoozeUnit) {
        chosenDuration = duration
        chosenUnit = unit
        selectedSnoozeTimeTuple = (duration, unit)
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(#function)
        if segue.identifier == "setCustomSnoozeTime" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! CustomSnoozePickerController
            let customSnoozeTime = getCustomSnoozeTime()
            let duration = customSnoozeTime.0
            let unit = customSnoozeTime.1
            controller.delegate = self
            controller.delay = duration
            controller.unit = unit
            
            
        }
    }
}

extension SnoozePickerViewController: CustomSnoozePickerDelegate {
    func customSnoozePickerDidCancel(controller: CustomSnoozePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func customSnoozePicker(controller: CustomSnoozePickerController, didChooseTime delay: Double, unit: SnoozeUnit) {
        dismissViewControllerAnimated(true, completion: nil)
        
        saveCustomSnoozeTime(delay, unit: unit)
        
        if delay != 0 {
            
            
            customSnoozeUnit = getLabel(delay, snoozeUnit: unit)
            customSnoozeDelay = "\(Int(delay))"
            
            if isUsingCustomSnoozeTime() {
                setSnoozeTime(delay, unit: unit)
            }
            print(selectedIndexPath)
        } else {
            if isUsingCustomSnoozeTime() {
                let indexPath = NSIndexPath(forItem: 2, inSection: 0)
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                cell?.accessoryType = .Checkmark
                selectedIndexPath = indexPath
                saveSnoozeTime(selectedIndexPath)
                setUsingCustomSnoozeTime(false)
                customSnoozeUnit = ""
                customSnoozeDelay = "None"
            }
        }
        tableView.reloadData()
    }
}
