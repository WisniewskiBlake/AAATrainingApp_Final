//
//  TeamCell.swift
//  AAATraining
//
//  Created by Margaret Dwan on 9/16/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import UIKit

class TeamCell: UITableViewCell {

    @IBOutlet weak var teamImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        teamImageView.layer.cornerRadius = teamImageView.frame.width / 2
        teamImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
