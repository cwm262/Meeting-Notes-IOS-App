//
//  CreateAgendaTimerTableViewCell.swift
//  Meeting Notes
//
//  Created by Ben Friedman on 12/10/16.
//  Copyright © 2016 Cody W McCarson. All rights reserved.
//

import UIKit

class CreateAgendaTimerTableViewCell: UITableViewCell {

    @IBOutlet weak var countdownTimer: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
