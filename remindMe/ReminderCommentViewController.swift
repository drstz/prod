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
        
        if previousComment?.characters.count == 0 {
            commentField.text = "Enter a short comment here"
            commentField.selectedRange = NSMakeRange(0, commentField.text.characters.count)
        } else {
            commentField.text = previousComment
        }
        commentField.backgroundColor = UIColor.clearColor()
        commentField.textColor = UIColor.whiteColor()
        
        view.backgroundColor = UIColor(red: 68/255, green: 140/255, blue: 183/255, alpha: 1)
        
    }
}

extension ReminderCommentViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maximumLength = 150
        let currentCharacterCount = textView.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.characters.count - range.length
        let remainingCharacters = maximumLength - newLength
        if remainingCharacters == -1 {
            title = String(maximumLength - newLength + 1) + " " + "characters" + " " + "left"
        } else {
            title = String(maximumLength - newLength) + " " + "characters" + " " + "left"
        }
        
        return newLength <= maximumLength
    }
    
    
}
