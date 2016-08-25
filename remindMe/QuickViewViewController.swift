//
//  quickViewViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 13/05/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

//import UIKit
//import CoreData
//
//protocol QuickViewViewControllerDelegate: class {
//    func quickViewViewControllerDidCancel(controller: QuickViewViewController)
//    func quickViewViewControllerDidDelete(controller: QuickViewViewController,
//                                          didDeleteReminder reminder: Reminder)
//    func quickViewViewControllerDidComplete(controller: QuickViewViewController,
//                                            didCompleteReminder reminder: Reminder)
//    func quickViewViewControllerDidSnooze(controller: QuickViewViewController,
//                                          didSnoozeReminder reminder: Reminder)
//}
//
//class QuickViewViewController: UIViewController, AddReminderViewControllerDelegate, AllRemindersViewControllerDelegate {
//    
//    // MARK: - Outlets
//    
//    // MARK: Labels
//    
//    @IBOutlet weak var reminderNameLabel: UILabel!
//    @IBOutlet weak var reminderDueDateLabel: UILabel!
//    @IBOutlet weak var reminderDueTimeLabel: UILabel!
//    @IBOutlet weak var reminderShortDateLabel: UILabel!
//    
//    // MARK: Buttons
//    
//    @IBOutlet weak var completeButton: UIButton!
//    @IBOutlet weak var deleteButton: UIButton!
//    
//    @IBOutlet weak var snoozeButton: UIButton!
//    
//    @IBOutlet weak var addToFavoritesButton: UIBarButtonItem!
//    
//    @IBOutlet weak var favoriteStar: UIImageView!
//    
//    // MARK: - Delegates
//    
//    weak var delegate: QuickViewViewControllerDelegate?
//    
//    // MARK: - Core Date
//    var managedObjectContext: NSManagedObjectContext!
//    
//    // MARK: - Properties
//    
//    var incomingReminder: Reminder?
//    
//    var notifiedReminder: Reminder? {
//        didSet {
//            print("QuickView Controller now has the notified reminder")
//        }
//    }
//    
//    var willSetNewDate = false
//    
//    var notificationHasGoneOff = false
//    
//    // MARK: - Actions
//    
//    // Bar Buttons 
//    
//    @IBAction func cancel() {
//        delegate?.quickViewViewControllerDidCancel(self)
//    }
//    
//    // Bottom Buttons
//    
//    @IBAction func completeReminder() {
//        if let reminder = incomingReminder {
//            if reminder.isComplete == true {
//                willSetNewDate = true
//                performSegueWithIdentifier("EditReminder", sender: nil)
//            } else {
//                delegate?.quickViewViewControllerDidComplete(self, didCompleteReminder: reminder)
//            }
//        }
//    }
//    
//    @IBAction func snoozeReminder() {
//        delegate?.quickViewViewControllerDidSnooze(self, didSnoozeReminder: incomingReminder!)
//    }
//    
//    @IBAction func deleteReminder() {
//        delegate?.quickViewViewControllerDidDelete(self, didDeleteReminder: incomingReminder!)
//    }
//    
//    func favoriteReminder() {
//        if let reminder = incomingReminder {
//            if reminder.isFavorite == true {
//                reminder.setFavorite(false)
//            } else {
//                reminder.setFavorite(true)
//            }
//        }
//        let coreDataHandler = CoreDataHandler()
//        coreDataHandler.setObjectContext(managedObjectContext)
//        coreDataHandler.save()
//        setFavoriteStar()
//        
//    }
//    
//    func setFavoriteStar() {
//        if let reminder = incomingReminder {
//            if reminder.isFavorite == true {
//                favoriteStar.image = UIImage.init(named: "Star Filled-44 (1).png")
//            } else {
//                favoriteStar.image = UIImage.init(named: "Star Filled-44.png")
//            }
//        }
//    }
//    
//    // MARK: - Delegate Methods
//    
//    // MARK: AddReminder
//    
//    func addReminderViewControllerDidCancel(controller: AddReminderViewController) {
//        print(#function)
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func addReminderViewController(controller: AddReminderViewController, didFinishEditingReminder reminder: Reminder) {
//        print(#function)
//        updateLabels(with: reminder)
//        setCompleteButton(with: reminder)
//        super.viewDidLoad()
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func addReminderViewController(controller: AddReminderViewController, didFinishAddingReminder reminder: Reminder) {
//        print(#function)
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func addReminderViewController(controller: AddReminderViewController, didChooseToDeleteReminder reminder: Reminder) {
//        print(#function)
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//    // MARK: AllReminder
//    
//    func allRemindersViewControllerDelegateDidReceiveNotification(controller: AllRemindersViewController, reminder: Reminder) {
//        print("Quick View is recieving notification")
//        
//    }
//    
//    // MARK: - Methods
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        snoozeButton.layer.cornerRadius = 10
//        
//        if let reminder = incomingReminder {
//            updateLabels(with: reminder)
//            setCompleteButton(with: reminder)
//            
//            if reminder.isDue() {
//                snoozeButton.hidden = false
//            }
//            
//        }
//        setFavoriteStar()
//        
//    }
//    
//    override func viewDidLoad() {
//        print(#function)
//        super.viewDidLoad()
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(favoriteReminder))
//        favoriteStar.addGestureRecognizer(tapGesture)
//        
//        
//        
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        print(#function)
//        super.viewDidAppear(animated)
//    }
//    
//    func updateLabels(with reminder: Reminder) {
//        reminderNameLabel.text = reminder.name
//        reminderDueDateLabel.text = convertDateToString(.Day, date: reminder.dueDate)
//        reminderDueTimeLabel.text = convertDateToString(.Time, date: reminder.dueDate)
//        reminderShortDateLabel.text = convertDateToString(.ShortDate, date: reminder.dueDate)
//        
//    }
//    
//    func setCompleteButton(with reminder: Reminder) {
//        var newTitle = ""
//        if reminder.isComplete == true {
//            newTitle = "Set new date"
//        } else {
//            newTitle = "Complete"
//        }
//       completeButton.setTitle(newTitle, forState: .Normal)
//    }
//    
//    // MARK: Segues
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "EditReminder" {
//            let navigationController = segue.destinationViewController as! UINavigationController
//            let controller = navigationController.topViewController as! AddReminderViewController
//            
//            controller.delegate = self
//            controller.managedObjectContext = managedObjectContext
//            controller.reminderToEdit = incomingReminder
//            
//            if willSetNewDate {
//                controller.willSetNewDate = willSetNewDate
//            }
//        }
//    }
//}
