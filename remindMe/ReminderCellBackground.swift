//
//  ReminderCellBackground.swift
//  remindMe
//
//  Created by Duane Stoltz on 16/06/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

class ReminderCellBackground: UIView, ReminderCellBackGroundDelegate {
    var backColor = UIColor.grayColor() {
        didSet {
            backgroundColor = backColor
            layer.backgroundColor  = backColor.CGColor
        }
    }
    
    func changeBackgroundColor(color: UIColor) {
        backColor = color
        //print("Changed background color")
        
    }
}
