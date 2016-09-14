//
//  DayOfTheWeekPickerViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 26/08/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

protocol DaysOfTheWeekPickerViewControllerDelegate: class {
    func daysOfTheWeekPickerViewControllerDidChooseDay(controller: DayOfTheWeekPickerViewController, days: [Int])
    func daysOfTheWeekPickerViewControllerDidCancel(controller: DayOfTheWeekPickerViewController)
}

class DayOfTheWeekPickerViewController: UITableViewController {
    
    var delegate: DaysOfTheWeekPickerViewControllerDelegate?
    
    let daysOfWeek = [
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
        "Sunday"
    ]
    
    let weekdayUnits = [
        2, // Monday
        3,
        4,
        5,
        6,
        7,
        1  // Sunday
    ]
    
    var selectedDays = [Int]()
    
    var selectedIndexPaths = [NSIndexPath]()
    
    // MARK: Actions
    
    @IBAction func done() {
        // Keep results in proper order
        selectedDays = selectedDays.sort()
        delegate?.daysOfTheWeekPickerViewControllerDidChooseDay(self, days: selectedDays)
    }
    
    @IBAction func cancel() {
        print(#function)
        delegate?.daysOfTheWeekPickerViewControllerDidCancel(self)
    }
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<weekdayUnits.count {
            if selectedDays.contains(weekdayUnits[i]) {
                selectedIndexPaths.append(NSIndexPath(forRow: i, inSection: 0))
            }
        }
        
        setColorTheme()
    }
    
    func setColorTheme() {
        // Table view background
        tableView.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        
        // Table view separator
        tableView.separatorColor = UIColor.whiteColor()
    }
    
    // MARK: Tableview
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return weekdayUnits.count
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.whiteColor()
        // header.titleLabel.textColor = UIColor.whiteColor()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor(red: 40/255, green: 82/255, blue: 108/255, alpha: 1)
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        cell.tintColor = UIColor.whiteColor()
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("weekday", forIndexPath: indexPath)
        let dayForRow = daysOfWeek[indexPath.row]
        
        cell.textLabel?.text = dayForRow
        
        if selectedIndexPaths.contains(indexPath) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Pick one or more days"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        if selectedIndexPaths.contains(indexPath) {
            selectedCell?.accessoryType = .None
            
            // Remove Index Path
            if let indexOfElement = selectedIndexPaths.indexOf(indexPath) {
                selectedIndexPaths.removeAtIndex(indexOfElement)
            }
            
            // Remove Day
            let weekDay = weekdayUnits[indexPath.row]
            if let indexOfDay = selectedDays.indexOf(weekDay) {
                selectedDays.removeAtIndex(indexOfDay)
            }
            
        } else {
            selectedCell?.accessoryType = .Checkmark
            
            // Add index path
            selectedIndexPaths.append(indexPath)
            
            // Add day
            let day = weekdayUnits[indexPath.row]
            selectedDays.append(day)
        }
        
        print("Selected Days are: ")
        
        if selectedDays.count > 0 {
            for day in selectedDays {
                print(day)
            }
        } else {
            print("None")
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    
    
    
}
