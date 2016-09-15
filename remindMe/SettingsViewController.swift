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
    
    @IBOutlet weak var autoSnoozeEnableLabel: UILabel!
    
    
    var snoozeTime = ""
    var snoozeDuration = 0.0
    var snoozeUnit: SnoozeUnit = .Minutes
    var autoSnoozeTime = ""
    
    var interval = 1
    
    @IBAction func snoozePickerDidPickSnoozeTime(_ segue: UIStoryboardSegue) {
        print(#function)
        let controller = segue.source as! SnoozePickerViewController
        snoozeTime = controller.selectedSnoozeTime
        
        let userDefaults = UserDefaults.standard
        let time = userDefaults.object(forKey: "SnoozeTime") as! String
        
        snoozeTimeLabel.text = time
    }
    
    @IBAction func autoSnoozePickerDidPickAutoSnoozeTime(_ segue: UIStoryboardSegue) {
        print(#function)
        let controller = segue.source as! AutoSnoozePickerViewController
        autoSnoozeTime = controller.selectedAutoSnoozeTime
        
        let userDefaults = UserDefaults.standard
        let time = userDefaults.object(forKey: "AutoSnoozeTime") as! String
        
        autoSnoozeLabel.text = time
    }
    
    @IBAction func setAutoSnoozeFromSwitch() {
        let enabled = autoSnoozeSwitch.isOn
        setAutoSnooze(enabled)
    }
    
    
    override func viewDidLoad() {
        // tableView.backgroundColor = UIColor(red: 47/255, green: 97/255, blue: 127/255, alpha: 1)
        print(#function)
        
        tableView.backgroundColor = UIColor(red: 40/255, green: 108/255, blue: 149/255, alpha: 1)
        tableView.separatorColor = UIColor.white
        
        // Can't change custom cells
        autoSnoozeEnableLabel.textColor = UIColor.white
        autoSnoozeSwitch.onTintColor = UIColor(red: 68/255, green: 140/255, blue: 183/255, alpha: 1)
        autoSnoozeSwitch.tintColor = UIColor(red: 68/255, green: 140/255, blue: 183/255, alpha: 1)
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadSettings()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor(red: 40/255, green: 82/255, blue: 108/255, alpha: 1)
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        // header.titleLabel.textColor = UIColor.whiteColor()
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
        let userDefaults = UserDefaults.standard
        let anAutoSnoozeTime = userDefaults.object(forKey: "AutoSnoozeTime") as! String
        let autoSnoozeOn = userDefaults.bool(forKey: "AutoSnoozeEnabled")
        
        autoSnoozeSwitch.setOn(autoSnoozeOn, animated: false)
        
        autoSnoozeTime = anAutoSnoozeTime
        autoSnoozeLabel.text = "every " + autoSnoozeTime
        
    }
    
    func loadSnoozeSettings() {
        let userDefaults = UserDefaults.standard
        let duration = userDefaults.double(forKey: "SnoozeDuration")
        let unit = userDefaults.object(forKey: "SnoozeUnit") as! String
        let chosenUnit = SnoozeUnit(rawValue: unit)
        
        snoozeUnit = chosenUnit!
        snoozeDuration = duration
        
        let durationString = Int(snoozeDuration)
        let unitString = getLabel(snoozeDuration, snoozeUnit: snoozeUnit)
        snoozeTime = "\(durationString) \(unitString)"
        snoozeTimeLabel.text = "for " + snoozeTime
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case "PickSnoozeTime":
                let controller = segue.destination as! SnoozePickerViewController
                controller.selectedSnoozeTime = snoozeTime
                controller.chosenDuration = snoozeDuration
                controller.chosenUnit = snoozeUnit
                controller.selectedSnoozeTimeTuple = (snoozeDuration, snoozeUnit)
            case "PickAutoSnoozeTime":
                let controller = segue.destination as! AutoSnoozePickerViewController
                controller.selectedAutoSnoozeTime = autoSnoozeTime
            case "SendFeedback":
                let controller = segue.destination as! AboutViewController
                controller.htmlFile = Bundle.main.path(forResource: "feedback", ofType: "html")
                controller.title = "Feedback"
            case "AboutDeveloper":
                let controller = segue.destination as! AboutViewController
                controller.htmlFile = Bundle.main.path(forResource: "aboutDeveloper", ofType: "html")
                controller.title = "About the developer"
            case "AboutApp":
                let controller = segue.destination as! AboutViewController
                controller.htmlFile = Bundle.main.path(forResource: "aboutApp", ofType: "html")
                controller.title = "About the app"
            case "PickTimePickerInterval":
                let controller = segue.destination as! TimePickerViewController
                controller.selectedInterval = interval
            default:
                print("Error: No segue")
            }
            
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func sendSupportEmail() {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.setSubject(NSLocalizedString("Support Request", comment: "Email Subject"))
            controller.setToRecipients(["duane.stoltz@gmail.com"])
            controller.mailComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Can't send email", message: "Please configure your device to send email in Settings -> Mail, Contacts, Calendar. You can also send me a mail at duane.stoltz@gmail.com", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            alert.addAction(cancel)
           

            present(alert, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}

