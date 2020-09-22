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

class Calendar_Coach: UIViewController, FSCalendarDelegate, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet var calendar: FSCalendar!
    @IBOutlet weak var upcomingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
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
    
    var x = 0
    
    var eventCopied = Event()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(loadEvents), name: NSNotification.Name(rawValue: "deleteEvent"), object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(loadEvents), name: NSNotification.Name(rawValue: "createEvent"), object: nil)

        

        let todayDate = self.calendar!.today! as Date
        self.calendar.formatter.dateFormat = "YYYY-MM-dd"
        today = calendar.formatter.string(from: todayDate)
        
        
        //loadEvents()
        
    }
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calendar.delegate = self
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
        splitterLabel.backgroundColor = #colorLiteral(red: 0.6815950428, green: 0.6815950428, blue: 0.6815950428, alpha: 1)
        splitterLabelTwo.backgroundColor = #colorLiteral(red: 0.9133789539, green: 0.9214370847, blue: 0.9337923527, alpha: 1)
    }
    
    func loadTeam() {
        team.getTeam(teamID: FUser.currentUser()!.userCurrentTeamID) { (teamReturned) in
            if teamReturned.teamID != "" {
                self.team = teamReturned
                    
            } else {
                
            }
        }
    }
    
    @objc func loadEvents() {
        print("loadEvents")
        ProgressHUD.show()
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
            self.x += 1
            print("x " + String(self.allEvents.count))
            
                
           self.tableView.reloadData()
           self.calendar.reloadData()
            
            ProgressHUD.dismiss()
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
        
        if let eventVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Event_Coach") as? Event_Coach
        {
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
            eventVC.modalPresentationStyle = .fullScreen
            self.present(eventVC, animated: true, completion: nil)
        }
        
//        let eventVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Event_Coach") as! Event_Coach
//        let navController = UINavigationController(rootViewController: eventVC)
        
        
        
        
        
        //self.navigationController?.present(navController, animated: true, completion: nil)
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
        
        let eventVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Event_Coach") as! Event_Coach
        let navController = UINavigationController(rootViewController: eventVC)
        
        eventVC.updateNeeded = true
        eventVC.event = event
        eventVC.dateForUpcomingComparison = event.dateForUpcomingComparison
        
        eventVC.hidesBottomBarWhenPushed = true
        eventVC.dateString = event.eventDate
        eventVC.dateForUpcomingComparison = event.dateForUpcomingComparison
        
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        titleLabel.font = UIFont(name: "PROGRESSPERSONALUSE", size: 27)
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
extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
