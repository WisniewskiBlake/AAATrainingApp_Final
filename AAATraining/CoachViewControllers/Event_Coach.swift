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

class Event_Coach: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var memberIds: [String] = []
    var allMembers: [FUser] = []
    
    var dateString: String = ""
    let formatter = DateFormatter()
    let helper = Helper()
    var eventText: String = ""
    var updateNeeded: Bool = false
    var eventID: String = ""
    var event = Event()
    var accountType = ""
    var eventCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getAllMembers()
        cornerRadius(for: deleteButton)

        dateLabel.text = dateString
        textView.text = event.eventText
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
    
    override func viewWillAppear(_ animated: Bool) {
        event.clearCalendarCounter(eventID: event.eventID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        event.clearCalendarCounter(eventID: event.eventID)
    }
    
    func createEvent(eventOwnerID: String, eventText: String, eventDate: String, eventAccountType: String, eventUserID: String, eventGroupID: String) {
        let localReference = reference(.Event).document()
        let eventId = localReference.documentID
        var event: [String : Any]!
        
        event = [kEVENTID: eventId, kEVENTOWNERID: FUser.currentId(), kEVENTTEXT: eventText, kEVENTDATE: self.dateString, kEVENTACCOUNTTYPE: eventAccountType, kEVENTCOUNTER: 0, kEVENTUSERID: eventUserID, kEVENTGROUPID: eventGroupID] as [String:Any]
        
        localReference.setData(event)
        
    }
    
    func createEventForMembers() {
        var tempMembers = memberIds
        let eventText = textView.text!
        let eventOwnerID = FUser.currentId()
        let eventAccountType = "coach"
        let eventGroupID = UUID().uuidString
        
//        let localReference = reference(.Event).document()
//        let eventId = localReference.documentID
               
        
        //NEED TO ADD EVENTGROUPID HERE NOT DATE, EVENTGROUPID WILL BE THE ID ALL USERS SHARE FOR AN EVENT (SYNONYMOUS WITH CHATROOMID), AND EVENTID WILL BE
        //A UNIQUE IDENTIFIER FOR THE EVENT
           reference(.Event).whereField(kEVENTDATE, isEqualTo: dateString).getDocuments { (snapshot, error) in
               
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
                self.createEvent(eventOwnerID: eventOwnerID, eventText: eventText, eventDate: self.dateString, eventAccountType: eventAccountType, eventUserID: userId, eventGroupID: eventGroupID)

                //                    if userId != FUser.currentId() {
//                        let event = Event(eventID: eventId, eventOwnerID: FUser.currentId(), eventText: eventText!, eventDate: self.dateString, eventAccountType: eventAccountType, eventCounter: 1, eventUserID: userId)
//                        event.saveEvent(eventID : eventId)
//                    } else {
//                        let event = Event(eventID: eventId, eventOwnerID: FUser.currentId(), eventText: eventText!, eventDate: self.dateString, eventAccountType: eventAccountType, eventCounter: 0, eventUserID: userId)
//                        event.saveEvent(eventID : eventId)
//                    }
                    
                
                
                   
               }
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createEvent"), object: nil)
           }
    }
    
    func getAllMembers() {
        reference(.User).getDocuments { (snapshot, error) in
        
            guard let snapshot = snapshot else { return }
        
            if !snapshot.isEmpty {
                
                for user in snapshot.documents {
                    
                    let currUser = user.data() as NSDictionary
                    
                    self.memberIds.append(currUser[kOBJECTID] as! String)
                   
                }
            }
        }
    }
    

    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        reference(.Event).document(eventID).delete()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deleteEvent"), object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if textView.text != "" {
            createEventForMembers()
            //createEvent()
        } else {
            helper.showAlert(title: "Data Error", message: "Please fill in info.", in: self)
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeHolderLabel.isHidden = false
        }
        else {
            placeHolderLabel.isHidden = true
        }
    }
    
    
    // exec whenever the screen has been tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.resignFirstResponder()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        event.clearCalendarCounter(eventID: event.eventID)
        //removeListeners()
        dismiss(animated: true, completion: nil)
    }
    
    // make corners rounded for any views (objects)
    func cornerRadius(for view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
    }
    

}
