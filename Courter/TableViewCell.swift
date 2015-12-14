//
//  TableViewCell.swift
//  Courter
//
//  Created by n3turn on 10/24/15.
//  Copyright © 2015 Zhihao Tang. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var gameTitleLabel: UILabel!
    @IBOutlet weak var gameOwnerLabel: UILabel!
    @IBOutlet weak var fractionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
