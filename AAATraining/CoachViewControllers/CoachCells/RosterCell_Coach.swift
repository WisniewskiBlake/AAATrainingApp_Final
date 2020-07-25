//
//  RosterCell_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/23/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

protocol RosterCell_CoachDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}

class RosterCell_Coach: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    var indexPath: IndexPath!
    var delegate: RosterCell_CoachDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tapGestureRecognizer.addTarget(self, action: #selector(self.avatarTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func generateCellWith(fUser: FUser, indexPath: IndexPath) {
        let helper = Helper()
        self.indexPath = indexPath
        
        self.fullNameLabel.text = fUser.firstname + " " + fUser.lastname
        
        if fUser.ava != "" {
            
            helper.imageFromData(pictureData: fUser.ava) { (avatarImage) in
                
                if avatarImage != nil {                    
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
    }
    
    @objc func avatarTap() {
        delegate!.didTapAvatarImage(indexPath: indexPath)
    }

}

