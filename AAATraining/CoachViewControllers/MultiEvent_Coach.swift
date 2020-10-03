//
//  MultiEvent_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 9/25/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MultiEvent_Coach: UITableViewController {
    
    var allEventsSameDate: [Event] = []
    var datesForUpcomingComparison: [String] = []
    var dateString: String = ""
    var accountType: String = ""
    var eventsToShow: [Event] = []
    var emptyLabelOne = UILabel()
    
    
    @IBOutlet weak var eventCounterLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var createButton: UIButton!
    
    let geoCoder = CLGeocoder()
    var locationArray: [MKPlacemark] = []
    var doesHaveLocationArray: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loadEvents()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
        loadEvents()
        getLocations()
    }
    
    func configureUI() {
        if self.accountType == "Coach" {
            createButton.isHidden = false
        } else if self.accountType == "Parent" {
            createButton.isHidden = true
        } else if self.accountType == "Player"{
            createButton.isHidden = true
        }
        eventCounterLabel.text = self.dateString
        emptyLabelOne = UILabel(frame: CGRect(x: 0, y: -150, width: view.bounds.size.width, height: view.bounds.size.height))
        titleView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        titleView.alpha = 1.0
        tableView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        //tableView.separatorColor = UIColor.clear
        self.navigationController?.view.addSubview(self.titleView)
        self.navigationController?.navigationBar.layer.zPosition = 0;
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.tableFooterView = view
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fillContentGap:
        if let tableFooterView = tableView.tableFooterView {
            /// The expected height for the footer under autolayout.
            let footerHeight = tableFooterView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            /// The amount of empty space to fill with the footer view.
            let gapHeight: CGFloat = tableView.bounds.height - tableView.adjustedContentInset.top - tableView.adjustedContentInset.bottom - tableView.contentSize.height
            // Ensure there is space to be filled
            guard gapHeight.rounded() > 0 else { break fillContentGap }
            // Fill the gap
            tableFooterView.frame.size.height = gapHeight + footerHeight
        }
    }
    
    @IBAction func createButton_clicked(_ sender: Any) {
        if let eventVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Event_Coach") as? Event_Coach
        {
            eventVC.modalPresentationStyle = .fullScreen
            self.present(eventVC, animated: true, completion: nil)
        }
    }
    
    
    func loadEvents() {
        self.eventsToShow = []
        
        self.doesHaveLocationArray = []
        for event in allEventsSameDate {
            if event.eventUserID == FUser.currentId() {
                eventsToShow.append(event)
            }
        }
    }
    
    func getLocations() {
        self.locationArray = []
        for event in eventsToShow {
            geoCoder.geocodeAddressString(event.eventLocation) { (placemarks, error) in
                if error != nil {
                    print(error)
                }
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first
                else {
                    self.doesHaveLocationArray.append(0)
                    return
                }
                self.doesHaveLocationArray.append(1)
                let mkPlacemark = MKPlacemark(placemark: location)
                self.locationArray.append(mkPlacemark)
                self.tableView.reloadData()
            }
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if eventsToShow.count == 0 {
            
            emptyLabelOne.text = "Created posts will appear here!"
            emptyLabelOne.textAlignment = NSTextAlignment.center
            self.tableView.tableFooterView!.addSubview(emptyLabelOne)
            return 0
        } else {
            emptyLabelOne.text = ""
            emptyLabelOne.removeFromSuperview()
            
            return eventsToShow.count
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        
        cell.eventTitleText.text = eventsToShow[indexPath.row].eventTitle
        cell.eventLocationView.text = eventsToShow[indexPath.row].eventLocation
        cell.eventTimeLabel.text = "From " + eventsToShow[indexPath.row].eventStart + " to " + eventsToShow[indexPath.row].eventEnd
        cell.eventText.text = eventsToShow[indexPath.row].eventText
        if cell.eventText.text != "" {
            cell.placeholderLabel.isHidden = true
        } else {
            cell.placeholderLabel.isHidden = false
        }
        if cell.eventLocationView.text != "" {
            cell.locationPlaceholder.isHidden = true
        } else {
            cell.locationPlaceholder.isHidden = false
        }
        
        if !locationArray.isEmpty {
            cell.eventMapView.removeAnnotations(cell.eventMapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationArray[indexPath.row].coordinate
            
            if let city = locationArray[indexPath.row].locality,
               let state = locationArray[indexPath.row].administrativeArea {
                annotation.subtitle = "(city) (state)"
            }
            
            cell.eventMapView.addAnnotation(annotation)
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: locationArray[indexPath.row].coordinate, span: span)
            cell.eventMapView.setRegion(region, animated: true)
        }
        
        
//        let lat = locationArray[indexPath.row].coordinate.latitude
//        let lon = locationArray[indexPath.row].coordinate.longitude
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = eventsToShow[indexPath.row]
        
        if self.accountType == "Player" {
            if let eventVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerEvent") as? PlayerEvent
            {
                eventVC.hidesBottomBarWhenPushed = true
                eventVC.dateString = event.eventDate
                eventVC.event = event
                eventVC.modalPresentationStyle = .fullScreen
                self.present(eventVC, animated: true, completion: nil)
            }
        } else if self.accountType == "Parent" {
            if let eventVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParentEvent") as? ParentEvent
            {
                eventVC.hidesBottomBarWhenPushed = true
                eventVC.dateString = event.eventDate
                eventVC.event = event
                eventVC.modalPresentationStyle = .fullScreen
                self.present(eventVC, animated: true, completion: nil)
            }
        } else {
            if let eventVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Event_Coach") as? Event_Coach
            {
                eventVC.hidesBottomBarWhenPushed = true
                eventVC.dateString = event.eventDate
                eventVC.updateNeeded = true
                eventVC.event = event
                eventVC.modalPresentationStyle = .fullScreen
                self.present(eventVC, animated: true, completion: nil)
            }
        }
        
        
    }
    
    

    @IBAction func backButtonPressed(_ sender: Any) {
        for event in eventsToShow {
            event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
        }
        //removeListeners()
        dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
