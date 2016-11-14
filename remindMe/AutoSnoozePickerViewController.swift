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
    
    var selectedIndexPath = IndexPath()
    
    override func viewDidLoad() {
        print(#function)
        super.viewDidLoad()
        for i in 0..<autoSnoozeTime.count {
            if autoSnoozeTime[i] == selectedAutoSnoozeTime {
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }
        
        setColorTheme()
    }
    
    func setColorTheme() {
        // Table view background
        tableView.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        
        // Table view separator
        tableView.separatorColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(#function)
        return autoSnoozeTime.count
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
        print(#function)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let autoSnoozeTime = self.autoSnoozeTime[(indexPath as NSIndexPath).row]
        cell.textLabel!.text = autoSnoozeTime
        
        if autoSnoozeTime == selectedAutoSnoozeTime {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function)
        if (indexPath as NSIndexPath).row != (selectedIndexPath as NSIndexPath).row {
            if let newCell = tableView.cellForRow(at: indexPath) {
                newCell.accessoryType = .checkmark
            }
            
            if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                oldCell.accessoryType = .none
            }
            selectedIndexPath = indexPath
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(#function)
        if segue.identifier == "PickedAutoSnoozeTime" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                selectedAutoSnoozeTimeIndex = (indexPath as NSIndexPath).row
                switch selectedAutoSnoozeTimeIndex {
                case 0:
                    setDefaultAutoSnoozeTime(.minute)
                case 1:
                    setDefaultAutoSnoozeTime(.hour)
                default:
                    break
                    
                }
                
            }
        }
    }
}

