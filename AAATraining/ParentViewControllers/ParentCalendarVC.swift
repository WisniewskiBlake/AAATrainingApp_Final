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

class ParentCalendarVC: UIViewController, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    @IBOutlet weak var newEventColorLabel: UILabel!
    @IBOutlet weak var eventColorLabel: UILabel!
    @IBOutlet weak var calendar: FSCalendar!
    
    var allEvents: [Event] = []
    var recentListener: ListenerRegistration!
    var allEventDates: [String] = []
    
    var countArray = [String]()
    
    @IBOutlet weak var logoutView: UIView!
    let logoutTapGestureRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setBadges(controller: self.tabBarController!, accountType: "coach")
        //commenting this out because notifications for parent calendar will only be seen by different color button
        //setCalendarBadges(controller: self.tabBarController!, accountType: "coach")
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadEvents), name: NSNotification.Name(rawValue: "createEvent"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadEvents), name: NSNotification.Name(rawValue: "deleteEvent"), object: nil)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)

        calendar.delegate = self
        calendar.appearance.todayColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        calendar.appearance.headerTitleColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        calendar.appearance.headerTitleFont = UIFont.boldSystemFont(ofSize:22)
        
        loadEvents()
        
        self.setLeftAlignedNavigationItemTitle(text: "Calendar", color: .white, margin: 12)
        
        eventColorLabel.layer.cornerRadius = eventColorLabel.frame.width / 2
        eventColorLabel.clipsToBounds = true
        
        newEventColorLabel.layer.cornerRadius = newEventColorLabel.frame.width / 2
        newEventColorLabel.clipsToBounds = true
        
        logoutTapGestureRecognizer.addTarget(self, action: #selector(self.logoutViewClicked))
        logoutView.isUserInteractionEnabled = true
        logoutView.addGestureRecognizer(logoutTapGestureRecognizer)
        
    }
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
       loadEvents()
    }
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    @objc func loadEvents() {
        ProgressHUD.show()
        recentListener = reference(.Event).whereField(kEVENTTEAMID, isEqualTo: FUser.currentUser()?.userTeamID).addSnapshotListener({ (snapshot, error) in
                           
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
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        calendar.formatter.dateFormat = "EEEE, MM-dd-YYYY"
        let dateString = calendar.formatter.string(from: date)
        guard let index = allEventDates.firstIndex(of: dateString) else {
            return nil
        }
        
        if allEventDates.contains(dateString) && Int(countArray[index])! >= 1 {
            return UIColor.gray
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
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        calendar.reloadData()
    }
    
    @objc func logoutViewClicked() {
        let sheet = UIAlertController(title: "Team Login Code: " + FUser.currentUser()!.userTeamID, message: nil, preferredStyle: .actionSheet)
        
        
        
        let colorPicker = UIAlertAction(title: "Choose App Color Theme", style: .default, handler: { (action) in
                        
            
            let navigationColorPicker = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColorPickerNav") as! UINavigationController
             //let colorPickerVC = navigationColorPicker.viewControllers.first as! ColorPickerVC
            
            
            self.present(navigationColorPicker, animated: true, completion: nil)
                
            
        })
        
        // creating buttons for action sheet
        let logout = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) in
                        
            FUser.logOutCurrentUser { (success) in
                
                if success {
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamLoginVC") as? TeamLoginVC
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
