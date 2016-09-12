//
//  PopupViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 21/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit
import CoreData

protocol PopupViewControllerDelegate: class {
    func popupViewControllerDidComplete(controller: PopupViewController, reminder: Reminder)
    func popupViewControllerDidSnooze(controller: PopupViewController, reminder: Reminder)
    func popupViewControllerDidDelete(controller: PopupViewController, reminder: Reminder)
}


class PopupViewController: UIViewController, AddReminderViewControllerDelegate {
    @IBOutlet weak var popup: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    // MARK: Labels
    
    @IBOutlet weak var reminderNameLabel: UILabel!
    @IBOutlet weak var reminderDayLabel: UILabel!
    @IBOutlet weak var reminderDueTimeLabel: UILabel!
    @IBOutlet weak var reminderShortDateLabel: UILabel!
    @IBOutlet weak var repeatLabel: UILabel!
    
    // MARK: Buttons
    
    @IBOutlet weak var snoozeButton: UIButton!
    
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteButtonBackground: UIView!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: Image
    
    @IBOutlet weak var repeatIcon: UIImageView!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    // MARK: - Delegates
    
    weak var delegate: PopupViewControllerDelegate?
    
    // MARK: - Core Date
    var managedObjectContext: NSManagedObjectContext!
    
    // MARK: - Properties
    
    var incomingReminder: Reminder?
    
    // MARK: Colors
    
    // Late
    
    var lateColor = UIColor(red: 149/255, green: 40/255, blue: 54/255, alpha: 1)
    var lightLate = UIColor(red: 169/255, green: 45/255, blue: 61/255, alpha: 1)
    var lighterLate = UIColor(red: 189/255, green: 51/255, blue: 69/255, alpha: 1)
    var lightestRed = UIColor(red: 203/255, green: 62/255, blue: 80/255, alpha: 1)
    var shinyRed = UIColor(red: 208/255, green: 82/255, blue: 98/255, alpha: 1)
    
    // Normal
    
    var normalColor = UIColor(red: 40/255, green: 83/255, blue: 108/255, alpha: 1)
    var lightNormal = UIColor(red: 47/255, green: 97/255, blue: 127/255, alpha: 1)
    var lighterNormal = UIColor(red: 54/255, green: 112/255, blue: 145/255, alpha: 1)
    var lightestNormal = UIColor(red: 61/255, green: 126/255, blue: 164/255, alpha: 1)
    var shinyNormal = UIColor(red: 68/255, green: 140/255, blue: 183/255, alpha: 1)
    
    
    @IBAction func complete() {
        delegate?.popupViewControllerDidComplete(self, reminder: incomingReminder!)
    }
    
    @IBAction func snooze() {
        delegate?.popupViewControllerDidSnooze(self, reminder: incomingReminder!)
    }
    
    @IBAction func delete() {
        let alert = UIAlertController(title: "Delete \"\((incomingReminder?.name)!)\" ?", message: "You cannot undo this", preferredStyle: .Alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: {
            action in
                self.delegate?.popupViewControllerDidDelete(self, reminder: self.incomingReminder!)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func favorite() {
        if let reminder = incomingReminder {
            if reminder.isFavorite == true {
                reminder.setFavorite(false)
            } else {
                reminder.setFavorite(true)
            }
        }
        let coreDataHandler = CoreDataHandler()
        coreDataHandler.setObjectContext(managedObjectContext)
        coreDataHandler.save()
        setFavoriteStar()
        
    }
    
    @IBAction func close() {
         dismissViewControllerAnimated(true, completion: nil)
    }
    
    deinit {
        print(#function)
        print(self)
    }
    
    
    // MARK: - Delegate Methods
    
    // MARK: AddReminder
    
    func addReminderViewControllerDidCancel(controller: AddReminderViewController) {
        print(#function)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewController(controller: AddReminderViewController, didFinishEditingReminder reminder: Reminder) {
        print(#function)
        setLabels(with: reminder)
        if reminder.dueDate.isPresent() {
            snoozeButton.hidden = true
        } else {
            snoozeButton.hidden = false
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewControllerDidFinishAdding(controller: AddReminderViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewController(controller: AddReminderViewController, didChooseToDeleteReminder reminder: Reminder) {
        print(#function)
        dismissViewControllerAnimated(true, completion: nil)
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popup.layer.masksToBounds = true
        popup.layer.cornerRadius = 10
        snoozeButton.layer.cornerRadius = 10
        closeButton.layer.cornerRadius = 10
        
        
        var gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(favoriteButtonWasPressed))
        favoriteButtonBackground.addGestureRecognizer(gestureRecognizer)
        
        // Disabled until I can animate button correctly when simulating a tap
        favoriteButton.adjustsImageWhenHighlighted = false
    }
    
    func favoriteButtonWasPressed() {
        favorite()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            backgroundView.backgroundColor = UIColor.clearColor()
        } else {
            backgroundView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
        }
        updatePopup()
    }
    
    func updatePopup() {
        if let reminder = incomingReminder {
            setLabels(with: reminder)
            setFavoriteStar()
            if reminder.isDue() && reminder.isComplete == false {
                snoozeButton.hidden = false
            } else {
                snoozeButton.hidden = true
            }
            
            if let comment = reminder.comment {
                commentLabel.hidden = false
                commentLabel.text = comment
            } else {
                commentLabel.hidden = true
            }
            
            
            if reminder.isDue() && reminder.isComplete == false {
                popup.backgroundColor = lateColor
                completeButton.backgroundColor = lighterLate
                favoriteButtonBackground.backgroundColor = shinyRed
                editButton.backgroundColor = lightestRed
                deleteButton.backgroundColor = lightLate
                closeButton.backgroundColor = lateColor
                snoozeButton.backgroundColor = lightestRed
            } else {
                popup.backgroundColor = normalColor
                completeButton.backgroundColor = lighterNormal
                favoriteButtonBackground.backgroundColor = shinyNormal
                editButton.backgroundColor = lightestNormal
                deleteButton.backgroundColor = lightNormal
                closeButton.backgroundColor = normalColor
            }
            
            if reminder.isComplete == true {
                completeButton.enabled = false
                completeButton.setTitle("Completed", forState: .Disabled)
                completeButton.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
            } else {
                completeButton.enabled = true
                completeButton.setTitle("Complete", forState: .Normal)
                completeButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            }
            
            if reminder.isRecurring == true {
                repeatIcon.hidden = false
                repeatLabel.hidden = false
            } else {
                repeatIcon.hidden = true
                repeatLabel.hidden = true
            }
        }
    }
    
    func setLabels(with reminder: Reminder) {
        reminderNameLabel.text = reminder.name
        reminderDayLabel.text = convertDateToString(.Day, date: reminder.dueDate)
        reminderDueTimeLabel.text = convertDateToString(.Time, date: reminder.dueDate)
        reminderShortDateLabel.text = convertDateToString(.ShortDate, date: reminder.dueDate)
        updateRepeatLabel(with: reminder)
    }
    
    func updateRepeatLabel(with reminder: Reminder) {
        if reminder.useDays == true {
            updateRepeatLabelWithDayPattern(reminder)
        } else if reminder.usePattern == true {
            updateRepeatLabelWithCustomPattern(reminder)
        } else {
            repeatLabel.hidden = true
        }
        
    }
    
    func updateRepeatLabelWithCustomPattern(reminder: Reminder) {
        if let frequency = reminder.everyAmount?.integerValue, let interval = reminder.typeOfInterval {
            if frequency != 1 {
                repeatLabel.text = "every " + "\(frequency) " + "\(interval)" + "s"
            } else if frequency == 1 {
                repeatLabel.text = "every " + "\(interval)"
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
                    stringOfDays.appendContentsOf("Sun")
                case 2:
                    stringOfDays.appendContentsOf("Mon")
                case 3:
                    stringOfDays.appendContentsOf("Tue")
                case 4:
                    stringOfDays.appendContentsOf("Wed")
                case 5:
                    stringOfDays.appendContentsOf("Thu")
                case 6:
                    stringOfDays.appendContentsOf("Fri")
                case 7:
                    stringOfDays.appendContentsOf("Sat")
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
            repeatLabel.text = stringOfDays
        }
    }
    
    
    
    func setFavoriteStar() {
        if let reminder = incomingReminder {
            if reminder.isFavorite == true {
                let yellowStar = UIImage.init(named: "starYellow100")
                favoriteButton.setImage(yellowStar, forState: .Normal)
            } else {
                let whiteStar = UIImage.init(named: "starWhite100")
                favoriteButton.setImage(whiteStar, forState: .Normal)
            }
        }
    }
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(#function)
        if segue.identifier == "EditReminder" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! AddReminderViewController
            
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext
            controller.reminderToEdit = incomingReminder
        }
    }

}

extension PopupViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController,
                                                          presentingViewController presenting: UIViewController,
                                                          sourceViewController source: UIViewController) -> UIPresentationController? {
        
        return DimmingPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}

extension PopupViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}

