//
//  PlayerRosterCell.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/15/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

// Delegate Protocol to be sent to the motherViewControler along with the data (e.g. action, cell)
protocol PlayerRosterCellDelegate: class {
    func deleteUserPermanent(from cell: UITableViewCell)
}

class PlayerRosterCell: UITableViewCell {

    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    var delegate: PlayerRosterCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // rounded corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
    }
    

}
