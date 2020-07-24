//
//  RecentChatCell_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/23/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

protocol RecentChatCell_CoachDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}

class RecentChatCell_Coach: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageCounterLabel: UILabel!
    @IBOutlet weak var messageCounterBackground: UIView!
    
    var indexPath: IndexPath!
    
    let tapGesture = UITapGestureRecognizer()
    var delegate: RecentChatCell_CoachDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        messageCounterBackground.layer.cornerRadius = messageCounterBackground.frame.width / 2
        
        tapGesture.addTarget(self, action: #selector(self.avatarTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    
    //MARK: Generate cell
    
    func generateCell(recentChat: NSDictionary, indexPath: IndexPath) {
        
        let helper = Helper()
        
        
        self.indexPath = indexPath
        
        self.nameLabel.text = recentChat[kWITHUSERFULLNAME] as? String
        
        let decryptedText = Encryption.decryptText(chatRoomId: recentChat[kCHATROOMID] as! String, encryptedMessage: recentChat[kLASTMESSAGE] as! String)
        
        self.lastMessageLabel.text = decryptedText
        self.messageCounterLabel.text = recentChat[kCOUNTER] as? String
        
        if let avatarString = recentChat[kAVATAR] {
            helper.imageFromData(pictureData: avatarString as! String) { (avatarImage) in
                
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
        
        if recentChat[kCOUNTER] as! Int != 0 {
            
            self.messageCounterLabel.text = "\(recentChat[kCOUNTER] as! Int)"
            self.messageCounterBackground.isHidden = false
            self.messageCounterLabel.isHidden = false
        } else {
            self.messageCounterBackground.isHidden = true
            self.messageCounterLabel.isHidden = true
        }
        
        var date: Date!
        
        if let created = recentChat[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            } else {
                date = helper.dateFormatter().date(from: created as! String)!
            }
        } else {
            date = Date()
        }
        
        
        self.dateLabel.text = helper.timeElapsed(date: date)
        
    }


    @objc func avatarTap() {
        
        print("avatar tap \(String(describing: indexPath))")
        delegate?.didTapAvatarImage(indexPath: indexPath)
    }

}
