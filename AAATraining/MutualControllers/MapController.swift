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
    
    var resultSearchController: UISearchController? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.register(myAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        configureUI()
        let initialLocation = CLLocation(latitude: 1.2835921, longitude: 103.8448966)
        centerMapOnLocation(location: initialLocation)
        
        let locationSearchTable = storyboard!.instantiateViewController(identifier: "MapSearch")
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable as! UISearchResultsUpdating
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
    }
    
    func configureUI() {
        let _annotation = myAnnotation(title: "Title", locationName: "locationName", discipline: "discipline", coordinate: CLLocationCoordinate2DMake(1.2835921, 103.8448966)
    }
    
    //Helper Functions
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion.init(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    


}
