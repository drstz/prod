//
//  PopupViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 21/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit
import CoreData


class PopupViewController: UIViewController {
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
    
    // MARK: - Core Date
    var managedObjectContext: NSManagedObjectContext!
    
    // MARK: - Properties
    
    var incomingReminder: Reminder?
    
    @IBAction func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func complete() {
        print(#function)
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
        setLabels()
    }
    
    func setLabels() {
        if let reminder = incomingReminder {
            reminderNameLabel.text = reminder.name
            reminderDayLabel.text = convertDateToString(.Day, date: reminder.dueDate)
            reminderDueTimeLabel.text = convertDateToString(.Time, date: reminder.dueDate)
            reminderShortDateLabel.text = convertDateToString(.ShortDate, date: reminder.dueDate)
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

