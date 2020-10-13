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
import Firebase
import FirebaseFirestore

class MultiEvent_Coach: UITableViewController, EventCellDelegate {
    
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
    
    var selectedPin: MKPlacemark? = nil
    
    var recentListener: ListenerRegistration!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadEvents), name: NSNotification.Name(rawValue: "createEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadEvents), name: NSNotification.Name(rawValue: "updateEvent"), object: nil)
        loadEvents()
        //getLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
        
        
//        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
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
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    @objc func handleRefresh() {
        loadEvents()
        //getLocations()
        self.refreshControl?.endRefreshing()
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
            eventVC.accountType = self.accountType
            eventVC.dateString = self.dateString
            eventVC.sendFromMultiEvent = true
            eventVC.modalPresentationStyle = .fullScreen
            self.present(eventVC, animated: true, completion: nil)
            self.navigationController?.pushViewController(eventVC, animated: true)
        }
        
        
    }
    
    
//    @objc func loadEvents() {
//        self.eventsToShow = []
//        self.doesHaveLocationArray = []
//        for event in allEventsSameDate {
//            if event.eventUserID == FUser.currentId() {
//                eventsToShow.append(event)
//            }
//        }
//    }
    
    @objc func loadEvents() {
        recentListener = reference(.Event).whereField(kEVENTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID).whereField(kEVENTUSERID, isEqualTo: FUser.currentId()).whereField(kEVENTDATE, isEqualTo: self.dateString).order(by: kEVENTSTART).addSnapshotListener({ (snapshot, error) in
                           
            self.eventsToShow = []
            self.doesHaveLocationArray = []

            if error != nil {
                print(error!.localizedDescription)

                return
            }
            guard let snapshot = snapshot else { return }
                   
            if !snapshot.isEmpty {
                for eventDictionary in snapshot.documents {
                    
                   let eventDictionary = eventDictionary.data() as NSDictionary
                   let event = Event(_dictionary: eventDictionary)
                    

                    self.eventsToShow.append(event)
                    //self.getLocations(event: event)
                    
               }
                //self.getLocations()
                self.tableView.reloadData()
                
           }
            //self.getLocations()
            self.tableView.reloadData()
            
        })
    }
    
    func getLocations() {
        //var mkPlacemark = MKPlacemark()
        for event in eventsToShow {
            geoCoder.geocodeAddressString(event.eventLocation) { (placemarks, error) in
                if error != nil {
                    print(error)
                }
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first
                else {
                    self.locationArray.append(MKPlacemark())
                    return
                    
                }
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
            emptyLabelOne.text = "No events to show."
            emptyLabelOne.textAlignment = NSTextAlignment.center
            emptyLabelOne.font = UIFont(name: "Helvetica Neue", size: 15)
            emptyLabelOne.textColor = UIColor.lightGray
            //self.tableView.tableFooterView!.addSubview(emptyLabelOne)
            return 0
        } else {
            emptyLabelOne.text = ""
            emptyLabelOne.removeFromSuperview()
            return eventsToShow.count
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        
        let event = eventsToShow[indexPath.row]
        
        cell.delegate = self
        cell.indexPath = indexPath
        
        cell.eventTitleText.text = eventsToShow[indexPath.row].eventTitle
        if event.eventLocation == "" {
            cell.eventLocationView.text = "No Location"
            cell.eventLocationView.tintColor = UIColor.lightGray
        } else {
            cell.eventLocationView.text = eventsToShow[indexPath.row].eventLocation
        }
        cell.eventTimeLabel.text = "From " + eventsToShow[indexPath.row].eventStart + " to " + eventsToShow[indexPath.row].eventEnd
        cell.eventText.text = eventsToShow[indexPath.row].eventText
        if cell.eventText.text != "" {
            cell.placeholderLabel.isHidden = true
        } else {
            cell.placeholderLabel.isHidden = false
        }
        
        if event.eventLocation != "" {
            
            geoCoder.geocodeAddressString(eventsToShow[indexPath.row].eventLocation) { (placemarks, error) in
                if error != nil {
                    print(error)
                }
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first
                else {
                    return
                }
                let mkPlacemark = MKPlacemark(placemark: location)
                cell.dropPinZoomIN(placemark: mkPlacemark)

            }
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = eventsToShow[indexPath.row]
        

            if let eventVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Event_Coach") as? Event_Coach
            {
                eventVC.accountType = self.accountType
                eventVC.hidesBottomBarWhenPushed = true
                //eventVC.sendFromMultiEvent = true
                eventVC.dateString = event.eventDate
                eventVC.updateNeeded = true
                eventVC.event = event
                eventVC.modalPresentationStyle = .fullScreen
                self.present(eventVC, animated: true, completion: nil)
            }

    }
    
    func didTapLocation(indexPath: IndexPath) {
        let helper = Helper()
        geoCoder.geocodeAddressString(eventsToShow[indexPath.row].eventLocation) { (placemarks, error) in
            if error != nil {
                print(error)
            }
            guard
                let placemarks = placemarks,
                let location = placemarks.first
            else {
                helper.showAlert(title: "Couldn't open in maps.", message: "Not enough info.", in: self)
                return
            }
            
            let mkPlacemark = MKPlacemark(placemark: location)
            let regionDestination: CLLocationDistance = 10000
            
            let coordinates = mkPlacemark.coordinate
            
            let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDestination, longitudinalMeters: regionDestination)

            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan:  regionSpan.span)
            ]
            
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = self.eventsToShow[indexPath.row].eventLocation
            mapItem.openInMaps(launchOptions: options)
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
