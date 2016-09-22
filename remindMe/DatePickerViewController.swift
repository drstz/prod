//
//  DatePickerViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 24/08/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

protocol DatePickerViewControllerDelegate: class {
    func datePickerViewControllerDidChooseDate(_ controller: DatePickerViewController, date: Date)
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
    var date: Date?
    
    // MARK: Actions
    
    @IBAction func done() {
        let date = datePicker.date.roundSecondsToZero()
        delegate?.datePickerViewControllerDidChooseDate(self, date: date)
    }
    
    @IBAction func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePopup.layer.masksToBounds = true
        datePopup.layer.cornerRadius = 10
        
        doneButton.layer.cornerRadius = 5
        doneButton.layer.borderWidth = 1
        doneButton.layer.borderColor = doneButton.tintColor.cgColor
        doneButton.backgroundColor = UIColor.white
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            backgroundView.backgroundColor = UIColor.clear
        } else {
            backgroundView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
        }
        
        // Update to sent date if one is present
        
        datePicker.minuteInterval = timePickerInterval()
        
        if let date = date {
            datePicker.setDate(date, animated: false)
        } else {
            datePicker.setDate(Date(), animated: false)
        }
    }
    
}

extension DatePickerViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                                          presenting: UIViewController?,
                                                                                   source: UIViewController) -> UIPresentationController? {
        
        return DimmingPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension DatePickerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return (touch.view === self.view)
    }
}
