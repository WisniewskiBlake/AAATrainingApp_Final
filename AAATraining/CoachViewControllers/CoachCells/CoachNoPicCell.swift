//
//  CoachNoPicCell.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/12/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class CoachNoPicCell: UITableViewCell {

    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var numberCompleted: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    
    
    var indexPath: IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // rounded corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func generateCellWith(post: Post, indexPath: IndexPath) {
        let helper = Helper()
        self.indexPath = indexPath
        
        self.fullnameLabel.text = post.postUserName
        self.dateLabel.text = post.date
        self.postTextLabel.text = post.text
        
        if post.postUserAva != "" {
            
            helper.imageFromData(pictureData: post.postUserAva) { (avatarImage) in
                
                if avatarImage != nil {
                    self.avaImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
    }

}
