//
//  SettingsViewController.swift
//  remindMe
//
//  Created by Duane Stoltz on 06/06/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var snoozeTimeLabel: UILabel!
    @IBOutlet weak var autoSnoozeLabel: UILabel!
    
    @IBOutlet weak var autoSnoozeSwitch: UISwitch!
    
    var snoozeTime = ""
    var autoSnoozeTime = ""
    
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
        print(#function)
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let time = userDefaults.objectForKey("SnoozeTime") as! String
        let anAutoSnoozeTime = userDefaults.objectForKey("AutoSnoozeTime") as! String
        let autoSnoozeOn = userDefaults.boolForKey("AutoSnoozeEnabled")
        print(autoSnoozeOn)
        
        autoSnoozeSwitch.setOn(autoSnoozeOn, animated: false)
        snoozeTime = time
        autoSnoozeTime = anAutoSnoozeTime
        print(anAutoSnoozeTime)
        autoSnoozeLabel.text = "every " + autoSnoozeTime
        snoozeTimeLabel.text = "for " + snoozeTime
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print(#function)
        if segue.identifier == "PickSnoozeTime" {
            let controller = segue.destinationViewController as! SnoozePickerViewController
            controller.selectedSnoozeTime = snoozeTime
        } else if segue.identifier == "PickAutoSnoozeTime" {
            let controller = segue.destinationViewController as! AutoSnoozePickerViewController
            controller.selectedAutoSnoozeTime = autoSnoozeTime
        }
    }
}

