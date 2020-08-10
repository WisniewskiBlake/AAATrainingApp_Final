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

class PlayerCalendar: UIViewController,FSCalendarDelegate, FSCalendarDelegateAppearance {

    @IBOutlet weak var calendar: FSCalendar!
    
    var allEvents: [Event] = []
    var recentListener: ListenerRegistration!
    var allEventDates: [String] = []
    
        
    var countArray = [String]()
    
     
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(loadEvents), name: NSNotification.Name(rawValue: "createEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadEvents), name: NSNotification.Name(rawValue: "deleteEvent"), object: nil)

        calendar.delegate = self
        loadEvents()
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
       
        
        if allEventDates.contains(dateString) || date == calendar.today {
              
            return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
             
            
        } else {
            return calendar.appearance.titleDefaultColor
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendar.formatter.dateFormat = "EEEE, MM-dd-YYYY"
        let dateString = calendar.formatter.string(from: date)
        
        let eventVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerEvent") as! PlayerEvent
        let navController = UINavigationController(rootViewController: eventVC)
        
        for event in allEvents {
            if event.eventDate == dateString {                
                eventVC.event = event
                eventVC.accountType = "player"
            } else {
                eventVC.eventText = ""
            }
        }
        
        eventVC.hidesBottomBarWhenPushed = true
        eventVC.dateString = dateString
        
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    


}
