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

class ParentCalendarVC: UIViewController, FSCalendarDelegate, FSCalendarDelegateAppearance, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var upcomingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var splitterLabel: UILabel!
    @IBOutlet weak var splitterLabelTwo: UILabel!
    
    var allEvents: [Event] = []
    var upcomingEvents: [Event] = []
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBadges(controller: self.tabBarController!, accountType: "coach")
        setCalendarBadges(controller: self.tabBarController!, accountType: "parent")

        NotificationCenter.default.addObserver(self, selector: #selector(loadEvents), name: NSNotification.Name(rawValue: "deleteEvent"), object: nil)
        
        calendar.delegate = self
        
        let todayDate = self.calendar!.today! as Date
        self.calendar.formatter.dateFormat = "YYYY-MM-dd"
        today = calendar.formatter.string(from: todayDate)
        
        logoutTapGestureRecognizer.addTarget(self, action: #selector(self.logoutViewClicked))
        logoutView.isUserInteractionEnabled = true
        logoutView.addGestureRecognizer(logoutTapGestureRecognizer)
        
        
        
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
        loadEvents()
        configureUI()

    }
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    func configureUI() {
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        calendar.appearance.todayColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        calendar.appearance.headerTitleColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize:23)
        self.setLeftAlignedNavigationItemTitle(text: "Team Calendar", color: .white, margin: 12)
        upcomingLabel.textColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        logoutView.tintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        splitterLabel.backgroundColor = #colorLiteral(red: 0.6815950428, green: 0.6815950428, blue: 0.6815950428, alpha: 1)
        splitterLabelTwo.backgroundColor = #colorLiteral(red: 0.6815950428, green: 0.6815950428, blue: 0.6815950428, alpha: 1)
    }
    

    
    @objc func loadEvents() {
        print("loadEvents")
        GIFHUD.shared.show(withOverlay: true)
        recentListener = reference(.Event).whereField(kEVENTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID).order(by: kEVENTUSERID).order(by: kEVENTDATEFORUPCOMINGCOMPARISON).addSnapshotListener({ (snapshot, error) in
                           
            self.allEvents = []
            self.allEventDates = []
            self.countArray = []
            self.eventsToCopy = []
            self.eventToCopyUserID = ""
            self.upcomingEvents = []
            self.eventUserIDs = []
            self.isNewObserver = true
            
            var i = 0
            var k = 0
            if error != nil {
                print(error!.localizedDescription)
                GIFHUD.shared.dismiss()
                self.calendar.reloadData()
                return
            }
            guard let snapshot = snapshot else { GIFHUD.shared.dismiss(); return }
                   
            if !snapshot.isEmpty {
                for eventDictionary in snapshot.documents {
                    
                   let eventDictionary = eventDictionary.data() as NSDictionary
                   let event = Event(_dictionary: eventDictionary)
                    
                    if event.dateForUpcomingComparison > self.today && event.eventUserID == FUser.currentId() {
                        self.upcomingEvents.append(event)
                    }
                    
                    //if the user and event grabbed have same teamID, append it to all events
                    if event.eventTeamID == FUser.currentUser()?.userCurrentTeamID {
                        self.allEvents.append(event)
                        print("allEvents.append(event)")
                        print(event.eventUserID + " 1")
                        i += 1
                        //if the event that has the same teamID belongs to an existing user, append the date and count
                        if event.eventUserID == FUser.currentId() {
                            print(event.eventUserID + " 2")
                            //print("event.eventUserID == FUser.currentId()")
                            self.allEventDates.append(event.eventDate)
                            self.countArray.append(String(event.eventCounter))
                            self.isNewObserver = false
                       } else {
                            //else if the first event grabbed does not belong to an existing user, then append it to eventsToCopy
                            if i == 1 {
                                self.eventsToCopy.append(event)
                                self.eventToCopyUserID = event.eventUserID
                            } else if i > 1 {
                                if self.eventToCopyUserID == event.eventUserID {
                                    self.eventsToCopy.append(event)
                                }
                            }
                            if !self.eventUserIDs.contains(event.eventUserID) {
                                self.eventUserIDs.append(event.eventUserID)
                            }
                       }
                    }
               }
                self.checkForNewObserver()
                k += 1
                print("k " + String(k))
           }
            
            print("x " + String(self.allEvents.count))
            
                
           self.tableView.reloadData()
           self.calendar.reloadData()
            
            GIFHUD.shared.dismiss()
        })
    }
    
    func checkForNewObserver() {
        let helper = Helper()
        print("check For New Observer")
        
        if self.isNewObserver {
            if self.eventsToCopy.count * self.eventUserIDs.count == self.allEvents.count && !(self.eventUserIDs.contains(FUser.currentId())) {
                
                for event in self.eventsToCopy {
                    print("create Events For New Observer")
                    if !(event.eventOwnerID == FUser.currentId()) && event.eventDate != eventCopied.eventDate {
                        eventCopied = event
                        self.createEventsForNewObserver(event: event)
                    }
                    
                    
                }
                self.tableView.reloadData()
                self.calendar.reloadData()
                
            } else {
                
                self.tableView.reloadData()
                self.calendar.reloadData()
            }
        }
        
        
        self.tableView.reloadData()
        self.calendar.reloadData()

    }
    
    func createEventsForNewObserver(event: Event) {
        let localReference = reference(.Event).document()
        let eventId = localReference.documentID
        var eventToUpload: [String : Any]!
        let eventCounter = 0
        eventToUpload = [kEVENTID: eventId, kEVENTTEAMID: event.eventTeamID, kEVENTOWNERID: event.eventOwnerID, kEVENTTEXT: event.eventText, kEVENTDATE: event.eventDate, kEVENTACCOUNTTYPE: FUser.currentUser()?.accountType, kEVENTCOUNTER: eventCounter, kEVENTUSERID: FUser.currentId(), kEVENTGROUPID: event.eventGroupID, kEVENTTITLE: event.eventTitle, kEVENTSTART: event.eventStart, kEVENTEND: event.eventEnd, kEVENTDATEFORUPCOMINGCOMPARISON: event.dateForUpcomingComparison] as [String:Any]

        localReference.setData(eventToUpload)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        calendar.formatter.dateFormat = "EEEE, MM-dd-YYYY"
        let dateString = calendar.formatter.string(from: date)
        guard let index = allEventDates.firstIndex(of: dateString) else {
            return nil
        }
        
        if allEventDates.contains(dateString) && Int(countArray[index])! >= 1 {
            return #colorLiteral(red: 0.05476168428, green: 0.06671469682, blue: 1, alpha: 1)
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
        
        let eventVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParentEvent") as! ParentEvent
        let navController = UINavigationController(rootViewController: eventVC)
        
        for event in allEvents {
            if event.eventDate == dateString {                
                eventVC.event = event
                
            } else {
                eventVC.eventText = ""
            }
        }
        
        eventVC.hidesBottomBarWhenPushed = true
        eventVC.dateString = dateString
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return upcomingEvents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        
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
        
        let eventVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParentEvent") as! ParentEvent
        let navController = UINavigationController(rootViewController: eventVC)
        
        eventVC.event = event
        
        eventVC.hidesBottomBarWhenPushed = true
        eventVC.dateString = event.eventDate
        
        self.navigationController?.present(navController, animated: true, completion: nil)
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
    
    @objc func logoutViewClicked() {
        let sheet = UIAlertController(title: "Team Login Code: " + FUser.currentUser()!.userCurrentTeamID, message: nil, preferredStyle: .actionSheet)
        
        
        
        let colorPicker = UIAlertAction(title: "Choose App Color Theme", style: .default, handler: { (action) in
                        
            
            let navigationColorPicker = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColorPickerNav") as! UINavigationController
             //let colorPickerVC = navigationColorPicker.viewControllers.first as! ColorPickerVC
            
            
            self.present(navigationColorPicker, animated: true, completion: nil)
                
            
        })
        
        // creating buttons for action sheet
        let logout = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) in
                        
            FUser.logOutCurrentUser { (success) in
                
                if success {
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                    {
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // add buttons to action sheet
        
        sheet.addAction(colorPicker)
        sheet.addAction(logout)
        sheet.addAction(cancel)
        
        // show action sheet
        present(sheet, animated: true, completion: nil)
    }
    


}
