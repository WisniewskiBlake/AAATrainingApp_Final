//
//  CoachPicCell.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/12/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

protocol CoachPicCellDelegate {
    func didTapMediaImage(indexPath: IndexPath)
}

class CoachPicCell: UITableViewCell {
    
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    @IBOutlet weak var numberComplete: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    
    var indexPath: IndexPath!
    var delegate: CoachPicCellDelegate?
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // rounded corners
       avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
       avaImageView.clipsToBounds = true
        
        tapGestureRecognizer.addTarget(self, action: #selector(self.avatarTap))
        pictureImageView.isUserInteractionEnabled = true
        pictureImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func avatarTap() {
        delegate!.didTapMediaImage(indexPath: indexPath)
    }

}
