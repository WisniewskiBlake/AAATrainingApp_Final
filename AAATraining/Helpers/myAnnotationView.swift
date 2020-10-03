//
//  myAnnotationView.swift
//  AAATraining
//
//  Created by Margaret Dwan on 10/2/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import MapKit

class myAnnotationView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet{
            guard let _myAnnotation = newValue as? myAnnotation else {return}
            canShowCallout = true
            calloutOffset = CGPoint(x:-5, y:5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            glyphText = String(_myAnnotation.discipline.first!)
        }
    }
}
