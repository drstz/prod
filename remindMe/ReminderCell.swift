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
    func cellWasLongPressed(cell: ReminderCell, longPress: UILongPressGestureRecognizer)
}


class ReminderCell: UITableViewCell {
    
    @IBOutlet weak var reminderLabel: UILabel!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var shortDateLabel: UILabel!
    @IBOutlet weak var nextDueDate: UILabel!
    
    weak var delegate : ReminderCellDelegate?
    
    var longPress: UILongPressGestureRecognizer!
    var wasSelected = false
    
    let favoriteColor = UIColor(red: 1, green: 223/255, blue: 0, alpha: 1)
    let favoriteColorDimmed = UIColor(red: 1, green: 223/255, blue: 0, alpha: 0.3)
    
    let cellBackgroundColor = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
    let cellBackgroundColorDimmed = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 0.3)
    
    let lateColor = UIColor.redColor()
    let normalTextColor = UIColor.blackColor()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(recognizeLongPress))
        self.addGestureRecognizer(longPress)
        self.selectionStyle = .Blue
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureForReminder(reminder: Reminder) {
        let isLate = reminderIsLate(reminder.dueDate)
        let isFavorite = reminder.isFavorite as! Bool
        let isComplete = reminder.isComplete as Bool
        
        configureLabels(reminder.name, dueDate: reminder.dueDate, nextDate: reminder.nextDueDate, frequency: reminder.everyAmount as? Int, interval: reminder.typeOfInterval)
        configureBackgroundColors(isFavorite, isLate: isLate)
        configureLabelColors(isComplete, isLate: isLate)
    }
    
    func reminderIsLate(dueDate: NSDate) -> Bool {
        let now = NSDate()
        let earlierDate = dueDate.earlierDate(now)
        
        return earlierDate == dueDate
    }
    
    func configureLabels(name: String, dueDate: NSDate, nextDate: NSDate?, frequency: Int?, interval: String?) {
        reminderLabel.text = name
        dayLabel.text = convertDateToString(.Day, date: dueDate)
        timeLabel.text = convertDateToString(.Time, date: dueDate)
        shortDateLabel.text = convertDateToString(.ShortDate, date: dueDate)
        
        if nextDate != nil {
            if frequency != 1 {
                nextDueDate.text = "Every " + "\(frequency) " + "\(interval)" + "s"
            } else {
                nextDueDate.text = "Every " + "\(interval)"
            }
        } else {
            nextDueDate.text = "Never"
        }
    }
    
    func configureBackgroundColors(isFavorite: Bool, isLate: Bool) {
        if isFavorite == true {
            if isLate {
                backgroundColor = favoriteColorDimmed
            } else {
                backgroundColor = favoriteColor
            }
        } else {
            if isLate {
                backgroundColor = cellBackgroundColorDimmed
            } else {
                 backgroundColor = cellBackgroundColor
            }
        }
    }
    
    func configureLabelColors(isComplete: Bool, isLate: Bool) {
        if isComplete || !isLate {
            dayLabel.textColor = normalTextColor
            shortDateLabel.textColor = normalTextColor
            timeLabel.textColor = normalTextColor
        } else {
            dayLabel.textColor = lateColor
            shortDateLabel.textColor = lateColor
            timeLabel.textColor = lateColor
        }
    }
    
    func recognizeLongPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        longPress = longPressGestureRecognizer
        delegate?.cellWasLongPressed(self, longPress: longPress)
        
    }
    
    func longPressF(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
    }
}
