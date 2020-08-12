//
//  BaselineCell.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/11/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class BaselineCell: UITableViewCell {
    
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var wingspanLabel: UILabel!
    @IBOutlet weak var verticalLabel: UILabel!
    @IBOutlet weak var dashLabel: UILabel!
    @IBOutlet weak var agilityLabel: UILabel!
    @IBOutlet weak var pushUpLabel: UILabel!
    @IBOutlet weak var chinUpLabel: UILabel!
    @IBOutlet weak var mileLabel: UILabel!
    
    var indexPath: IndexPath!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func generateCellWith(baseline: Baseline, indexPath: IndexPath) {
        let helper = Helper()
        self.indexPath = indexPath
           
        self.fullnameLabel.text = post.postUserName
        self.dateLabel.text = post.date
        self.postTextLabel.text = post.text
        self.dateLabel.text = post.date
        self.dateLabel.text = post.date
        self.dateLabel.text = post.date
        self.dateLabel.text = post.date
        self.dateLabel.text = post.date
        self.dateLabel.text = post.date
           
           
           
    }

}
