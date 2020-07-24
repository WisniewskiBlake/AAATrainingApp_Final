//
//  GroupMemberCell_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/24/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

protocol GroupMemberCell_CoachDelegate {
    func didClickDeleteButton(indexPath: IndexPath)
}

class GroupMemberCell_Coach: UICollectionViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    let helper = Helper()
    
    var indexPath: IndexPath!
    var delegate: GroupMemberCell_CoachDelegate?
    
    func generateCell(user: FUser, indexPath: IndexPath) {
        
        self.indexPath = indexPath
        nameLabel.text = user.firstname
        
        if user.ava != "" {
            
            helper.imageFromData(pictureData: user.ava) { (avatarImage) in
                
                if avatarImage != nil {
                    
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
        
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegate!.didClickDeleteButton(indexPath: indexPath)
    }
    
}
