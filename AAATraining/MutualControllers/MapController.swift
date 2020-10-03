//
//  MapController.swift
//  AAATraining
//
//  Created by Margaret Dwan on 10/2/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import UIKit
import MapKit

class MapController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var selectedPin: MKPlacemark? = nil
    var resultSearchController: UISearchController? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.register(myAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        configureUI()
        let initialLocation = CLLocation(latitude: 1.2835921, longitude: 103.8448966)
        centerMapOnLocation(location: initialLocation)
        
        let locationSearchTable = storyboard!.instantiateViewController(identifier: "MapSearch") as! MapSearch
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable as! UISearchResultsUpdating
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
    }
    
    func configureUI() {
        let _annotation = myAnnotation(title: "Title", locationName: "locationName", discipline: "discipline", coordinate: CLLocationCoordinate2DMake(1.2835921, 103.8448966))
        mapView.addAnnotation(_annotation)
    }
    
    //Helper Functions
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    


}
extension MapController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let _annotation = annotation as? myAnnotation else {return nil}
        let _identifier = "marker"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: _identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: _identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
}
protocol HandleMapSearch {
    func dropPinZoomIN(placemark: MKPlacemark)
}
extension MapController: HandleMapSearch {

    func dropPinZoomIN(placemark: MKPlacemark) {
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        
        if let city = placemark.locality,
           let state = placemark.administrativeArea {
            annotation.subtitle = "(city) (state)"
        }
        resultSearchController?.searchBar.text = placemark.title!
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}
