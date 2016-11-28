//
//  DayOfTheWeekPickerViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 26/08/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

protocol DaysOfTheWeekPickerViewControllerDelegate: class {
    func daysOfTheWeekPickerViewControllerDidChooseDay(_ controller: DayOfTheWeekPickerViewController, days: [Int])
    func daysOfTheWeekPickerViewControllerDidCancel(_ controller: DayOfTheWeekPickerViewController)
}

class DayOfTheWeekPickerViewController: UITableViewController {
    
    var delegate: DaysOfTheWeekPickerViewControllerDelegate?
    
    let theme = Theme()
    
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
    
    var selectedIndexPaths = [IndexPath]()
    
    // MARK: Actions
    
    @IBAction func done() {
        // Keep results in proper order
        selectedDays = selectedDays.sorted()
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
                selectedIndexPaths.append(IndexPath(row: i, section: 0))
            }
        }
        
        setColorTheme()
    }
    
    func setColorTheme() {
        // Table view background
        tableView.backgroundColor = theme.backgroundColor
        
        // Table view separator
        tableView.separatorColor = UIColor.white
    }
    
    // MARK: Tableview
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return weekdayUnits.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        // header.titleLabel.textColor = UIColor.whiteColor()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = theme.normalColor
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        cell.tintColor = UIColor.white
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weekday", for: indexPath)
        let dayForRow = daysOfWeek[(indexPath as NSIndexPath).row]
        
        cell.textLabel?.text = dayForRow
        
        if selectedIndexPaths.contains(indexPath) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Pick one or more days"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        if selectedIndexPaths.contains(indexPath) {
            selectedCell?.accessoryType = .none
            
            // Remove Index Path
            if let indexOfElement = selectedIndexPaths.index(of: indexPath) {
                selectedIndexPaths.remove(at: indexOfElement)
            }
            
            // Remove Day
            let weekDay = weekdayUnits[(indexPath as NSIndexPath).row]
            if let indexOfDay = selectedDays.index(of: weekDay) {
                selectedDays.remove(at: indexOfDay)
            }
            
        } else {
            selectedCell?.accessoryType = .checkmark
            
            // Add index path
            selectedIndexPaths.append(indexPath)
            
            // Add day
            let day = weekdayUnits[(indexPath as NSIndexPath).row]
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
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    
    
}
