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
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var eventTitleText: UITextField!
    @IBOutlet weak var eventStartText: UITextField!
    @IBOutlet weak var eventEndText: UITextField!
    
      
    var memberIds: [String] = []
    var allMembers: [FUser] = []
    
    var dateString: String = ""
    let formatter = DateFormatter()
    let helper = Helper()
    
    var updateNeeded: Bool = false
    
    var event = Event()
    var accountType = ""
    
    var allEventsWithGroupID: [NSDictionary] = []
    
    var dateForUpcomingComparison: String = ""
    var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(dateForUpcomingComparison)
        getAllMembers()
        getAllEvents()
        configureUI()
        createStartDatePicker()
        createEndDatePicker()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        

        dateLabel.text = dateString
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
            self.navigationItem.rightBarButtonItem?.title = "Update"
        } else {
            deleteButton.isHidden = true
        }
        
        
        
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
        
        var bottomLine2 = CALayer()
        bottomLine2.frame = CGRect(x: 0.0, y: eventTitleText.frame.height - 1, width: eventTitleText.frame.width, height: 1.0)
        bottomLine2.backgroundColor = #colorLiteral(red: 0.6574437103, green: 0.6574437103, blue: 0.6574437103, alpha: 1)
        eventTitleText.borderStyle = UITextField.BorderStyle.none
        eventTitleText.layer.addSublayer(bottomLine2)
        cornerRadius(for: deleteButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
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
    
    //get all events with the same teamID as current user, sort by event id and create new events for current user. The number of new events to be created will be determined by how many indexes in until the next eventUserID starts
    
    func createEventForMembers() {
        var tempMembers = memberIds
        let eventText = textView.text!
        let eventOwnerID = FUser.currentId()
        let eventAccountType = "coach"
        let eventGroupID = UUID().uuidString
        let eventTitle = eventTitleText.text!
        let eventStart = eventStartText.text
        let eventEnd = eventEndText.text
        
        
        //NEED TO ADD EVENTGROUPID HERE NOT DATE, EVENTGROUPID WILL BE THE ID ALL USERS SHARE FOR AN EVENT (SYNONYMOUS WITH CHATROOMID), AND EVENTID WILL BE
        //A UNIQUE IDENTIFIER FOR THE EVENT
        reference(.Event).whereField(kEVENTDATE, isEqualTo: dateString).whereField(kEVENTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID).getDocuments { (snapshot, error) in
               
               guard let snapshot = snapshot else { return }
               
               if !snapshot.isEmpty {
                   
                   for event in snapshot.documents {
                       
                       let currEvent = event.data() as NSDictionary
                       
                       if let currentUserId = currEvent[kEVENTUSERID] {
                           
                           if tempMembers.contains(currentUserId as! String) {
                               tempMembers.remove(at: tempMembers.firstIndex(of: currentUserId as! String)!)
                           }
                       }
                   }
                   
               }
               
               
               for userId in tempMembers {
                self.createEvent(eventOwnerID: eventOwnerID, eventTeamID: FUser.currentUser()!.userCurrentTeamID, eventText: eventText, eventDate: self.dateString, eventAccountType: eventAccountType, eventUserID: userId, eventGroupID: eventGroupID, eventTitle: eventTitle, eventStart: eventStart!, eventEnd: eventEnd!)

               }
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createEvent"), object: nil)
           }
    }
    
    func getAllMembers() {
        
        reference(.Event).whereField(kEVENTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID).order(by: kEVENTUSERID).order(by: kEVENTDATEFORUPCOMINGCOMPARISON).getDocuments { (snapshot, error) in
            
            self.memberIds = []
        
            guard let snapshot = snapshot else { return }
        
            if !snapshot.isEmpty {
                
                for eventDictionary in snapshot.documents {
                    
                    let eventDictionary = eventDictionary.data() as NSDictionary
                    let event = Event(_dictionary: eventDictionary)
                    
                    if !self.memberIds.contains(event.eventUserID) {
                        self.memberIds.append(event.eventUserID)
                    }
                   
                }
            }
        }
        
        
        
//        reference(.User).whereField(kUSERTEAMIDS, arrayContains: FUser.currentUser()!.userCurrentTeamID).getDocuments { (snapshot, error) in
//
//            guard let snapshot = snapshot else { return }
//
//            if !snapshot.isEmpty {
//
//                for user in snapshot.documents {
//
//                    let currUser = user.data() as NSDictionary
//
//                    self.memberIds.append(currUser[kOBJECTID] as! String)
//
//                }
//            }
//        }
    }
    
    func getAllEvents() {
        reference(.Event).whereField(kEVENTGROUPID, isEqualTo: event.eventGroupID).getDocuments { (snapshot, error) in
        
            guard let snapshot = snapshot else { return }
        
            if !snapshot.isEmpty {
                
                for event in snapshot.documents {
                    
                    let currEvent = event.data() as NSDictionary
                    
                    if currEvent[kEVENTGROUPID] as! String == self.event.eventGroupID {
                        self.allEventsWithGroupID.append(currEvent)
                    }
                    
                    
                   
                }
            }
        }
    }
    

    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        for eventGrp in allEventsWithGroupID {
            reference(.Event).document(eventGrp[kEVENTID] as! String).delete()
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deleteEvent"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if eventTitleText.text != "" && eventStartText.text != "" && eventEndText.text != "" {
            if self.navigationItem.rightBarButtonItem?.title == "Update" {
                event.updateEvent(eventGroupID: event.eventGroupID, eventOwnerID: event.eventOwnerID, eventText: textView.text!, eventTitle: eventTitleText.text!, eventStart: eventStartText.text!, eventEnd: eventEndText.text!)
            } else {
                createEventForMembers()
            }
            
            //createEvent()
        } else {
            helper.showAlert(title: "Data Error", message: "Please fill in info.", in: self)
        }
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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
        //removeListeners()
        dismiss(animated: true, completion: nil)
    }
    
    // make corners rounded for any views (objects)
    func cornerRadius(for view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
    }

}
