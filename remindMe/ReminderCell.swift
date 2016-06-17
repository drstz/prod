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

protocol ReminderCellBackGroundDelegate: class {
    func changeBackgroundColor(color: UIColor)
}

class ReminderCell: UITableViewCell {
    
    @IBOutlet weak var reminderLabel: UILabel!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var shortDateLabel: UILabel!
    @IBOutlet weak var nextDueDate: UILabel!
    
    @IBOutlet weak var reminderBackgroundView: ReminderCellBackground!
    @IBOutlet weak var reminderSelectionView: UIView!
    
    weak var delegate : ReminderCellDelegate?
    weak var backgroundDelegate: ReminderCellBackGroundDelegate?
    
    var longPress: UILongPressGestureRecognizer!
    var wasSelected = false
    
    let favoriteColor = UIColor(red: 1, green: 223/255, blue: 0, alpha: 1)
    let favoriteColorDimmed = UIColor(red: 1, green: 223/255, blue: 0, alpha: 0.3)
    
    let cellBackgroundColor = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 1)
    let cellBackgroundColorDimmed = UIColor(red: 64/255, green: 224/255, blue: 208/255, alpha: 0.3)
    
    let lateColor = UIColor.redColor()
    let normalTextColor = UIColor.whiteColor()
    
    let selectionColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1)
    
    let cornerRadius: CGFloat = 5
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        reminderBackgroundView.layer.cornerRadius = cornerRadius
        reminderSelectionView.layer.cornerRadius = cornerRadius
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(recognizeLongPress))
        self.addGestureRecognizer(longPress)
        selectionStyle = .None
        backgroundDelegate = reminderBackgroundView
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        print(#function)
        if self.selected {
            reminderSelectionView?.backgroundColor = selectionColor
        } else {
            reminderSelectionView?.backgroundColor = UIColor.clearColor()
        }
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
        let frequencyAsPlural = "Every " + "\(frequency) " + "\(interval)" + "s"
        let frequencyAsSingular = "Every " + "\(interval)"
        let neverRepeats = "Never"
        
        reminderLabel.text = name
        dayLabel.text = convertDateToString(.Day, date: dueDate)
        timeLabel.text = convertDateToString(.Time, date: dueDate)
        shortDateLabel.text = convertDateToString(.ShortDate, date: dueDate)
        
        if nextDate != nil {
            if frequency != 1 {
                nextDueDate.text = frequencyAsPlural
            } else {
                nextDueDate.text = frequencyAsSingular
            }
        } else {
            nextDueDate.text = neverRepeats
        }
    }
    
    func configureBackgroundColors(isFavorite: Bool, isLate: Bool) {
        if isFavorite == true {
            if isLate {
                backgroundDelegate?.changeBackgroundColor(favoriteColorDimmed)
            } else {
                backgroundDelegate?.changeBackgroundColor(favoriteColor)
            }
        } else {
            if isLate {
                backgroundDelegate?.changeBackgroundColor(tintColor)
            } else {
                backgroundDelegate?.changeBackgroundColor(tintColor)
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
