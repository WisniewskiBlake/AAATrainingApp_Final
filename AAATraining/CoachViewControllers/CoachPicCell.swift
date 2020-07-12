//
//  CoachPicCell.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/12/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class CoachPicCell: UITableViewCell {
    
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    @IBOutlet weak var numberComplete: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
