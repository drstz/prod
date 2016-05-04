//
//  ReminderCell.swift
//  remindMe
//
//  Created by Duane Stoltz on 11/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

protocol ReminderCellDelegate: class {
    func completeButtonWasPressed (cell : ReminderCell)
}


class ReminderCell: UITableViewCell {
    
    @IBOutlet weak var reminderLabel: UILabel!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBOutlet weak var isEnabledLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
    
    
    @IBOutlet weak var nextDueDate: UILabel!
    
    weak var delegate : ReminderCellDelegate?
    
    var reminderIsEnabled = false
    
    @IBAction func completeReminder () {

        delegate?.completeButtonWasPressed(self)
        print(#function)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureForReminder(reminder: Reminder) {
        print(#function)
        
        enableReminderCell(reminder)
        configureLabels(reminder)
        configureColor(reminder)
    }
    
    func configureLabels(reminder: Reminder) {
        reminderLabel.text = "\(reminder.name)" + " " + "(\(reminder.idNumber))"
        dayLabel.text = convertDateToString(dayFromDate: reminder.dueDate)
        dateLabel.text = convertDateToString(dateFromDate: reminder.dueDate)
        timeLabel.text = convertDateToString(timeFromDate: reminder.dueDate)
        if let nexty = reminder.nextDueDate {
            if reminder.everyAmount! != 1 {
                nextDueDate.text = "Every " + "\(reminder.everyAmount!) " + "\(reminder.typeOfInterval!)" + "s"
            } else {
                nextDueDate.text = "Every " + "\(reminder.typeOfInterval!)"
            }
        } else {
            nextDueDate.text = "No recurrence"
        }
        
        if reminderIsEnabled {
            isEnabledLabel.text = "Enabled"
        } else {
            isEnabledLabel.text = "Disabled"
        }
        
        if reminder.isComplete == true {
            completeButton.setTitle("Reopen reminder", forState: .Normal)
        } else {
            completeButton.setTitle("Complete reminder", forState: .Normal)
        }
        
    }
    
    func enableReminderCell (reminder: Reminder) {
        print(#function)
        if reminder.isEnabled == 1 {
            reminderIsEnabled = true
        } else {
            reminderIsEnabled = false
        }
    }
    
    func configureColor(reminder: Reminder) {
        if reminderIsEnabled {
            backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
        } else {
            backgroundColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 1)
        }
    }
}
