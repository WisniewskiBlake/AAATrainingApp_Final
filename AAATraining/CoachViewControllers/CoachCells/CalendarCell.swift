//
//  CalendarCell.swift
//  AAATraining
//
//  Created by Margaret Dwan on 9/12/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol CalendarCellDelegate {
    func didTapLocation(indexPath: IndexPath)
}

class CalendarCell: UITableViewCell {
    
    @IBOutlet weak var eventDateView: UIView!
    @IBOutlet weak var eventDayLabel: UILabel!
    @IBOutlet weak var eventMonthLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventLocationText: UILabel!
    
    var delegate: CalendarCellDelegate?
    var indexPath: IndexPath!
    
    let locTapGestureRecognizer = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        eventMonthLabel.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
        locTapGestureRecognizer.addTarget(self, action: #selector(self.goToMap))
        eventLocationText.isUserInteractionEnabled = true
        eventLocationText.addGestureRecognizer(locTapGestureRecognizer)
        
        let width = CGFloat(2)
        let color = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)!.cgColor
        //let color = UIColor.lightGray.cgColor
        let border = CALayer()
        border.borderWidth = width
        border.borderColor = color
        border.frame = CGRect(x: 0, y: 0, width: eventDateView.frame.width, height: eventDateView.frame.height)
        eventDateView.layer.addSublayer(border)
        eventDateView.layer.cornerRadius = 5
        eventDateView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func goToMap() {
        delegate!.didTapLocation(indexPath: indexPath)        
    }

}
