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
    
    var snoozeTime = ""
    
    @IBAction func snoozePickerDidPickSnoozeTime(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! SnoozePickerViewController
        snoozeTime = controller.selectedSnoozeTime
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let time = userDefaults.objectForKey("SnoozeTime") as! String
        
        snoozeTimeLabel.text = time
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let time = userDefaults.objectForKey("SnoozeTime") as! String
        snoozeTime = time
        snoozeTimeLabel.text = snoozeTime
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickSnoozeTime" {
            let controller = segue.destinationViewController as! SnoozePickerViewController
            controller.selectedSnoozeTime = snoozeTime
        }
    }
}
