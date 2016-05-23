//
//  completeButton.swift
//  remindMe
//
//  Created by Duane Stoltz on 13/05/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import UIKit

@IBDesignable

class completeButton: UIButton {

    override func drawRect(rect: CGRect) {
        
        //set up the width and height variables
        //for the horizontal stroke
        let lineHeight: CGFloat = 3.0
        let lineWidth: CGFloat = bounds.width
        
        //create the path
        var plusPath = UIBezierPath()
        
        //set the path's line width to the height of the stroke
        plusPath.lineWidth = lineHeight
        
        //move the initial point of the path
        //to the start of the horizontal stroke
        plusPath.moveToPoint(CGPoint(
            x:0,
            y:0
            )
        )
        
        
        //add a point to the path at the end of the stroke
        plusPath.addLineToPoint(CGPoint(
            x:bounds.width,
            y:0
            )
        )
        
        plusPath.addLineToPoint(CGPoint(
            x:bounds.width,
            y:bounds.height
            )
        )
        
        plusPath.addLineToPoint(CGPoint(
            x:0,
            y:bounds.height
            )
        )
        
        plusPath.addLineToPoint(CGPoint(
            x:0,
            y:0
            )
        )
        
        
        //set the stroke color
        UIColor.cyanColor().setStroke()
        
        //draw the stroke
        plusPath.stroke()
        plusPath.fill()
        
    }
 

}
