//
//  bookingTableViewCell.swift
//  Courter
//
//  Created by Xinyu Chen on 12/8/15.
//  Copyright © 2015 Zhihao Tang. All rights reserved.
//

import UIKit

class bookingTableViewCell: UITableViewCell {
    
    @IBOutlet var time: UILabel!
    @IBOutlet var court3: UILabel!
    @IBOutlet var court2: UILabel!
    @IBOutlet var court1: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
