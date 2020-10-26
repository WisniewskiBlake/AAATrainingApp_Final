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
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        teamImageView.layer.cornerRadius = teamImageView.frame.width / 2
//        teamImageView.clipsToBounds = true
        teamImageView.layer.cornerRadius = CGFloat(10.0)

        teamImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
//        borderView.backgroundColor = .white
//        borderView.layer.shadowRadius = CGFloat(4.0)
//        borderView.layer.shadowColor = UIColor.black.cgColor
//        borderView.layer.shadowOffset = CGSize(width: 0, height: 0)
//        borderView.layer.shadowOpacity = 0.4
//        borderView.layer.cornerRadius = CGFloat(15.0)
//        borderView.layer.shadowPath = UIBezierPath(roundedRect: borderView.bounds, cornerRadius: CGFloat(15.0)).cgPath
        //borderView.layer.masksToBounds = false
//        // add shadow on cell
//        backgroundColor = .clear // very important

//
//        // add corner radius on `contentView`
        //contentView.backgroundColor = .clear
       // contentView.layer.cornerRadius = 15
        //contentView.layer.masksToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
//
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
}
