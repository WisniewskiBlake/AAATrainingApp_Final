//
//  Event_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/28/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase
import FirebaseCore
import FirebaseFirestore

class Event_Coach: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateText: UITextField!
    

    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var eventTitleText: UITextField!
    @IBOutlet weak var eventStartText: UITextField!
    @IBOutlet weak var eventEndText: UITextField!
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var navView: UIView!
    
      
    var memberIds: [String] = []
    var allMembers: [FUser] = []
    
    var dateString: String = ""
    let formatter = DateFormatter()
    let helper = Helper()
    
    var updateNeeded: Bool = false
    
    var event = Event()
    var accountType = ""
    
    var allEventsWithGroupID: [Event] = []
    
    var dateForUpcomingComparison: String = ""
    var datePicker = UIDatePicker()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print(dateForUpcomingComparison)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
        self.navView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
        getAllMembers()
        getAllEvents()
        configureUI()
        createStartDatePicker()
        createEndDatePicker()
        createEventDatePicker()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        

        //dateLabel.text = dateString
        textView.text = event.eventText
        eventTitleText.text = event.eventTitle
        eventStartText.text = event.eventStart
        eventEndText.text = event.eventEnd
        
        if event.eventText != "" {
            placeHolderLabel.isHidden = true
        } else {
            placeHolderLabel.isHidden = false
        }
        if updateNeeded == true {
            deleteButton.isHidden = false
            self.doneButton.setTitle("Update", for: .normal)
            
        } else {
            deleteButton.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
    }
    
    func createEvent(eventOwnerID: String, eventTeamID: String, eventText: String, eventDate: String, eventAccountType: String, eventUserID: String, eventGroupID: String, eventTitle: String, eventStart: String, eventEnd: String) {
        let localReference = reference(.Event).document()
        let eventId = localReference.documentID
        var event: [String : Any]!
        var eventCounter = 0
        
        if eventUserID != eventOwnerID {
            eventCounter = 1
        }
        
        event = [kEVENTID: eventId, kEVENTTEAMID: eventTeamID, kEVENTOWNERID: FUser.currentId(), kEVENTTEXT: eventText, kEVENTDATE: self.dateString, kEVENTACCOUNTTYPE: eventAccountType, kEVENTCOUNTER: eventCounter, kEVENTUSERID: eventUserID, kEVENTGROUPID: eventGroupID, kEVENTTITLE: eventTitle, kEVENTSTART: eventStart, kEVENTEND: eventEnd, kEVENTDATEFORUPCOMINGCOMPARISON: dateForUpcomingComparison] as [String:Any]
        
        localReference.setData(event)
        
    }
    
    func createTeamEvent(eventOwnerID: String, eventTeamID: String, eventText: String, eventDate: String, eventAccountType: String, eventUserID: String, eventGroupID: String, eventTitle: String, eventStart: String, eventEnd: String) {
        let localReference = reference(.TeamEventCache).document()
        let eventId = localReference.documentID
        var event: [String : Any]!
        var eventCounter = 0
        
        event = [kEVENTID: eventId, kEVENTTEAMID: eventTeamID, kEVENTOWNERID: FUser.currentId(), kEVENTTEXT: eventText, kEVENTDATE: self.dateString, kEVENTACCOUNTTYPE: eventAccountType, kEVENTCOUNTER: "0", kEVENTUSERID: "", kEVENTGROUPID: eventGroupID, kEVENTTITLE: eventTitle, kEVENTSTART: eventStart, kEVENTEND: eventEnd, kEVENTDATEFORUPCOMINGCOMPARISON: dateForUpcomingComparison] as [String:Any]
        
        localReference.setData(event)
        
    }
    
    //get all events with the same teamID as current user, sort by event id and create new events for current user. The number of new events to be created will be determined by how many indexes in until the next eventUserID starts
    
    func createEventForMembers() {
        if self.memberIds.isEmpty {
            self.memberIds.append(FUser.currentId())
        }
        var tempMembers = memberIds
        let eventText = textView.text!
        let eventOwnerID = FUser.currentId()
        let eventAccountType = "Coach"
        let eventGroupID = UUID().uuidString
        let eventTitle = eventTitleText.text!
        let eventStart = eventStartText.text
        let eventEnd = eventEndText.text
        
        
        //NEED TO ADD EVENTGROUPID HERE NOT DATE, EVENTGROUPID WILL BE THE ID ALL USERS SHARE FOR AN EVENT (SYNONYMOUS WITH CHATROOMID), AND EVENTID WILL BE
        //A UNIQUE IDENTIFIER FOR THE EVENT
//        reference(.Event).whereField(kEVENTDATE, isEqualTo: dateString).whereField(kEVENTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID).getDocuments { (snapshot, error) in
//
//            guard let snapshot = snapshot else { return }
//
//            if !snapshot.isEmpty {
//
//                for event in snapshot.documents {
//
//                    let currEvent = event.data() as NSDictionary
//
//                    if let currentUserId = currEvent[kEVENTUSERID] {
//
//                        if tempMembers.contains(currentUserId as! String) {
//                            tempMembers.remove(at: tempMembers.firstIndex(of: currentUserId as! String)!)
//                        }
//                    }
//                }
//
//            }
            
            
            for userId in tempMembers {
             self.createEvent(eventOwnerID: eventOwnerID, eventTeamID: FUser.currentUser()!.userCurrentTeamID, eventText: eventText, eventDate: self.dateString, eventAccountType: eventAccountType, eventUserID: userId, eventGroupID: eventGroupID, eventTitle: eventTitle, eventStart: eventStart!, eventEnd: eventEnd!)

            }
            self.createTeamEvent(eventOwnerID: eventOwnerID, eventTeamID: FUser.currentUser()!.userCurrentTeamID, eventText: eventText, eventDate: self.dateString, eventAccountType: eventAccountType, eventUserID: "", eventGroupID: eventGroupID, eventTitle: eventTitle, eventStart: eventStart!, eventEnd: eventEnd!)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createEvent"), object: nil)
            sleep(UInt32(0.6))
            ProgressHUD.dismiss()
        //}
    }
    
    func getAllMembers() {

        
//        reference(.Event).whereField(kEVENTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID).order(by: kEVENTUSERID).order(by: kEVENTDATEFORUPCOMINGCOMPARISON).getDocuments { (snapshot, error) in
//
//            self.memberIds = []
//
//            guard let snapshot = snapshot else { return }
//
//            if !snapshot.isEmpty {
//
//                for eventDictionary in snapshot.documents {
//
//                    let eventDictionary = eventDictionary.data() as NSDictionary
//                    let event = Event(_dictionary: eventDictionary)
//
//                    if !self.memberIds.contains(event.eventUserID) {
//                        self.memberIds.append(event.eventUserID)
//                    }
//
//                }
//
//
//
//            }
//        }
                
        reference(.User).whereField(kUSERTEAMIDS, arrayContains: FUser.currentUser()!.userCurrentTeamID).getDocuments { (snapshot, error) in
              self.memberIds = []
            guard let snapshot = snapshot else { return }

            if !snapshot.isEmpty {

                for userDictionary in snapshot.documents {

                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)

                    self.memberIds.append(fUser.objectId)

                }
            }
        }
    }
    
    func getAllEvents() {
        reference(.Event).whereField(kEVENTGROUPID, isEqualTo: event.eventGroupID).getDocuments { (snapshot, error) in
            self.allEventsWithGroupID = []
            
            guard let snapshot = snapshot else { return }
        
            if !snapshot.isEmpty {
                
                for eventDictionary in snapshot.documents {
                    
                    let eventDictionary = eventDictionary.data() as NSDictionary
                    let eventS = Event(_dictionary: eventDictionary)
                    if eventS.eventGroupID == self.event.eventGroupID {
                        self.allEventsWithGroupID.append(eventS)
                    }
                    
                    
                   
                }
            }
        }
    }
    

    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        //ProgressHUD.show()
        ProgressHUD.show("Deleting...", interaction: false)
        var i = 0
        
        for event in allEventsWithGroupID {
            reference(.Event).document(event.eventID).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    i += 1
                }
                if i == self.allEventsWithGroupID.count {
                    sleep(UInt32(1.7))
                           ProgressHUD.dismiss()
                           NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deleteEvent"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
//        reference(.Event).whereField(kEVENTGROUPID, isEqualTo: event.eventGroupID).getDocuments { (snapshot, error) in
//
//            guard let snapshot = snapshot else { return }
//
//            if !snapshot.isEmpty {
//
//                for event in snapshot.documents {
//                    let currEvent = event.data() as NSDictionary
//                    reference(.Event).document(currEvent[kEVENTID] as! String).delete() { err in
//                        if let err = err {
//                            print("Error removing document: \(err)")
//                        } else {
//                            print("Document successfully removed!")
//                            i += 1
//                        }
//                    }
//                }
//            }
//        }
        
        
       
//        if let calendarVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Calendar_Coach") as? Calendar_Coach
//        {
//
//            calendarVC.modalPresentationStyle = .fullScreen
//            self.present(calendarVC, animated: true, completion: nil)
//        }
//        if i == allEventsWithGroupID.count {
//
//        }
        
        
        
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if eventTitleText.text != "" && eventStartText.text != "" && eventEndText.text != "" && dateText.text != "" {
            if self.doneButton.currentTitle == "Update" {
                event.updateEvent(eventGroupID: event.eventGroupID, eventOwnerID: event.eventOwnerID, eventText: textView.text!, eventTitle: eventTitleText.text!, eventStart: eventStartText.text!, eventEnd: eventEndText.text!)
            } else {
                ProgressHUD.show("Creating...", interaction: false)
                createEventForMembers()
                sleep(UInt32(0.5))
            }
            
            //createEvent()
        } else {
            helper.showAlert(title: "Data Error", message: "Please fill in info.", in: self)
        }
        sleep(UInt32(1.5))
        dismiss(animated: true, completion: nil)
        
    }

    
    func createStartDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneStartPressed))
        toolbar.setItems([doneBtn], animated: true)
        eventStartText.inputAccessoryView = toolbar
        eventStartText.inputView = datePicker
        datePicker.datePickerMode = .time
    }
    func createEndDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneEndPressed))
        toolbar.setItems([doneBtn], animated: true)
        eventEndText.inputAccessoryView = toolbar
        eventEndText.inputView = datePicker
        datePicker.datePickerMode = .time
    }
    
    func createEventDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneEventDatePressed))
        toolbar.setItems([doneBtn], animated: true)
        dateText.inputAccessoryView = toolbar
        dateText.inputView = datePicker
        datePicker.datePickerMode = .date
    }
    
    @objc func doneEventDatePressed() {
        let formatter = DateFormatter()
        //formatter.dateStyle = .full
        formatter.dateFormat = "EEEE, MM-dd-YYYY"
        self.dateString = formatter.string(from: datePicker.date)
        dateText.text = formatter.string(from: datePicker.date)
        formatter.dateFormat = "YYYY-MM-dd"
        self.dateForUpcomingComparison = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func doneStartPressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        eventStartText.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func doneEndPressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        eventEndText.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    func configureUI() {
        
       self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
       navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
        var bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: eventStartText.frame.height, width: eventStartText.frame.width, height: 1.0)
        bottomLine.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        eventStartText.borderStyle = UITextField.BorderStyle.none
        eventStartText.layer.addSublayer(bottomLine)
        
        var bottomLine1 = CALayer()
        bottomLine1.frame = CGRect(x: 0.0, y: eventEndText.frame.height, width: eventEndText.frame.width, height: 1.0)
        bottomLine1.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        eventEndText.borderStyle = UITextField.BorderStyle.none
        eventEndText.layer.addSublayer(bottomLine1)

        cornerRadius(for: deleteButton)
    }
    

        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
        //removeListeners()
        dismiss(animated: true, completion: nil)
    }
    


    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textView.resignFirstResponder()
        eventTitleText.resignFirstResponder()
        eventStartText.resignFirstResponder()
        eventEndText.resignFirstResponder()
        
           return true;
       }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeHolderLabel.isHidden = false
        }
        else {
            placeHolderLabel.isHidden = true
        }
    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.view.endEditing(true)
//        return false
//    }
    
    // exec whenever the screen has been tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.resignFirstResponder()
    }
    
//    @IBAction func backButtonPressed(_ sender: Any) {
//        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
//        //removeListeners()
//        dismiss(animated: true, completion: nil)
//    }
    
    // make corners rounded for any views (objects)
    func cornerRadius(for view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
    }

}
