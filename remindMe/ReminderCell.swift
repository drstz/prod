//
//  ReminderCell.swift
//  remindMe
//
//  Created by Duane Stoltz on 11/04/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol ReminderCellDelegate: class {
    func cellWasLongPressed(_ cell: ReminderCell, longPress: UILongPressGestureRecognizer)
}

protocol ReminderCellBackGroundDelegate: class {
    func changeBackgroundColor(_ color: UIColor)
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

    // MARK: Icons
    @IBOutlet weak var starIcon: UIImageView!
    
    @IBOutlet weak var repeatIcon: UIImageView!
    @IBOutlet weak var commentIcon: UIImageView!
    
    weak var delegate : ReminderCellDelegate?
    weak var backgroundDelegate: ReminderCellBackGroundDelegate?
    
    var longPress: UILongPressGestureRecognizer!
    var wasSelected = false
    
    // MARK: Colors
    let theme = Theme()
    
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
        backgroundColor = UIColor.clear
        reminderBackgroundView.layer.cornerRadius = cornerRadius
        reminderSelectionView.layer.cornerRadius = cornerRadius
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(recognizeLongPress))
        self.addGestureRecognizer(longPress)
        selectionStyle = .none
        backgroundDelegate = reminderBackgroundView
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //print(#function)
        if self.isSelected {
            reminderSelectionView?.backgroundColor = theme.selectionColor
        } else {
            reminderSelectionView?.backgroundColor = UIColor.clear
        }
    }
    
    func configureForReminder(_ reminder: Reminder) {
        //print(#function)
        let isDue = reminder.isDue()
        let isFavorite = reminder.isFavorite as! Bool
        let isComplete = reminder.wasCompleted as Bool
        
        if reminder.repeats == true {
            nextDueDate.isHidden = false
            repeatIcon.isHidden = false
        } else {
            nextDueDate.isHidden = true
            repeatIcon.isHidden = true
        }
        
        configureLabels(reminder.name,
                        dueDate: reminder.dueDate as Date,
                        frequency: reminder.frequency as? Int,
                        interval: reminder.interval)
        configureBackgroundColors(isFavorite, isLate: isDue, isComplete: isComplete)
        configureLabelColors(isComplete, isLate: isDue)
        updateRepeatLabel(with: reminder)
        updateCommentLabel(with: reminder)
        
    }
    
    func updateCommentLabel(with reminder: Reminder) {
        if reminder.comment != nil {
            commentIcon.isHidden = false
        } else {
            commentIcon.isHidden = true
        }
    }
    
    func updateRepeatLabel(with reminder: Reminder) {
        if reminder.usesDayPattern == true {
            updateRepeatLabelWithDayPattern(reminder)
        } else if reminder.usesCustomPattern == true {
            updateRepeatLabelWithCustomPattern(reminder)
        }
    }
    
    
    
    func updateRepeatLabelWithCustomPattern(_ reminder: Reminder) {
        
        if let frequency = reminder.frequency?.intValue, let interval = reminder.interval {
            nextDueDate.text = patternPhrase(frequency: frequency, interval: interval)
        }
    }
    
    func updateRepeatLabelWithDayPattern(_ reminder: Reminder) {
        var selectedDays = [Int]()
        for day in reminder.selectedDays {
            selectedDays.append(Int(day as! NSNumber))
        }
        if selectedDays.count > 0 {
            nextDueDate.text = listOfSelectedDays(selectedDays: selectedDays)
        }
    }
    
    func configureLabels(_ name: String, dueDate: Date, frequency: Int?, interval: String?) {
        reminderLabel.text = name
        dayLabel.text = convertDateToString(.Day, date: dueDate)
        timeLabel.text = convertDateToString(.Time, date: dueDate)
        if dueDate.isPresent() {
            shortDateLabel.text = convertDateToString(.ShortDate, date: dueDate)
        } else {
            shortDateLabel.text = convertDateToString(.ShortDate, date: dueDate)
        }
    }
    
    func configureBackgroundColors(_ isFavorite: Bool, isLate: Bool, isComplete: Bool) {
        //print(#function)
        if isFavorite == true {
            let yellowStar = UIImage.init(named: "Star Filled-44 (1)")
            starIcon.image = yellowStar
            starIcon.alpha = 1
            if isLate && !isComplete {
                backgroundDelegate?.changeBackgroundColor(theme.lateColor)
            } else {
                backgroundDelegate?.changeBackgroundColor(theme.normalColor)
            }
        } else {
            let whiteStar = UIImage.init(named: "Star-44")
            starIcon.image = whiteStar
            starIcon.alpha = 0.3
            if isLate && !isComplete {
                backgroundDelegate?.changeBackgroundColor(theme.lateColor)
            } else {
                backgroundDelegate?.changeBackgroundColor(theme.normalColor)
            }
        }
    }
    
    func configureLabelColors(_ isComplete: Bool, isLate: Bool) {
        reminderLabel.textColor = theme.normalTextColor
        dayLabel.textColor = theme.normalTextColor
        shortDateLabel.textColor = theme.normalTextColor
        timeLabel.textColor = theme.normalTextColor
    }
    
    func recognizeLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        //print(#function)
        longPress = longPressGestureRecognizer
        delegate?.cellWasLongPressed(self, longPress: longPress)
    }
    
    func longPressF(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
    }
}
