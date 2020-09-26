//
//  EventCell.swift
//  AAATraining
//
//  Created by Margaret Dwan on 9/25/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventTitleText: UITextField!
    @IBOutlet weak var eventStartText: UITextField!
    @IBOutlet weak var eventEndText: UITextField!
    @IBOutlet weak var eventText: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        var bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: eventStartText.frame.height, width: eventStartText.frame.width, height: 1.0)
        bottomLine.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        eventStartText.borderStyle = UITextField.BorderStyle.none
        eventStartText.layer.addSublayer(bottomLine)
        
        var bottomLine1 = CALayer()
        bottomLine1.frame = CGRect(x: 0.0, y: eventEndText.frame.height, width: eventEndText.frame.width, height: 1.0)
        bottomLine1.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        eventEndText.borderStyle = UITextField.BorderStyle.none
        eventEndText.layer.addSublayer(bottomLine1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
