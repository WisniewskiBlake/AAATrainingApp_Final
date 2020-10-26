//
//  ParentCalendarVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/3/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import FSCalendar
import Firebase
import FirebaseFirestore
import ProgressHUD
import MapKit
import CoreLocation
import GoogleMobileAds

class ParentCalendarVC: UIViewController, FSCalendarDelegate, FSCalendarDelegateAppearance, UITableViewDataSource, UITableViewDelegate, CalendarCellDelegate {

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
    
    let logoutTapGestureRecognizer = UITapGestureRecognizer()
    var imageview = UIImageView()
    let helper = Helper()
    
    @IBOutlet weak var teamImageView: UIImageView!
    @IBOutlet weak var navView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBadges(controller: self.tabBarController!, accountType: "coach")
        setCalendarBadges(controller: self.tabBarController!, accountType: "parent")

        NotificationCenter.default.addObserver(self, selector: #selector(loadEvents), name: NSNotification.Name(rawValue: "deleteEvent"), object: nil)
        
        calendar.delegate = self
        
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
        team.getTeam(teamID: FUser.currentUser()!.userCurrentTeamID) { (teamReturned) in
            if teamReturned.teamID != "" {
                self.team = teamReturned
                if self.team.teamLogo != "" {
                    self.helper.imageFromData(pictureData: self.team.teamLogo) { (coverImage) in

                        if coverImage != nil {
                            self.teamImageView.image = coverImage?.circleMasked
                        }
                    }
                } else {
                    self.teamImageView.image = UIImage(named: "HomeCover.jpg")
                    
                }
            } else {
                self.teamImageView.image = UIImage(named: "HomeCover.jpg")
            }
        }
        teamImageView.layer.cornerRadius = teamImageView.frame.width / 2
        teamImageView.clipsToBounds = true
        teamImageView.layer.masksToBounds = true
        navView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
        calendar.appearance.todayColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        calendar.appearance.headerTitleColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize:23)
        self.setLeftAlignedNavigationItemTitle(text: "Team Calendar", color: .white, margin: 12)
        //splitterLabelTwo.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
            eventVC.accountType = "Parent"
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
        
        cell.eventTimeLabel?.text = upcomingEvents[indexPath.row].eventStart + " - " + upcomingEvents[indexPath.row].eventEnd
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
            eventCoach.accountType = "Parent"
            eventCoach.modalPresentationStyle = .fullScreen
            self.present(eventCoach, animated: true, completion: nil)
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
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        calendar.reloadData()
    }
    @IBAction func logoutViewClicked(_ sender: Any) {
        if let vc =  UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsNav") as? UINavigationController
        {
            vc.modalPresentationStyle = .fullScreen
            vc.navigationController?.navigationBar.tintColor = UIColor.black
            vc.navigationBar.tintColor = UIColor.black
            
            self.present(vc, animated: true, completion: nil)
        }
//        let sheet = UIAlertController(title: "Team Login Code: " + FUser.currentUser()!.userCurrentTeamID, message: nil, preferredStyle: .actionSheet)
//
//
//
//        let colorPicker = UIAlertAction(title: "Choose App Color Theme", style: .default, handler: { (action) in
//
//
//            let navigationColorPicker = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColorPickerNav") as! UINavigationController
//             //let colorPickerVC = navigationColorPicker.viewControllers.first as! ColorPickerVC
//
//
//            self.present(navigationColorPicker, animated: true, completion: nil)
//
//
//        })
//
//        let backToTeamSelect = UIAlertAction(title: "Back To Team Select", style: .default, handler: { (action) in
//
//            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamSelectionVC") as? TeamSelectionVC
//            {
//                vc.modalPresentationStyle = .fullScreen
//                self.present(vc, animated: true, completion: nil)
//            }
//
//
//        })
//
//        // creating buttons for action sheet
//        let logout = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) in
//
//            FUser.logOutCurrentUser { (success) in
//
//                if success {
//                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
//                    {
//                        vc.modalPresentationStyle = .fullScreen
//                        self.present(vc, animated: true, completion: nil)
//                    }
//                }
//            }
//        })
//
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//        // add buttons to action sheet
//
//        sheet.addAction(colorPicker)
//        sheet.addAction(backToTeamSelect)
//        sheet.addAction(logout)
//        sheet.addAction(cancel)
//
//        // show action sheet
//        present(sheet, animated: true, completion: nil)
    }
    
    
}

