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
        (5, .Minutes),
        (30, .Minutes),
        (1, .Hours)
    ]
    
    var selectedIndexPath = IndexPath()
    
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
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }
        if !foundSomething {
            selectedIndexPath = IndexPath(row: 0, section: 1)
        }
        
        setColorTheme()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(#function)
        super.viewWillAppear(animated)
    }
    
    func setColorTheme() {
        // Table view background
        tableView.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        
        // Table view separator
        tableView.separatorColor = UIColor.white
    }
    
    
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Custom Snooze Time"
        } else {
            return "Defaut Snooze Times"
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        // header.titleLabel.textColor = UIColor.whiteColor()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red: 40/255, green: 82/255, blue: 108/255, alpha: 1)
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        cell.tintColor = UIColor.white
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        print(#function)
        if (indexPath as NSIndexPath).section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "snoozeChoice", for: indexPath)
            let snoozeTime = self.snoozeTimes[(indexPath as NSIndexPath).row]
            let unitString = getLabel(snoozeTime.0, snoozeUnit: snoozeTime.1)
            let durationString = Int(snoozeTime.0)
            
            cell.textLabel!.text = "\(durationString) \(unitString)"
            
            if snoozeTime == selectedSnoozeTimeTuple! && !isUsingCustomSnoozeTime() {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            
        } else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "customSnoozeButton", for: indexPath)
            cell.textLabel?.text = customSnoozeTime
            //cell.detailTextLabel?.text = customSnoozeTime
            if isUsingCustomSnoozeTime() {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
        } else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "addCustomSnooze", for: indexPath)
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function)
        if (indexPath as NSIndexPath).section == 0 {
            setUsingCustomSnoozeTime(false)
            print(selectedIndexPath)
            
            if (indexPath as NSIndexPath).section == (selectedIndexPath as NSIndexPath).section {
                if (indexPath as NSIndexPath).row != (selectedIndexPath as NSIndexPath).row {
                    if let newCell = tableView.cellForRow(at: indexPath) {
                        newCell.accessoryType = .checkmark
                    }
                    
                    if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                        print("Old cell : section \((selectedIndexPath as NSIndexPath).section) row \((selectedIndexPath as NSIndexPath).row)")
                        oldCell.accessoryType = .none
                    }
                    selectedIndexPath = indexPath
                    setUsingCustomSnoozeTime(false)
                    
                    saveSnoozeTime(indexPath)
                    
                    
                    tableView.deselectRow(at: indexPath, animated: true)
                }
            } else {
                if let newCell = tableView.cellForRow(at: indexPath) {
                    newCell.accessoryType = .checkmark
                }
                
                if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                    print("Old cell : section \((selectedIndexPath as NSIndexPath).section) row \((selectedIndexPath as NSIndexPath).row)")
                    oldCell.accessoryType = .none
                }
                selectedIndexPath = indexPath
                
                
                saveSnoozeTime(indexPath)
                
                
                tableView.deselectRow(at: indexPath, animated: true)
                
            }
            
        }
        
        if (indexPath as NSIndexPath).section == 1 {
            
            if (indexPath as NSIndexPath).section == (selectedIndexPath as NSIndexPath).section {
                if (indexPath as NSIndexPath).row != (selectedIndexPath as NSIndexPath).row {
                    if (indexPath as NSIndexPath).row == 0 {
                        let customSnoozeTime = getCustomSnoozeTime()
                        if customSnoozeTime.0 != 0 {
                            setUsingCustomSnoozeTime(true)
                            
                            setSnoozeTime(customSnoozeTime.0, unit: customSnoozeTime.1)
                            if let newCell = tableView.cellForRow(at: indexPath) {
                                newCell.accessoryType = .checkmark
                            }
                            
                            if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                                print("Old cell : section \((selectedIndexPath as NSIndexPath).section) row \((selectedIndexPath as NSIndexPath).row)")
                                oldCell.accessoryType = .none
                            }
                            selectedIndexPath = indexPath
                        }
                    }
                }
            } else {
                if (indexPath as NSIndexPath).row == 0 {
        
                    
                    let customSnoozeTime = getCustomSnoozeTime()
                    if  customSnoozeTime.0 != 0 {
                        setUsingCustomSnoozeTime(true)
                        setSnoozeTime(customSnoozeTime.0, unit: customSnoozeTime.1)
                        if let newCell = tableView.cellForRow(at: indexPath) {
                            newCell.accessoryType = .checkmark
                        }
                        
                        if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                            print("Old cell : section \((selectedIndexPath as NSIndexPath).section) row \((selectedIndexPath as NSIndexPath).row)")
                            oldCell.accessoryType = .none
                        }
                        selectedIndexPath = indexPath
                    }
                    
                }
                
                if (indexPath as NSIndexPath).row == 1 {
                    performSegue(withIdentifier: "setCustomSnoozeTime", sender: self)
                }
            }
            tableView.deselectRow(at: indexPath, animated: true)

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
    
    func saveSnoozeTime(_ indexPath: IndexPath) {
        selectedSnoozeTimeIndex = (indexPath as NSIndexPath).row
        switch selectedSnoozeTimeIndex {
        case 0:
            setSnoozeTime(5, unit: .Minutes)
            overwriteOldTimes(5, unit: .Minutes)
        case 1:
            setSnoozeTime(30, unit: .Minutes)
            overwriteOldTimes(30, unit: .Minutes)
        case 2:
            setSnoozeTime(1, unit: .Hours)
            overwriteOldTimes(1, unit: .Hours)
        default:
            break
            
        }
        
    }
    
    func overwriteOldTimes(_ duration: Double, unit: SnoozeUnit) {
        chosenDuration = duration
        chosenUnit = unit
        selectedSnoozeTimeTuple = (duration, unit)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(#function)
        if segue.identifier == "setCustomSnoozeTime" {
            let navigationController = segue.destination as! UINavigationController
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
    func customSnoozePickerDidCancel(_ controller: CustomSnoozePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func customSnoozePicker(_ controller: CustomSnoozePickerController, didChooseTime delay: Double, unit: SnoozeUnit) {
        dismiss(animated: true, completion: nil)
        
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
                let indexPath = IndexPath(item: 2, section: 0)
                let cell = tableView.cellForRow(at: indexPath)
                cell?.accessoryType = .checkmark
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
