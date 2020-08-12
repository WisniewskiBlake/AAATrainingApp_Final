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
    @IBOutlet weak var baselineDateLabel: UILabel!
    
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
        
        self.indexPath = indexPath
           
        self.heightLabel.text = baseline.height
        self.weightLabel.text = baseline.weight
        self.wingspanLabel.text = baseline.wingspan
        self.verticalLabel.text = baseline.vertical
        self.dashLabel.text = baseline.yardDash
        self.agilityLabel.text = baseline.agility
        self.pushUpLabel.text = baseline.pushUp
        self.chinUpLabel.text = baseline.chinUp
        self.mileLabel.text = baseline.mileRun
        self.baselineDateLabel.text = baseline.baselineDate
           
           
           
    }

}
