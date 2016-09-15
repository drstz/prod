//
//  ReminderCellBackground.swift
//  remindMe
//
//  Created by Duane Stoltz on 16/06/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

class ReminderCellBackground: UIView, ReminderCellBackGroundDelegate {
    var backColor = UIColor.gray {
        didSet {
            backgroundColor = backColor
            layer.backgroundColor  = backColor.cgColor
        }
    }
    
    func changeBackgroundColor(_ color: UIColor) {
        backColor = color
        //print("Changed background color")
        
    }
}
