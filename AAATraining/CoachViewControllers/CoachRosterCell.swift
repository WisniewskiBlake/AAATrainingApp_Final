//
//  CoachRosterCell.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/14/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class CoachRosterCell: UITableViewCell {

    @IBOutlet weak var coachAvaImage: UIImageView!
    @IBOutlet weak var coachFirstNameLabel: UILabel!
    @IBOutlet weak var coachDeleteButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // rounded corners
        coachAvaImage.layer.cornerRadius = coachAvaImage.frame.width / 2
        coachAvaImage.clipsToBounds = true
    }

}
