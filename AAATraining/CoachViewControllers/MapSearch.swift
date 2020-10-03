//
//  MapSearch.swift
//  AAATraining
//
//  Created by Margaret Dwan on 10/2/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import UIKit
import MapKit

class MapSearch: UITableViewController {
    
    var matchingItems : [MKMapItem] = []
    var mapView : MKMapView? = nil
    var handleMapSearchDelegate : HandleMapSearch? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func parseAddress(selectedItem: MKPlacemark) -> String {
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " ": ""
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", ": ""
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " ": ""
        let addressLine = String(
            format: "%@%@%@%@%@%@%@",
            //street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            //street name
            selectedItem.thoroughfare ?? "",
            comma,
            //city
            selectedItem.locality ?? "",
            secondSpace,
            //state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locCell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIN(placemark: selectedItem)
        
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }

    
}
extension MapSearch : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView, let searchBarText = searchController.searchBar.text else {return}
        let request = MKLocalSearch.Request()

        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region

        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            guard let response = response else {return}
            self.matchingItems = response.mapItems
            self.tableView.reloadData()

        }
    }
}

extension MapSearch {
    
}
