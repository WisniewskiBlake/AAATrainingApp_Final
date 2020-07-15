//
//  CoachRosterCell.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/14/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

// Delegate Protocol to be sent to the motherViewControler along with the data (e.g. action, cell)
protocol CoachRosterCellDelegate: class {
    func deleteUserPermanent(from cell: UITableViewCell)
}

class CoachRosterCell: UITableViewCell {

    @IBOutlet weak var coachAvaImage: UIImageView!
    @IBOutlet weak var coachFirstNameLabel: UILabel!
    @IBOutlet weak var coachDeleteButton: UIButton!
    @IBOutlet weak var coachConfirmButton: UIButton!
    
    
    var delegate: CoachRosterCellDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // creating border for delete button
        let border = CALayer()
        border.borderWidth = 1.5
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: 0, width: coachDeleteButton.frame.width, height: coachDeleteButton.frame.height)
        
        // assining border to delete button and making corners rounded
        coachDeleteButton.layer.addSublayer(border)
        coachDeleteButton.layer.cornerRadius = 3
        coachDeleteButton.layer.masksToBounds = true
        
        // rounded corners for confirmButton
        coachConfirmButton.layer.cornerRadius = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // rounded corners
        coachAvaImage.layer.cornerRadius = coachAvaImage.frame.width / 2
        coachAvaImage.clipsToBounds = true
    }
    @IBAction func coachDeleteButton_clicked(_ sender: Any) {
        if(coachConfirmButton.isHidden == true) {
            coachConfirmButton.isHidden = false
        } else if (coachConfirmButton.isHidden == false) {
            coachConfirmButton.isHidden = true
        }
    }
    
//    @IBAction func coachConfirmButton_clicked(_ sender: Any) {
//        let indexPathRow = coachConfirmButton.tag
//        let newvar = CoachRosterVC.deleteUser(_: indexPathRow)
//        delegate?.deleteUserPermanent(from: self)
//    }
    
    
}
