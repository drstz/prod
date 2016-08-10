//
//  TableSectionHeader.swift
//  remindMe
//
//  Created by Duane Stoltz on 13/07/2016.
//  Copyright © 2016 Duane Stoltz. All rights reserved.
//

import Foundation
import UIKit

class TableSectionHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
//        print(#function)
        super.awakeFromNib()
    
        titleLabel.layer.cornerRadius = 3
        titleLabel.layer.masksToBounds = true
        // titleLabel.backgroundColor = UIColor(red: 40/255, green: 114/255, blue: 192/255, alpha: 1)
        
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textColor = UIColor.whiteColor()
        
        
        
    }
}
