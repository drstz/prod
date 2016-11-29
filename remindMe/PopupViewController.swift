//
//  PopupViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 21/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit
import CoreData

import Fabric
import Crashlytics

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

protocol PopupViewControllerDelegate: class {
    func popupViewControllerDidComplete(_ controller: PopupViewController, reminder: Reminder)
    func popupViewControllerDidSnooze(_ controller: PopupViewController, reminder: Reminder)
    func popupViewControllerDidDelete(_ controller: PopupViewController, reminder: Reminder)
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
    
    let theme = Theme()
    
    @IBAction func complete() {
        delegate?.popupViewControllerDidComplete(self, reminder: incomingReminder!)
        
        // Tracking
        Answers.logCustomEvent(withName: "Completed", customAttributes: ["Category": "Popup"])
    }
    
    @IBAction func snooze() {
        
        delegate?.popupViewControllerDidSnooze(self, reminder: incomingReminder!)
        
        // Tracking
        Answers.logCustomEvent(withName: "Snoozed", customAttributes: ["Category": "Popup"])
    }
    
    @IBAction func delete() {
        let alert = UIAlertController(title: "Delete \"\((incomingReminder?.name)!)\" ?", message: "You cannot undo this", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {
            action in
            // Tracking
            Answers.logCustomEvent(withName: "Delete", customAttributes: ["Category": "Popup"])
                self.delegate?.popupViewControllerDidDelete(self, reminder: self.incomingReminder!)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func favorite() {
        if let reminder = incomingReminder {
            if reminder.isFavorite == true {
                reminder.setFavorite(false)
                
                // Tracking
                Answers.logCustomEvent(withName: "Unfavorited", customAttributes: ["Category": "Popup"])
            } else {
                reminder.setFavorite(true)
                
                // Tracking
                Answers.logCustomEvent(withName: "Favorited", customAttributes: ["Category": "Popup"])
            }
        }
        let coreDataHandler = CoreDataHandler()
        coreDataHandler.setObjectContext(managedObjectContext)
        coreDataHandler.save()
        setFavoriteStar()
    }
    
    @IBAction func close() {
         dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print(#function)
        print(self)
    }
    
    
    // MARK: - Delegate Methods
    
    // MARK: AddReminder
    
    func addReminderViewControllerDidCancel(_ controller: AddReminderViewController) {
        print(#function)
        dismiss(animated: true, completion: nil)
    }
    
    func addReminderViewController(_ controller: AddReminderViewController, didFinishEditingReminder reminder: Reminder) {
        print(#function)
        setLabels(with: reminder)
        if reminder.dueDate.isPresent() {
            snoozeButton.isHidden = true
        } else {
            snoozeButton.isHidden = false
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func addReminderViewControllerDidFinishAdding(_ controller: AddReminderViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func addReminderViewController(_ controller: AddReminderViewController, didChooseToDeleteReminder reminder: Reminder) {
        print(#function)
        dismiss(animated: true, completion: nil)
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            backgroundView.backgroundColor = UIColor.clear
        } else {
            backgroundView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
        }
        updatePopup()
    }
    
    func updatePopup() {
        if let reminder = incomingReminder {
            setLabels(with: reminder)
            setFavoriteStar()
            if reminder.isDue() && reminder.wasCompleted == false {
                snoozeButton.isHidden = false
            } else {
                snoozeButton.isHidden = true
            }
            
            if let comment = reminder.comment {
                commentLabel.isHidden = false
                commentLabel.text = comment
            } else {
                commentLabel.isHidden = true
            }
            
            if reminder.isDue() && reminder.wasCompleted == false {
                popup.backgroundColor = theme.lateColor
                completeButton.backgroundColor = theme.lighterLate
                favoriteButtonBackground.backgroundColor = theme.shinyRed
                editButton.backgroundColor = theme.lightestRed
                deleteButton.backgroundColor = theme.lightLate
                closeButton.backgroundColor = theme.lateColor
                snoozeButton.backgroundColor = theme.lightestRed
            } else {
                popup.backgroundColor = theme.normalColor
                completeButton.backgroundColor = theme.lighterNormal
                favoriteButtonBackground.backgroundColor = theme.shinyNormal
                editButton.backgroundColor = theme.lightestNormal
                deleteButton.backgroundColor = theme.lightNormal
                closeButton.backgroundColor = theme.normalColor
            }
            
            if reminder.wasCompleted == true {
                completeButton.isEnabled = false
                completeButton.setTitle(NSLocalizedString("Completed", comment: "The task has been completed"), for: .disabled)
                completeButton.setTitleColor(UIColor.lightGray, for: .disabled)
            } else {
                completeButton.isEnabled = true
                completeButton.setTitle(NSLocalizedString("Complete", comment: "Complete the task"), for: UIControlState())
                completeButton.setTitleColor(UIColor.white, for: UIControlState())
            }
            
            if reminder.repeats == true {
                repeatIcon.isHidden = false
                repeatLabel.isHidden = false
            } else {
                repeatIcon.isHidden = true
                repeatLabel.isHidden = true
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
        if reminder.usesDayPattern == true {
            updateRepeatLabelWithDayPattern(reminder)
        } else if reminder.usesCustomPattern == true {
            updateRepeatLabelWithCustomPattern(reminder)
        } else {
            repeatLabel.isHidden = true
        }
    }
    
    
    
    func updateRepeatLabelWithCustomPattern(_ reminder: Reminder) {
        if let frequency = reminder.frequency?.intValue, let interval = reminder.interval {
            repeatLabel.text = patternPhrase(frequency: frequency, interval: interval)
        }
    }
    
    func updateRepeatLabelWithDayPattern(_ reminder: Reminder) {
        var selectedDays = [Int]()
        for day in reminder.selectedDays {
            selectedDays.append(Int(day as! NSNumber))
        }
        if selectedDays.count > 0 {
            repeatLabel.text = "every " + listOfSelectedDays(selectedDays: selectedDays)
        }
    }
    
    func setFavoriteStar() {
        if let reminder = incomingReminder {
            if reminder.isFavorite == true {
                let yellowStar = UIImage.init(named: "starYellow100")
                favoriteButton.setImage(yellowStar, for: UIControlState())
            } else {
                let whiteStar = UIImage.init(named: "starWhite100")
                favoriteButton.setImage(whiteStar, for: UIControlState())
            }
        }
    }
    
    // MARK: Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(#function)
        if segue.identifier == "EditReminder" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! AddReminderViewController
            
            controller.delegate = self
            controller.managedObjectContext = managedObjectContext
            controller.reminderToEdit = incomingReminder
        }
    }
}

extension PopupViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                                          presenting: UIViewController?,
                                                          source: UIViewController) -> UIPresentationController? {
        
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension PopupViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
