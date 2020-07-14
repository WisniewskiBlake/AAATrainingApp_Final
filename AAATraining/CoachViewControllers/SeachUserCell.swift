//
//  SeachUserCell.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/13/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class SeachUserCell: UITableViewCell {
    
    @IBOutlet weak var coachAvaImage: UIImageView!
    @IBOutlet weak var coachFullNameLabel: UILabel!
    @IBOutlet weak var coachDeleteButton: UIButton!
    
    
    
    @IBOutlet weak var playerAvaImage: UIImageView!
    @IBOutlet weak var playerFullNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // rounded corners
        coachAvaImage.layer.cornerRadius = coachAvaImage.frame.width / 2
        coachAvaImage.clipsToBounds = true
        playerAvaImage.layer.cornerRadius = playerAvaImage.frame.width / 2
        playerAvaImage.clipsToBounds = true
    }

}
