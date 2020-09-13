//
//  Calendar_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/28/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import FSCalendar
import Firebase
import FirebaseFirestore
import ProgressHUD

class Calendar_Coach: UIViewController, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
//    @IBOutlet weak var newEventColorLabel: UILabel!
//    @IBOutlet weak var eventColorLabel: UILabel!
    @IBOutlet var calendar: FSCalendar!

    
    var allEvents: [Event] = []
    var upcomingEvents: [Event] = []
    var recentListener: ListenerRegistration!
    var allEventDates: [String] = []
    var countArray = [String]()
    var dateToCheckForUpcoming: [String] = []
    
    var eventsToCopy: [Event] = []
    var isNewObserver: Bool = true
    var eventToCopyUserID: String = ""
    var today: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //NotificationCenter.default.addObserver(self, selector: #selector(loadEvents), name: NSNotification.Name(rawValue: "createEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadEvents), name: NSNotification.Name(rawValue: "deleteEvent"), object: nil)
        
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)

        calendar.delegate = self
        calendar.appearance.todayColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        calendar.appearance.headerTitleColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        //calendar.appearance.weekdayTextColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize:22)
        //calendar.placeholderType = .none
        
        //loadEvents()
        
//        eventColorLabel.layer.cornerRadius = eventColorLabel.frame.width / 2
//        eventColorLabel.clipsToBounds = true
//
//        newEventColorLabel.layer.cornerRadius = newEventColorLabel.frame.width / 2
//        newEventColorLabel.clipsToBounds = true
        let todayDate = self.calendar!.today! as Date
        self.calendar.formatter.dateFormat = "YYYY-MM-dd"
        today = calendar.formatter.string(from: todayDate)
        
        self.setLeftAlignedNavigationItemTitle(text: "Calendar", color: .white, margin: 12)
        
    }
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        //loadTeamType()
        
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
//                if team.teamType == "Hockey" {
//                    self.cooperWaxLogo.isHidden = false
//                } else {
//                    self.cooperWaxLogo.isHidden = true
//                }
                    
            } else {
                
            }
        }
    }
    
    @objc func loadEvents() {
        ProgressHUD.show()
        recentListener = reference(.Event).whereField(kEVENTTEAMID, isEqualTo: FUser.currentUser()?.userTeamID).order(by: kEVENTUSERID).addSnapshotListener({ (snapshot, error) in
                           
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
                    
                    //if the user and event grabbed have same teamID, append it to all events
                    if event.eventTeamID == FUser.currentUser()?.userTeamID {
                        self.allEvents.append(event)
                        i += 1
                        //if the event that has the same teamID belongs to an existing user, append the date and count
                       if event.eventUserID == FUser.currentId() {
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
                            
                       }
                    }
                
               }
                if self.isNewObserver == true {
                    //self.isNewObserver = false
                    for event in self.eventsToCopy {
                        self.createEventsForNewObserver(event: event)
                        
                    }
                    self.calendar.reloadData()
                } else {
                    
                    
                    self.calendar.reloadData()
                }
                               
            
           }
            //may not need to reload here to speed up time
            for event in self.upcomingEvents {
                print(event.eventID)
                
            }
            
            self.calendar.reloadData()
            ProgressHUD.dismiss()
        })
    }
    
    func createEventsForNewObserver(event: Event) {
        let localReference = reference(.Event).document()
        let eventId = localReference.documentID
        var eventToUpload: [String : Any]!
        let eventCounter = 0
        eventToUpload = [kEVENTID: eventId, kEVENTTEAMID: event.eventTeamID, kEVENTOWNERID: event.eventOwnerID, kEVENTTEXT: event.eventText, kEVENTDATE: event.eventDate, kEVENTACCOUNTTYPE: FUser.currentUser()?.accountType, kEVENTCOUNTER: eventCounter, kEVENTUSERID: FUser.currentId(), kEVENTGROUPID: event.eventGroupID, kEVENTTITLE: event.eventTitle, kEVENTSTART: event.eventStart, kEVENTEND: event.eventEnd, kEVENTDATEFORUPCOMINGCOMPARISON: event.dateForUpcomingComparison] as [String:Any]

        localReference.setData(eventToUpload)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendar.formatter.dateFormat = "EEEE, MM-dd-YYYY"
        let dateString = calendar.formatter.string(from: date)
        
        calendar.formatter.dateFormat = "YYYY-MM-dd"
        let dateForUpcomingComparison = calendar.formatter.string(from: date)
        
        let eventVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Event_Coach") as! Event_Coach
        let navController = UINavigationController(rootViewController: eventVC)
        
        for event in allEvents {
            if event.eventDate == dateString {
                eventVC.updateNeeded = true
                eventVC.event = event
                eventVC.dateForUpcomingComparison = dateForUpcomingComparison
                //event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID: event.eventUserID)
            }
        }
        
        eventVC.hidesBottomBarWhenPushed = true
        eventVC.dateString = dateString
        eventVC.dateForUpcomingComparison = dateForUpcomingComparison
        
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.isNewObserver == true {
            
        }
        return allEvents.count / upcomingEvents.count

    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath)
//        cell.textLabel?.text = dataSource[indexPath.row]
//
//        if cellTagArray.contains([indexPath.section, indexPath.row]) {
//            cell.accessoryType = .checkmark
//        } else {
//            cell.accessoryType = .none
//        }
//
//        cell.tag = indexPath.row
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 50
//    }
    
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
        //print(dateString)
        if allEventDates.contains(dateString) || date == calendar.today {
            return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        } else if date.get(.month) != values.month{
            return #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        } else {
            return calendar.appearance.titleDefaultColor
        }
        
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        calendar.reloadData()
    }
    
    
    


}
extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

extension UIViewController
{
    func setLeftAlignedNavigationItemTitle(text: String,
                                           color: UIColor,
                                           margin left: CGFloat)
        
    {

        
        let titleLabel = UILabel()
        titleLabel.textColor = color
        titleLabel.text = text
        titleLabel.textAlignment = .left
        //titleLabel.font = UIFont(name: "PaladinsLaser", size: 19)
        titleLabel.font = UIFont(name: "GigaSans-Regular", size: 29)
        //titleLabel.backgroundColor = .black
        
//        titleLabel.font = UIFont(name: "Paladins", size: 29)
//        titleLabel.font = UIFont(name: "Paladins3D", size: 29)
        //titleLabel.font = UIFont(name: "PaladinsCondensed", size: 29)
        //titleLabel.font = UIFont(name: "Spantaran", size: 29)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.navigationItem.titleView = titleLabel
        
        
        
        guard let containerView = self.navigationItem.titleView?.superview else { return }
        
        // NOTE: This always seems to be 0. Huh??
        //let leftBarItemWidth = self.navigationItem.leftBarButtonItems?.reduce(0, { $0 + $1.width })
        let leftBarItemWidth = self.navigationItem.leftBarButtonItems?.reduce(0, { $0 + $1.width/2 })
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor,
                                             constant: (leftBarItemWidth ?? 0) + left),
            titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -100)
        ])
    }
}
