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
    @IBOutlet weak var nextDueDate: UILabel!
    
    weak var delegate : ReminderCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureForReminder(reminder: Reminder) {
        configureLabels(reminder)
        configureColor(reminder)
    }
    
    func configureLabels(reminder: Reminder) {
        reminderLabel.text = "\(reminder.name)"
        dayLabel.text = convertDateToString(.Day, date: reminder.dueDate)
        timeLabel.text = convertDateToString(.Time, date: reminder.dueDate)
        if let nexty = reminder.nextDueDate {
            if reminder.everyAmount! != 1 {
                nextDueDate.text = "Every " + "\(reminder.everyAmount!) " + "\(reminder.typeOfInterval!)" + "s"
            } else {
                nextDueDate.text = "Every " + "\(reminder.typeOfInterval!)"
            }
        } else {
            nextDueDate.text = "Never"
        }
    }
    
    func configureColor(reminder: Reminder) {
        backgroundColor = UIColor(red: 174/255, green: 198/255, blue: 207/255, alpha: 1)
        if reminder.isFavorite == true {
            backgroundColor = UIColor(red: 1, green: 223/255, blue: 0, alpha: 1)
        }
    }
}
