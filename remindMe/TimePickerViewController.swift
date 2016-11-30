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
    @IBOutlet weak var timePicker: UIDatePicker!
    
    var selectedInterval = 1
    
    var selectedIndexPath = IndexPath()
    
    let intervals = [
        1,
        5,
        10,
        15,
        30
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0 ..< intervals.count {
            if intervals[i] == selectedInterval {
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }
        // Change this first or else time interval doesn't update
        timePicker.datePickerMode = .time
        timePicker.minuteInterval = timePickerInterval()
        
        timePicker.isEnabled = false
        
        timePicker.isUserInteractionEnabled = false
        
        timePicker.backgroundColor = UIColor.clear
        timePicker.setValue(UIColor.white, forKey: "textColor")
        
        setColorTheme()
    }
    
    func setColorTheme() {
        // Table view background
        tableView.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        
        // Table view separator
        tableView.separatorColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intervals.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Pick an interval", comment: "Pick how many minutes are changed when you change the clock")
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red: 40/255, green: 82/255, blue: 108/255, alpha: 1)
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        cell.tintColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(#function)
        let cell = tableView.dequeueReusableCell(withIdentifier: "interval", for: indexPath)
        let intervalForRow = intervals[(indexPath as NSIndexPath).row]
        
        print("Interval is \(intervalForRow) at indexPath row \((indexPath as NSIndexPath).row)")
        print("Selected interval is \(selectedInterval)")
        
        var minuteString = ""
        if intervalForRow == 1 {
            minuteString = "minute"
            minuteString = NSLocalizedString("minute", comment: "")
        } else {
            minuteString = NSLocalizedString("minutes", comment: "")
        }
        
        cell.textLabel?.text = String(intervalForRow) + " " + minuteString
        
        if indexPath == selectedIndexPath {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath != selectedIndexPath {
            if let newCell = tableView.cellForRow(at: indexPath) {
                newCell.accessoryType = .checkmark
            }
            
            if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                oldCell.accessoryType = .none
            }
            
            selectedIndexPath = indexPath
            
            // Get Interval from row
            let interval = intervalFromRow((selectedIndexPath as NSIndexPath).row)
            
            // Save interval here
            saveTimePickerInterval(interval)
            print("Interval was set to \(timePickerInterval())")
            
            timePicker.minuteInterval = interval
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func intervalFromRow(_ row: Int) -> Int {
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
        default:
            print("Problem finding interval from row \(row)")
            print("Returning 1")
            return 1
        }
    }
    
}
