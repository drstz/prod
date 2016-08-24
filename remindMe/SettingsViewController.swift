//
//  SettingsViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 06/06/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UITableViewController {
    @IBOutlet weak var snoozeTimeLabel: UILabel!
    @IBOutlet weak var autoSnoozeLabel: UILabel!
    @IBOutlet weak var timePickerLabel: UILabel!
    
    @IBOutlet weak var autoSnoozeSwitch: UISwitch!
    
    
    var snoozeTime = ""
    var snoozeDuration = 0.0
    var snoozeUnit: SnoozeUnit = .Minutes
    var autoSnoozeTime = ""
    
    var interval = 1
    
    @IBAction func snoozePickerDidPickSnoozeTime(segue: UIStoryboardSegue) {
        print(#function)
        let controller = segue.sourceViewController as! SnoozePickerViewController
        snoozeTime = controller.selectedSnoozeTime
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let time = userDefaults.objectForKey("SnoozeTime") as! String
        
        snoozeTimeLabel.text = time
    }
    
    @IBAction func autoSnoozePickerDidPickAutoSnoozeTime(segue: UIStoryboardSegue) {
        print(#function)
        let controller = segue.sourceViewController as! AutoSnoozePickerViewController
        autoSnoozeTime = controller.selectedAutoSnoozeTime
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let time = userDefaults.objectForKey("AutoSnoozeTime") as! String
        
        autoSnoozeLabel.text = time
    }
    
    @IBAction func setAutoSnoozeFromSwitch() {
        let enabled = autoSnoozeSwitch.on
        setAutoSnooze(enabled)
    }
    
    
    override func viewDidLoad() {
        // tableView.backgroundColor = UIColor(red: 47/255, green: 97/255, blue: 127/255, alpha: 1)
        print(#function)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        loadSettings()
    }
    
    func loadSettings() {
        interval = timePickerInterval()
        var minuteString = ""
        
        if interval == 1 {
            minuteString = "minute"
        } else {
            minuteString = "minutes"
        }
        
        timePickerLabel.text = String(interval) + " " + minuteString
        
        loadSnoozeSettings()
        loadAutoSnoozeSettings()
    }
    
    func loadAutoSnoozeSettings() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let anAutoSnoozeTime = userDefaults.objectForKey("AutoSnoozeTime") as! String
        let autoSnoozeOn = userDefaults.boolForKey("AutoSnoozeEnabled")
        
        autoSnoozeSwitch.setOn(autoSnoozeOn, animated: false)
        
        autoSnoozeTime = anAutoSnoozeTime
        autoSnoozeLabel.text = "every " + autoSnoozeTime
        
    }
    
    func loadSnoozeSettings() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let duration = userDefaults.doubleForKey("SnoozeDuration")
        let unit = userDefaults.objectForKey("SnoozeUnit") as! String
        let chosenUnit = SnoozeUnit(rawValue: unit)
        
        snoozeUnit = chosenUnit!
        snoozeDuration = duration
        
        let durationString = Int(snoozeDuration)
        let unitString = getLabel(snoozeDuration, snoozeUnit: snoozeUnit)
        snoozeTime = "\(durationString) \(unitString)"
        snoozeTimeLabel.text = "for " + snoozeTime
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case "PickSnoozeTime":
                let controller = segue.destinationViewController as! SnoozePickerViewController
                controller.selectedSnoozeTime = snoozeTime
                controller.chosenDuration = snoozeDuration
                controller.chosenUnit = snoozeUnit
                controller.selectedSnoozeTimeTuple = (snoozeDuration, snoozeUnit)
            case "PickAutoSnoozeTime":
                let controller = segue.destinationViewController as! AutoSnoozePickerViewController
                controller.selectedAutoSnoozeTime = autoSnoozeTime
            case "SendFeedback":
                let controller = segue.destinationViewController as! AboutViewController
                controller.htmlFile = NSBundle.mainBundle().pathForResource("feedback", ofType: "html")
                controller.title = "Feedback"
            case "AboutDeveloper":
                let controller = segue.destinationViewController as! AboutViewController
                controller.htmlFile = NSBundle.mainBundle().pathForResource("aboutDeveloper", ofType: "html")
                controller.title = "About the developer"
            case "AboutApp":
                let controller = segue.destinationViewController as! AboutViewController
                controller.htmlFile = NSBundle.mainBundle().pathForResource("aboutApp", ofType: "html")
                controller.title = "About the app"
            case "PickTimePickerInterval":
                let controller = segue.destinationViewController as! TimePickerViewController
                controller.selectedInterval = interval
            default:
                print("Error: No segue")
            }
            
        }
        
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
//    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        let header = view as! UITableViewHeaderFooterView
//        header.textLabel?.textColor = UIColor.whiteColor()
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        print(#function)
//        let cell = tableView.cellForRowAtIndexPath(indexPath)
//        cell?.backgroundColor = UIColor(red: 40/255, green: 83/255, blue: 108/255, alpha: 1)
//        cell?.textLabel?.textColor = UIColor.whiteColor()
//        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
//    }
    
    
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func sendSupportEmail() {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.setSubject(NSLocalizedString("Support Request", comment: "Email Subject"))
            controller.setToRecipients(["duane.stoltz@gmail.com"])
            controller.mailComposeDelegate = self
            self.presentViewController(controller, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Can't send email", message: "Please configure your device to send email in Settings -> Mail, Contacts, Calendar. You can also send me a mail at duane.stoltz@gmail.com", preferredStyle: .Alert)
            let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            
            alert.addAction(cancel)
           

            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

