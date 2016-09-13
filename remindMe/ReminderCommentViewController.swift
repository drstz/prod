//
//  ReminderCommentViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 12/09/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

protocol ReminderCommentViewControllerDelegate: class {
    func reminderCommentViewControllerDidCancel(controller: ReminderCommentViewController)
    func reminderCommentViewControllerDidSave(controller: ReminderCommentViewController, comment: String)
}

class ReminderCommentViewController: UIViewController {
    
    var previousComment: String?
    
    weak var delegate: ReminderCommentViewControllerDelegate?
    
    // MARK: Outlets
    
    @IBOutlet weak var commentField: UITextView!
    
    // MARK: Actions
    
    @IBAction func done() {
        commentField.resignFirstResponder()
        
        if commentField.isFirstResponder() == false {
            delegate?.reminderCommentViewControllerDidSave(self, comment: commentField.text)
        }
        
    }
    
    @IBAction func cancel() {
        commentField.resignFirstResponder()
        
        if commentField.isFirstResponder() == false {
            delegate?.reminderCommentViewControllerDidCancel(self)
        }
    }
    
    @IBAction func delete() {
        commentField.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentField.becomeFirstResponder()
        
        if previousComment == nil {
            commentField.text = "Enter extra details here"
        } else {
            commentField.text = previousComment
        }
    }
    
}
