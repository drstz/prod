//
//  ColorManager.swift
//  remindMe
//
//  Created by Duane Stoltz on 19/09/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

struct ColorManager {
    // Normal State
    var color: blueColor
    
    init() {
        color = blueColor()
    }
    
    
    // Late state
    var lateColor = UIColor(red: 149/255, green: 40/255, blue: 54/255, alpha: 1)
    var lightLate = UIColor(red: 169/255, green: 45/255, blue: 61/255, alpha: 1)
    var lighterLate = UIColor(red: 189/255, green: 51/255, blue: 69/255, alpha: 1)
    var lightestRed = UIColor(red: 203/255, green: 62/255, blue: 80/255, alpha: 1)
    var shinyRed = UIColor(red: 208/255, green: 82/255, blue: 98/255, alpha: 1)
}

struct blueColor {
    var normalColor = UIColor(red: 40/255, green: 83/255, blue: 108/255, alpha: 1)
    var lightNormal = UIColor(red: 47/255, green: 97/255, blue: 127/255, alpha: 1)
    var lighterNormal = UIColor(red: 54/255, green: 112/255, blue: 145/255, alpha: 1)
    var lightestNormal = UIColor(red: 61/255, green: 126/255, blue: 164/255, alpha: 1)
    var shinyNormal = UIColor(red: 68/255, green: 140/255, blue: 183/255, alpha: 1)
}
