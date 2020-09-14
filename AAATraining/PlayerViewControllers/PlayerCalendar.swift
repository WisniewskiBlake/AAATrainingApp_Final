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

class PlayerCalendar: UIViewController, FSCalendarDelegate, FSCalendarDelegateAppearance, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var upcomingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var allEvents: [Event] = []
    var upcomingEvents: [Event] = []
    var recentListener: ListenerRegistration!
    var allEventDates: [String] = []
    var countArray = [String]()
    
    var eventsToCopy: [Event] = []
    var isNewObserver: Bool = true
    var eventToCopyUserID: String = ""
    var today: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        NotificationCenter.default.addObserver(self, selector: #selector(loadEvents), name: NSNotification.Name(rawValue: "createEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadEvents), name: NSNotification.Name(rawValue: "deleteEvent"), object: nil)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)

        calendar.delegate = self
        calendar.appearance.todayColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        calendar.appearance.headerTitleColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize:22)
        
        let todayDate = self.calendar!.today! as Date
        self.calendar.formatter.dateFormat = "YYYY-MM-dd"
        today = calendar.formatter.string(from: todayDate)
        
        self.setLeftAlignedNavigationItemTitle(text: "Team Calendar", color: .white, margin: 12)
        
        let width = CGFloat(2)
        let color = UIColor.lightGray.cgColor
        let border = CALayer()
        border.borderWidth = width
        border.borderColor = color
        border.frame = CGRect(x: -3, y: 0, width: upcomingLabel.frame.width+6, height: upcomingLabel.frame.height)
        upcomingLabel.layer.addSublayer(border)
        upcomingLabel.layer.cornerRadius = 5
        upcomingLabel.layer.masksToBounds = true
    }
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)

       loadEvents()
    }
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    func loadTeamType() {
        var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "", teamType: "")
        
        team.getTeam(teamID: FUser.currentUser()!.userTeamID) { (teamReturned) in
            if teamReturned.teamID != "" {
                team = teamReturned
                    
            } else {
                
            }
        }
    }
    
    @objc func loadEvents() {
        ProgressHUD.show()
        recentListener = reference(.Event).whereField(kEVENTTEAMID, isEqualTo: FUser.currentUser()?.userTeamID).order(by: kEVENTUSERID).order(by: kEVENTDATEFORUPCOMINGCOMPARISON).addSnapshotListener({ (snapshot, error) in
                           
            self.allEvents = []
            self.allEventDates = []
            self.countArray = []
            self.eventsToCopy = []
            self.eventToCopyUserID = ""
            self.upcomingEvents = []
            
            var i = 0
            
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.calendar.reloadData()
                return
            }
            guard let snapshot = snapshot else { ProgressHUD.dismiss(); return }
                   
            if !snapshot.isEmpty {
                for eventDictionary in snapshot.documents {
                    
                   let eventDictionary = eventDictionary.data() as NSDictionary
                   let event = Event(_dictionary: eventDictionary)
                    
                    if event.dateForUpcomingComparison > self.today && event.eventUserID == FUser.currentId() {
                        self.upcomingEvents.append(event)
                    }
                    
                    if event.eventTeamID == FUser.currentUser()?.userTeamID {
                        self.allEvents.append(event)
                        i += 1
                       if event.eventUserID == FUser.currentId() {
                            self.allEventDates.append(event.eventDate)
                            self.countArray.append(String(event.eventCounter))
                            self.isNewObserver = false
                       } else {
                            
                            if i == 1 {
                                self.eventsToCopy.append(event)
                                self.eventToCopyUserID = event.eventUserID
                            } else if i > 1 {
                                if self.eventToCopyUserID == event.eventUserID {
                                    self.eventsToCopy.append(event)
                                }
                            }
                            
                       }
                    }

                
               }
                if self.isNewObserver == true {
                    //self.isNewObserver = false
                    for event in self.eventsToCopy {
                        self.createEventsForNewObserver(event: event)
                    }
                    self.tableView.reloadData()
                    self.calendar.reloadData()
                } else {
                    self.tableView.reloadData()
                    self.calendar.reloadData()
                }
               //self.calendar.reloadData()
            
           }
            self.tableView.reloadData()
            self.calendar.reloadData()
            ProgressHUD.dismiss()
        })
    }
    
    //when a new observer opens the view this is called twice
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
        
        calendar.formatter.dateFormat = "YYYY-MM-dd"
        let dateForUpcomingComparison = calendar.formatter.string(from: date)
        
        let eventVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerEvent") as! PlayerEvent
        let navController = UINavigationController(rootViewController: eventVC)
        
        for event in allEvents {
            if event.eventDate == dateString {                
                eventVC.event = event
//                eventVC.eventStart = event.eventStart
//                eventVC.eventEnd = event.eventEnd
//                eventVC.eventTitle = event.eventTitle
                eventVC.accountType = "player"
                
            } else {
                eventVC.eventText = ""
                eventVC.eventStart = ""
                eventVC.eventEnd = ""
                eventVC.eventTitle = ""
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
        
        let eventVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerEvent") as! PlayerEvent
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
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        calendar.reloadData()
    }

}
