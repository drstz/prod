//
//  DatePickerViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 24/08/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

protocol DatePickerViewControllerDelegate: class {
    func datePickerViewControllerDidChooseDate(controller: DatePickerViewController, date: NSDate)
}

class DatePickerViewController: UIViewController {
    @IBOutlet weak var datePopup: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    // MARK: Datepicker
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // MARK: Buttons
    
    @IBOutlet weak var doneButton: UIButton!
    
    // MARK: - Delegates
    
    weak var delegate: DatePickerViewControllerDelegate?
    
    // MARK: - Date
    var date: NSDate?
    
    // MARK: Actions
    
    @IBAction func done() {
        delegate?.datePickerViewControllerDidChooseDate(self, date: datePicker.date)
    }
    
    @IBAction func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePopup.layer.masksToBounds = true
        datePopup.layer.cornerRadius = 10
        
        doneButton.layer.cornerRadius = 5
        doneButton.layer.borderWidth = 1
        doneButton.layer.borderColor = doneButton.tintColor.CGColor
        doneButton.backgroundColor = UIColor.whiteColor()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            backgroundView.backgroundColor = UIColor.clearColor()
        } else {
            backgroundView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
        }
        
        // Update to sent date if one is present
        
        datePicker.minuteInterval = timePickerInterval()
        
        if let date = date {
            datePicker.setDate(date, animated: false)
        } else {
            datePicker.setDate(NSDate(), animated: false)
        }
    }
    
}

extension DatePickerViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController,
                                                          presentingViewController presenting: UIViewController,
                                                                                   sourceViewController source: UIViewController) -> UIPresentationController? {
        
        return DimmingPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}

extension DatePickerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}