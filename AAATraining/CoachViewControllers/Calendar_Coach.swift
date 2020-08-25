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
    
    @IBOutlet weak var newEventColorLabel: UILabel!
    @IBOutlet weak var eventColorLabel: UILabel!
    @IBOutlet var calendar: FSCalendar!
    
    var allEvents: [Event] = []
    var recentListener: ListenerRegistration!
    var allEventDates: [String] = []
    var countArray = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadEvents), name: NSNotification.Name(rawValue: "createEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadEvents), name: NSNotification.Name(rawValue: "deleteEvent"), object: nil)

        calendar.delegate = self
        calendar.appearance.todayColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        calendar.appearance.headerTitleColor = #colorLiteral(red: 0.1006183103, green: 0.2956552207, blue: 0.71825701, alpha: 1)
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize:22)
        //calendar.placeholderType = .none
        
        loadEvents()
        
        eventColorLabel.layer.cornerRadius = eventColorLabel.frame.width / 2
        eventColorLabel.clipsToBounds = true
        
        newEventColorLabel.layer.cornerRadius = newEventColorLabel.frame.width / 2
        newEventColorLabel.clipsToBounds = true
    }
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       loadEvents()
    }
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    @objc func loadEvents() {
        ProgressHUD.show()
        recentListener = reference(.Event).addSnapshotListener({ (snapshot, error) in
                           
            self.allEvents = []
            self.allEventDates = []
            self.countArray = []
                        
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
                   self.allEvents.append(event)
                   if event.eventUserID == FUser.currentId() {
                        self.allEventDates.append(event.eventDate)
                        self.countArray.append(String(event.eventCounter))
                    }
                
               }
               self.calendar.reloadData()
            
           }
            self.calendar.reloadData()
            ProgressHUD.dismiss()
        })
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendar.formatter.dateFormat = "EEEE, MM-dd-YYYY"
        let dateString = calendar.formatter.string(from: date)
        
        let eventVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Event_Coach") as! Event_Coach
        let navController = UINavigationController(rootViewController: eventVC)
        
        for event in allEvents {
            if event.eventDate == dateString {
                eventVC.updateNeeded = true
                eventVC.event = event                                
                //event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID: event.eventUserID)
            }
        }
        
        eventVC.hidesBottomBarWhenPushed = true
        eventVC.dateString = dateString
        
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        calendar.formatter.dateFormat = "EEEE, MM-dd-YYYY"
        let dateString = calendar.formatter.string(from: date)
        guard let index = allEventDates.firstIndex(of: dateString) else {
            return nil
        }
        
        
        if allEventDates.contains(dateString) && Int(countArray[index])! >= 1 {
              
            return #colorLiteral(red: 0.9044845104, green: 0.09804645926, blue: 0.1389197409, alpha: 1)
            
        } else if allEventDates.contains(dateString) && Int(countArray[index])! == 0 {
            
            return #colorLiteral(red: 0.1006183103, green: 0.2956552207, blue: 0.71825701, alpha: 1)
        }  else {
            return nil
        }

    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        calendar.formatter.dateFormat = "EEEE, MM-dd-YYYY"
        let dateString = calendar.formatter.string(from: date)
        let values = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: self.calendar.currentPage)
        let range = Calendar.current.range(of: Calendar.Component.day, in: Calendar.Component.month, for: self.calendar.currentPage)
        let timeInterval = date.timeIntervalSince1970
        
        if allEventDates.contains(dateString) || date == calendar.today {
              
            return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
        } else if date.get(.month) != values.month{
            return #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        }
        else {
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
