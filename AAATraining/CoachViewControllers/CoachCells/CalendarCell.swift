//
//  CalendarCell.swift
//  AAATraining
//
//  Created by Margaret Dwan on 9/12/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import UIKit

class CalendarCell: UITableViewCell {
    
    @IBOutlet weak var eventDateView: UIView!
    @IBOutlet weak var eventDayLabel: UILabel!
    @IBOutlet weak var eventMonthLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
