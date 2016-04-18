//
//  ReminderCell.swift
//  remindMe
//
//  Created by Duane Stoltz on 11/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit


class ReminderCell: UITableViewCell {
    
    @IBOutlet weak var reminderLabel: UILabel!
    @IBOutlet weak var occurenceLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var isEnabledLabel: UILabel!
    

    
    var reminderIsEnabled = false
    
    @IBAction func completeReminder () {
        backgroundColor = UIColor(red: 1, green: 0, blue: 1, alpha: 1)
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
        func enableReminderCell () {
            print(#function)
            if reminder.isEnabled == 1 {
                reminderIsEnabled = true
            } else {
                reminderIsEnabled = false
            }
        }
        reminderLabel.text = reminder.name
        occurenceLabel.text = dateConverter(dateToConvert: reminder.dueDate)
        enableReminderCell()
       if reminderIsEnabled {
        print(reminderIsEnabled)
           isEnabledLabel.text = "Enabled"
            backgroundColor = UIColor(red: 163/255, green: 45/255, blue: 85/255, alpha: 0.9)
        } else {
            print(reminderIsEnabled)
           isEnabledLabel.text = "Disabled"
            backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.4)
       }
    }
    


}
