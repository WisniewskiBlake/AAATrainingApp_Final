//
//  EventCell.swift
//  AAATraining
//
//  Created by Margaret Dwan on 9/25/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol EventCellDelegate {
    func didTapLocation(indexPath: IndexPath)
}

class EventCell: UITableViewCell {
    
    //@IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventTitleText: UITextField!
    
    @IBOutlet weak var eventLocationView: UILabel!
    //    @IBOutlet weak var eventLocationView: UITextView!
//    @IBOutlet weak var locationPlaceholder: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var eventText: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var eventMapView: MKMapView!
    var selectedPin: MKPlacemark? = nil
    var delegate: EventCellDelegate?
    var indexPath: IndexPath!
    
    let locTapGestureRecognizer = UITapGestureRecognizer()

    override func awakeFromNib() {
        super.awakeFromNib()

        eventTitleText.isUserInteractionEnabled = false
        eventText.isUserInteractionEnabled = false
        
        locTapGestureRecognizer.addTarget(self, action: #selector(self.goToMap))
        eventLocationView.isUserInteractionEnabled = true
        eventLocationView.addGestureRecognizer(locTapGestureRecognizer)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func goToMap() {
        delegate!.didTapLocation(indexPath: indexPath)
    }
    
    func dropPinZoomIN(placemark: MKPlacemark) {
        selectedPin = placemark
        eventMapView.removeAnnotations(eventMapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        
        if let city = placemark.locality,
           let state = placemark.administrativeArea {
            annotation.subtitle = "(city) (state)"
        }
        
        eventMapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        eventMapView.setRegion(region, animated: true)
    }

}
