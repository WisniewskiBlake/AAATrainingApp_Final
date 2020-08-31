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
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var urlTextView: UITextView!
    
    @IBOutlet weak var numberComplete: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
    
    var indexPath: IndexPath!
    var delegate: CoachPicCellDelegate?
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    let tapGestureRecognizerPic = UITapGestureRecognizer()
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // rounded corners
       avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
       avaImageView.clipsToBounds = true
        
        urlTextView.textContainerInset = .zero
        
        tapGestureRecognizer.addTarget(self, action: #selector(self.mediaTap)) 
        playImageView.isUserInteractionEnabled = true
        playImageView.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizerPic.addTarget(self, action: #selector(self.mediaTap))
        pictureImageView.isUserInteractionEnabled = true
        pictureImageView.addGestureRecognizer(tapGestureRecognizerPic)
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

//        let mScreenSize = UIScreen.main.bounds
//        let mSeparatorHeight = CGFloat(5.0) // Change height of speatator as you want
//        let mAddSeparator = UIView.init(frame: CGRect(x: 0, y: self.frame.size.height, width: mScreenSize.width, height: mSeparatorHeight))
//        mAddSeparator.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) // Change backgroundColor of separator
//        self.addSubview(mAddSeparator)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func mediaTap() {
        delegate!.didTapMediaImage(indexPath: indexPath)
    }

}
