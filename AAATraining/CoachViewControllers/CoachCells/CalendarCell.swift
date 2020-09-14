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
        
        let width = CGFloat(2)
        let color = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        let border = CALayer()
        border.borderWidth = width
        border.borderColor = color?.cgColor
        border.frame = CGRect(x: 0, y: 0, width: eventDateView.frame.width, height: eventDateView.frame.height)
        eventDateView.layer.addSublayer(border)
        eventDateView.layer.cornerRadius = 5
        eventDateView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
