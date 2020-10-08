//
//  PlayerCalendar.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/2/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import FSCalendar
import Firebase
import FirebaseFirestore
import ProgressHUD
import MapKit
import CoreLocation

class PlayerCalendar: UIViewController, FSCalendarDelegate, FSCalendarDelegateAppearance, UITableViewDataSource, UITableViewDelegate, CalendarCellDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var splitterLabelTwo: UILabel!
    
    let geoCoder = CLGeocoder()
    var allEvents: [Event] = []
    var upcomingEvents: [Event] = []
    
    var allCacheEvents: [TeamEventCache] = []
    var upcomingCacheEvents: [TeamEventCache] = []
    var isNewObserverValue: String = "No"
    var updateObserverArray: [String] = []
    var index = 0
    
    var recentListener: ListenerRegistration!
    var allEventDates: [String] = []
    var countArray = [String]()
    
    var eventsToCopy: [Event] = []
    var isNewObserver: Bool = true
    var eventToCopyUserID: String = ""
    var today: String = ""
    
    var eventUserIDs: [String] = []
    
    var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "", teamType: "", teamMemberCount: "", teamMemberAccountTypes: [])
    
    var eventCopied = Event()
    var imageview = UIImageView()
    let helper = Helper()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(loadEvents), name: NSNotification.Name(rawValue: "deleteEvent"), object: nil)

        let todayDate = self.calendar!.today! as Date
        self.calendar.formatter.dateFormat = "YYYY-MM-dd"
        today = calendar.formatter.string(from: todayDate)
        
    }
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            let gif = try UIImage(gifName: "loaderFinal.gif")
            imageview = UIImageView(gifImage: gif, loopCount: -1) // Will loop 3 times
            imageview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageview)
            let widthConstraint = NSLayoutConstraint(item: imageview, attribute: .width, relatedBy: .equal,
                                                     toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 250)

            let heightConstraint = NSLayoutConstraint(item: imageview, attribute: .height, relatedBy: .equal,
                                                      toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 250)

            let xConstraint = NSLayoutConstraint(item: imageview, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)

            let yConstraint = NSLayoutConstraint(item: imageview, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)

            NSLayoutConstraint.activate([widthConstraint, heightConstraint, xConstraint, yConstraint])
        } catch {
            print(error)
        }
        self.imageview.startAnimatingGif()
        
        calendar.delegate = self
        loadUser()
        configureUI()
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.tableFooterView = view
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    func configureUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
        calendar.appearance.todayColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        calendar.appearance.headerTitleColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize:23)
        splitterLabelTwo.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    func loadUser() {

        let query = reference(.User).whereField(kOBJECTID, isEqualTo: FUser.currentId())
                query.getDocuments { (snapshot, error) in
                    
                    self.updateObserverArray = []

                    if error != nil {
                        print(error!.localizedDescription)
                        self.imageview.removeFromSuperview()
                     self.helper.showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
        
                        return
                    }
        
                    guard let snapshot = snapshot else {
                        self.helper.showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        self.imageview.removeFromSuperview();
                        return
                    }
        
                    if !snapshot.isEmpty {
        
                        for userDictionary in snapshot.documents {
        
                            let userDictionary = userDictionary.data() as NSDictionary
                            let user = FUser(_dictionary: userDictionary)
                            
                            let userTeamIDArray = user.userTeamIDs
                            let userIsNewObserverArray = user.userIsNewObserverArray
                            self.index = userTeamIDArray.firstIndex(of: FUser.currentUser()!.userCurrentTeamID)!
                            self.isNewObserverValue = user.userIsNewObserverArray[self.index]
                            self.updateObserverArray = userIsNewObserverArray
                            
                        }
                        if self.isNewObserverValue == "Yes" {
                            self.getEventsForNewObserver()
                            self.updateObserverArray[self.index] = "No"
                            updateUser(userID: FUser.currentId(), withValues: [kUSERISNEWOBSERVERARRAY: self.updateObserverArray])
                        } else {
                            self.loadEvents()
                        }

                    }
                    
                    
                    
                }
     }
    
    func getEventsForNewObserver() {

        let localReference = reference(.Event).document()
        let eventId = localReference.documentID
        var eventToUpload: [String : Any]!
        print(FUser.currentUser()?.userCurrentTeamID)
        
        let query = reference(.TeamEventCache).whereField(kEVENTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID).order(by: kEVENTDATEFORUPCOMINGCOMPARISON)
        query.getDocuments { (snapshot, error) in
            self.allCacheEvents = []
            self.allEventDates = []
            self.upcomingCacheEvents = []
            self.countArray = []
            
            if error != nil {
                 print(error!.localizedDescription)
                self.imageview.removeFromSuperview()
                 self.calendar.reloadData()
                 return
             }
             guard let snapshot = snapshot else { self.imageview.removeFromSuperview(); return }
                    
             if !snapshot.isEmpty {
                 for eventDictionary in snapshot.documents {
                     
                    let eventDictionary = eventDictionary.data() as NSDictionary
                    let event = TeamEventCache(_dictionary: eventDictionary)

                    self.createEventsForNewObserver(event: event)

                }

            }
             self.loadEvents()
        }
    }
    
    func createEventsForNewObserver(event: TeamEventCache) {
        let localReference = reference(.Event).document()
        let eventId = localReference.documentID
        var eventToUpload: [String : Any]!
        let eventCounter = 0
        eventToUpload = [kEVENTID: eventId, kEVENTTEAMID: event.eventTeamID, kEVENTOWNERID: event.eventOwnerID, kEVENTTEXT: event.eventText, kEVENTDATE: event.eventDate, kEVENTACCOUNTTYPE: FUser.currentUser()?.accountType, kEVENTCOUNTER: 0, kEVENTUSERID: FUser.currentId(), kEVENTGROUPID: event.eventGroupID, kEVENTTITLE: event.eventTitle, kEVENTSTART: event.eventStart, kEVENTEND: event.eventEnd, kEVENTDATEFORUPCOMINGCOMPARISON: event.dateForUpcomingComparison, kEVENTLOCATION: event.eventLocation, kEVENTIMAGE: "", kEVENTURL: event.eventURL] as [String:Any]

        localReference.setData(eventToUpload)
    }
    
    @objc func loadEvents() {
        recentListener = reference(.Event).whereField(kEVENTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID).order(by: kEVENTUSERID).order(by: kEVENTDATEFORUPCOMINGCOMPARISON).addSnapshotListener({ (snapshot, error) in
                           
            self.allEvents = []
            self.allEventDates = []
            self.countArray = []
            self.eventsToCopy = []
            self.eventToCopyUserID = ""
            self.upcomingEvents = []
            self.eventUserIDs = []
            self.isNewObserver = true
            

            if error != nil {
                print(error!.localizedDescription)
                self.imageview.removeFromSuperview()
                self.calendar.reloadData()
                return
            }
            guard let snapshot = snapshot else { self.imageview.removeFromSuperview(); return }
                   
            if !snapshot.isEmpty {
                for eventDictionary in snapshot.documents {
                    
                   let eventDictionary = eventDictionary.data() as NSDictionary
                   let event = Event(_dictionary: eventDictionary)
                    

                    self.allEvents.append(event)
//                    print("allEvents.append(event)")
//                    print(event.eventUserID + " 1")
  
                    //if the event that has the same teamID belongs to an existing user, append the date and count
                    if event.eventUserID == FUser.currentId() {
                        //print(event.eventUserID + " 2")
                        //print("event.eventUserID == FUser.currentId()")
                        if event.dateForUpcomingComparison > self.today {
                            self.upcomingEvents.append(event)
                        }
                        self.allEventDates.append(event.eventDate)
                        self.countArray.append(String(event.eventCounter))
                       
                   }
                    
               }
                self.tableView.reloadData()
                self.calendar.reloadData()
                self.imageview.removeFromSuperview()
                
           }
            
            self.tableView.reloadData()
            self.calendar.reloadData()
            self.imageview.removeFromSuperview()
            
        })
    }
    
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        calendar.formatter.dateFormat = "EEEE, MM-dd-YYYY"
        let dateString = calendar.formatter.string(from: date)
        guard let index = allEventDates.firstIndex(of: dateString) else {
            return nil
        }
        
        if allEventDates.contains(dateString) && Int(countArray[index])! >= 1 {
            return UIColor.red
            
        } else if allEventDates.contains(dateString) && Int(countArray[index])! == 0 {
            return UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        }  else {
            return nil
        }
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        calendar.formatter.dateFormat = "EEEE, MM-dd-YYYY"
        let dateString = calendar.formatter.string(from: date)
        let values = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: self.calendar.currentPage)
        //print(dateString)
        if allEventDates.contains(dateString) || date == calendar.today {
            return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else if date.get(.month) != values.month{
            return #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        } else {
            return calendar.appearance.titleDefaultColor
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        calendar.formatter.dateFormat = "EEEE, MM-dd-YYYY"
        let dateString = calendar.formatter.string(from: date)
        
        calendar.formatter.dateFormat = "YYYY-MM-dd"
        let dateForUpcomingComparison = calendar.formatter.string(from: date)
        
        var allEventsSameDate: [Event] = []
        var datesForUpcomingComparison: [String] = []
        
        if let eventVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MultiEvent_Coach") as? MultiEvent_Coach
        {
            for event in allEvents {
                if event.eventDate == dateString {
                    allEventsSameDate.append(event)
                    datesForUpcomingComparison.append(dateForUpcomingComparison)
                }
            }
            eventVC.hidesBottomBarWhenPushed = true
            eventVC.dateString = dateString
            eventVC.allEventsSameDate = allEventsSameDate
            eventVC.datesForUpcomingComparison = datesForUpcomingComparison
            eventVC.accountType = "Player"
            eventVC.modalPresentationStyle = .fullScreen
            self.present(eventVC, animated: true, completion: nil)
        }        
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return upcomingEvents.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        cell.delegate = self
        cell.indexPath = indexPath
        if upcomingEvents[indexPath.row].eventLocation != "" {
            let locationLimited = upcomingEvents[indexPath.row].eventLocation.components(separatedBy: ",")
            if locationLimited.count == 3 {
                cell.eventLocationText.text = String(locationLimited[0]) + " " + String(locationLimited[1]) + " " + String(locationLimited[2])
            } else if locationLimited.count == 2 {
                cell.eventLocationText.text = String(locationLimited[0]) + " " + String(locationLimited[1])
            } else if locationLimited.count == 1 {
                cell.eventLocationText.text = String(locationLimited[0])
            } else {
                cell.eventLocationText.text = String(locationLimited[0])
            }
            
        }
        
        cell.eventTimeLabel?.text = upcomingEvents[indexPath.row].eventStart + " - " + upcomingEvents[indexPath.row].eventEnd + ","
        cell.eventTitleLabel?.text = upcomingEvents[indexPath.row].eventTitle
        let date = upcomingEvents[indexPath.row].dateForUpcomingComparison
        let month = date[5 ..< 7]
        let day = date[8 ..< 10]
        cell.eventDayLabel.text = day
        cell.eventMonthLabel.text = getMonth(monthNumber: month)
        
        cell.accessoryType = .disclosureIndicator


        cell.tag = indexPath.row

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = upcomingEvents[indexPath.row]
        
        if let eventCoach : Event_Coach = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Event_Coach") as? Event_Coach
        {
            eventCoach.hidesBottomBarWhenPushed = true
            eventCoach.dateString = event.eventDate
            eventCoach.event = event
            eventCoach.accountType = "Player"
            eventCoach.modalPresentationStyle = .fullScreen
            self.present(eventCoach, animated: true, completion: nil)
        }
    }
    
    func didTapLocation(indexPath: IndexPath) {
        let helper = Helper()
        geoCoder.geocodeAddressString(upcomingEvents[indexPath.row].eventLocation) { (placemarks, error) in
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
            //mapItem.name = "User's Location"
            mapItem.openInMaps(launchOptions: options)
        }
    }
    
    func getMonth(monthNumber: String) -> String {
        if monthNumber == "01" {
            return "Jan."
        } else if monthNumber == "02" {
            return "Feb."
        } else if monthNumber == "03" {
            return "Mar."
        } else if monthNumber == "04" {
            return "Apr."
        } else if monthNumber == "05" {
            return "May"
        } else if monthNumber == "06" {
            return "June"
        } else if monthNumber == "07" {
            return "July"
        } else if monthNumber == "08" {
            return "Aug."
        } else if monthNumber == "09" {
            return "Sept."
        } else if monthNumber == "10" {
            return "Oct."
        } else if monthNumber == "11" {
            return "Nov."
        } else if monthNumber == "12" {
            return "Dec."
        } else {
            return ""
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        calendar.reloadData()
    }

}
