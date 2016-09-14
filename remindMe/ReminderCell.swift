//
//  ReminderCell.swift
//  remindMe
//
//  Created by Duane Stoltz on 11/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

protocol ReminderCellDelegate: class {
    func cellWasLongPressed(cell: ReminderCell, longPress: UILongPressGestureRecognizer)
}

protocol ReminderCellBackGroundDelegate: class {
    func changeBackgroundColor(color: UIColor)
}

class ReminderCell: UITableViewCell {
    
    // MARK: Labels
    @IBOutlet weak var reminderLabel: UILabel!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var shortDateLabel: UILabel!
    @IBOutlet weak var nextDueDate: UILabel!
    
    
    // MARK: Views
    @IBOutlet weak var reminderBackgroundView: ReminderCellBackground!
    @IBOutlet weak var reminderSelectionView: UIView!

    
    @IBOutlet weak var favoriteStar: UIImageView!
    
    @IBOutlet weak var repeatIcon: UIImageView!
    @IBOutlet weak var commentIcon: UIImageView!
    
    weak var delegate : ReminderCellDelegate?
    weak var backgroundDelegate: ReminderCellBackGroundDelegate?
    
    var longPress: UILongPressGestureRecognizer!
    var wasSelected = false
    
    // MARK: Colors
    
    // Favorites
    let favoriteColor = UIColor(red: 1, green: 223/255, blue: 0, alpha: 1)
    let favoriteColorDimmed = UIColor(red: 1, green: 223/255, blue: 0, alpha: 0.3)
    
    // NormalColor
    let cellBackgroundColor = UIColor(red: 40/255, green: 82/255, blue: 108/255, alpha: 1)
    let cellBackgroundColorDimmed = UIColor.whiteColor()
    
    // Late color
    let lateColor = UIColor(red: 149/255, green: 40/255, blue: 54/255, alpha: 1)
    
    // Text color
    let normalTextColor = UIColor.whiteColor()
    
    let selectionColor = UIColor(red: 148/255, green: 191/255, blue: 215/255, alpha: 1)
    
    let cornerRadius: CGFloat = 5
    
    // MARK: Methods
    
    deinit {
//        print("")
//        print("Reminder Cell was deallocated")
    }
    
    override func awakeFromNib() {
//        print("")
//        print(#function)
        
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
        //print(#function)
        if self.selected {
            reminderSelectionView?.backgroundColor = selectionColor
        } else {
            reminderSelectionView?.backgroundColor = UIColor.clearColor()
        }
    }
    
    func configureForReminder(reminder: Reminder) {
        //print(#function)
        let isDue = reminder.isDue()
        let isFavorite = reminder.isFavorite as! Bool
        let isComplete = reminder.isComplete as Bool
        
        if reminder.isRecurring == true {
            nextDueDate.hidden = false
            repeatIcon.hidden = false
        } else {
            nextDueDate.hidden = true
            repeatIcon.hidden = true
        }
        
        configureLabels(reminder.name,
                        dueDate: reminder.dueDate,
                        frequency: reminder.everyAmount as? Int,
                        interval: reminder.typeOfInterval)
        configureBackgroundColors(isFavorite, isLate: isDue, isComplete: isComplete)
        configureLabelColors(isComplete, isLate: isDue)
        updateRepeatLabel(with: reminder)
        updateCommentLabel(with: reminder)
        
    }
    
    func updateCommentLabel(with reminder: Reminder) {
        if reminder.comment != nil {
            commentIcon.hidden = false
        } else {
            commentIcon.hidden = true
        }
    }
    
    func updateRepeatLabel(with reminder: Reminder) {
        if reminder.useDays == true {
            updateRepeatLabelWithDayPattern(reminder)
        } else if reminder.usePattern == true {
            updateRepeatLabelWithCustomPattern(reminder)
        }
    }
    
    func updateRepeatLabelWithCustomPattern(reminder: Reminder) {
        if let frequency = reminder.everyAmount?.integerValue, let interval = reminder.typeOfInterval {
            if frequency != 1 {
                nextDueDate.text = "every " + "\(frequency) " + "\(interval)" + "s"
            } else if frequency == 1 {
                nextDueDate.text = "every " + "\(interval)"
            }
        }
    }
    
    func updateRepeatLabelWithDayPattern(reminder: Reminder) {
        var stringOfDays = "every "
        var selectedDays = [Int]()
        for day in reminder.selectedDays {
            selectedDays.append(Int(day as! NSNumber))
        }
        if selectedDays.count > 0 {
            for day in selectedDays {
                switch day {
                case 1:
                    var day = "Sunday"
                    if selectedDays.count != 1 {
                        day = "Sun"
                    }
                    stringOfDays.appendContentsOf(day)
                case 2:
                    var day = "Monday"
                    if selectedDays.count != 1 {
                        day = "M"
                    }
                    stringOfDays.appendContentsOf(day)
                case 3:
                    var day = "Tuesday"
                    if selectedDays.count != 1 {
                        day = "T"
                    }
                    stringOfDays.appendContentsOf(day)
                case 4:
                    var day = "Wednesday"
                    if selectedDays.count != 1 {
                        day = "W"
                    }
                    stringOfDays.appendContentsOf(day)
                case 5:
                    var day = "Thursday"
                    if selectedDays.count != 1 {
                        day = "Th"
                    }
                    stringOfDays.appendContentsOf(day)
                case 6:
                    var day = "Friday"
                    if selectedDays.count != 1 {
                        day = "F"
                    }
                    stringOfDays.appendContentsOf(day)
                case 7:
                    var day = "Saturday"
                    if selectedDays.count != 1 {
                        day = "Sat"
                    }
                    stringOfDays.appendContentsOf(day)
                default:
                    print("Error appending strings of days")
                }
                if selectedDays.count > 1 {
                    // Do not print comma after last word
                    if selectedDays.indexOf(day) < selectedDays.count - 1 {
                        stringOfDays.appendContentsOf(", ")
                    }
                }
            }
            nextDueDate.text = stringOfDays
        }
    }
    
    
    
    func configureLabels(name: String, dueDate: NSDate, frequency: Int?, interval: String?) {
        //print(#function)
        
        
        
        reminderLabel.text = name
        dayLabel.text = convertDateToString(.Day, date: dueDate)
        timeLabel.text = convertDateToString(.Time, date: dueDate)
        if dueDate.isPresent() {
            // shortDateLabel.text = convertDateToString(.ShortDate, date: dueDate)
            shortDateLabel.text = convertDateToString(.Day, date: dueDate) + ", " + convertDateToString(.ShortDate, date: dueDate)
        } else {
            shortDateLabel.text = convertDateToString(.Day, date: dueDate) + ", " + convertDateToString(.ShortDate, date: dueDate)
        }
        
        
        
        
        
    }
    
    func configureBackgroundColors(isFavorite: Bool, isLate: Bool, isComplete: Bool) {
        //print(#function)
        if isFavorite == true {
            favoriteStar.hidden = false
            if isLate && !isComplete {
                backgroundDelegate?.changeBackgroundColor(lateColor)
            } else {
                backgroundDelegate?.changeBackgroundColor(cellBackgroundColor)
            }
        } else {
            favoriteStar.hidden = true
            if isLate && !isComplete {
                backgroundDelegate?.changeBackgroundColor(lateColor)
            } else {
                backgroundDelegate?.changeBackgroundColor(cellBackgroundColor)
            }
        }
    }
    
    func configureLabelColors(isComplete: Bool, isLate: Bool) {
//        print(#function)
        if isComplete || !isLate {
            dayLabel.textColor = UIColor.whiteColor()
            shortDateLabel.textColor = UIColor.whiteColor()
            timeLabel.textColor = UIColor.whiteColor()
        } else {
            dayLabel.textColor = UIColor.whiteColor()
            shortDateLabel.textColor = UIColor.whiteColor()
            timeLabel.textColor = UIColor.whiteColor()
        }
    }
    
    func recognizeLongPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        //print(#function)
        longPress = longPressGestureRecognizer
        delegate?.cellWasLongPressed(self, longPress: longPress)
        
    }
    
    func longPressF(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
    }
}
