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
    
    // MARK: Buttons
    
    @IBOutlet weak var snoozeButton: UIButton!
    
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    // MARK: - Delegates
    
    weak var delegate: PopupViewControllerDelegate?
    
    // MARK: - Core Date
    var managedObjectContext: NSManagedObjectContext!
    
    // MARK: - Properties
    
    var incomingReminder: Reminder?
    
    
    @IBAction func complete() {
        delegate?.popupViewControllerDidComplete(self, reminder: incomingReminder!)
    }
    
    @IBAction func snooze() {
        delegate?.popupViewControllerDidSnooze(self, reminder: incomingReminder!)
    }
    
    @IBAction func delete() {
        delegate?.popupViewControllerDidDelete(self, reminder: incomingReminder!)

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
    
    @IBAction func edit() {

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
        super.viewDidLoad()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func addReminderViewController(controller: AddReminderViewController, didFinishAddingReminder reminder: Reminder) {
        print(#function)
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
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            backgroundView.backgroundColor = UIColor.clearColor()
        } else {
            backgroundView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.8)
        }
        if let reminder = incomingReminder {
            setLabels(with: reminder)
            setFavoriteStar()
        }
        
    }
    
    func setLabels(with reminder: Reminder) {
        reminderNameLabel.text = reminder.name
        reminderDayLabel.text = convertDateToString(.Day, date: reminder.dueDate)
        reminderDueTimeLabel.text = convertDateToString(.Time, date: reminder.dueDate)
        reminderShortDateLabel.text = convertDateToString(.ShortDate, date: reminder.dueDate)
    }
    
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
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

