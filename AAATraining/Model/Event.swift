//
//  Event.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/29/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import Foundation
import Firebase

public class Event {
    var eventID: String
    var eventOwnerID: String
    var eventText: String
    var eventDate: String
    var eventAccountType: String
    var eventCounter: Int
    var eventUserID: String
    var eventGroupID: String
    
    
    
    let eventDictionary: NSMutableDictionary
    
    init() {
        eventID = ""
        eventOwnerID = ""
        eventText = ""
        eventDate = ""
        eventAccountType = ""
        eventCounter = 0
        eventUserID = ""
        eventGroupID = ""
        eventDictionary = NSMutableDictionary(objects: [eventID, eventOwnerID, eventText, eventDate, eventAccountType, eventCounter, eventUserID, eventGroupID], forKeys: [kEVENTID as NSCopying, kEVENTOWNERID as NSCopying, kEVENTTEXT as NSCopying, kEVENTDATE as NSCopying, kEVENTACCOUNTTYPE as NSCopying, kEVENTCOUNTER as NSCopying, kEVENTUSERID as NSCopying, kEVENTGROUPID as NSCopying])
    }

    init(eventID: String, eventOwnerID: String, eventText: String, eventDate: String, eventAccountType: String, eventCounter: Int, eventUserID: String, eventGroupID: String) {

        eventDictionary = NSMutableDictionary(objects: [eventID, eventOwnerID, eventText, eventDate, eventAccountType, eventCounter, eventUserID, eventGroupID], forKeys: [kEVENTID as NSCopying, kEVENTOWNERID as NSCopying, kEVENTTEXT as NSCopying, kEVENTDATE as NSCopying, kEVENTACCOUNTTYPE as NSCopying, kEVENTCOUNTER as NSCopying, kEVENTUSERID as NSCopying, kEVENTGROUPID as NSCopying])
        
        self.eventID = eventID
        self.eventOwnerID = eventOwnerID
        self.eventText = eventText
        self.eventDate = eventDate
        self.eventAccountType = eventAccountType
        self.eventCounter = eventCounter
        self.eventUserID = eventUserID
        self.eventGroupID = eventGroupID
    }
    
    init(_dictionary: NSDictionary) {
        
       //let helper = Helper()
       eventID = _dictionary[kEVENTID] as! String
       eventOwnerID = _dictionary[kEVENTOWNERID] as! String
       
       
       if let txt = _dictionary[kEVENTTEXT] {
           eventText = txt as! String
       } else {
           eventText = ""
       }
       if let dte = _dictionary[kEVENTDATE] {
           eventDate = dte as! String
       } else {
           eventDate = ""
       }
       if let accT = _dictionary[kEVENTACCOUNTTYPE] {
           eventAccountType = accT as! String
       } else {
           eventAccountType = ""
       }
        if let eC = _dictionary[kEVENTCOUNTER] {
            eventCounter = eC as! Int
        } else {
            eventCounter = 0
        }
        if let eID = _dictionary[kEVENTUSERID] {
            eventUserID = eID as! String
        } else {
            eventUserID = ""
        }
        if let egID = _dictionary[kEVENTGROUPID] {
            eventGroupID = egID as! String
        } else {
            eventGroupID = ""
        }
       
        
        eventDictionary = NSMutableDictionary(objects: [eventID, eventOwnerID, eventText, eventDate, eventAccountType, eventCounter, eventUserID, eventGroupID], forKeys: [kEVENTID as NSCopying, kEVENTOWNERID as NSCopying, kEVENTTEXT as NSCopying, kEVENTDATE as NSCopying, kEVENTACCOUNTTYPE as NSCopying, kEVENTCOUNTER as NSCopying, kEVENTUSERID as NSCopying, kEVENTGROUPID as NSCopying])
        
    }

    func saveEvent(eventID : String) {
        
        reference(.Event).document(eventDictionary[kEVENTID] as! String).setData(eventDictionary as! [String:Any])
    }

    public func updateEvent(eventID: String, eventOwnerID: String, withValues: [String:Any]) {
        reference(.Event).document(eventID).updateData(withValues)
        
//        reference(.Event).whereField(kEVENTACCOUNTTYPE, isEqualTo: "coach").getDocuments { (snapshot, error) in
//
//            guard let snapshot = snapshot else { return }
//
//            if !snapshot.isEmpty {
//
//                for event in snapshot.documents {
//
//                    let currentEvent = event.data() as NSDictionary
//
//                    self.updateEventItem(event: currentEvent)
//                }
//            }
//        }
        
    }
    
//    func updateEventItem(event: NSDictionary) {
//
//        let helper = Helper()
//
//        //let date = helper.dateFormatter().string(from: Date())
//
//        var counter = event[kEVENTCOUNTER] as! Int
//
//        if event[kEVENTOWNERID] as? String != FUser.currentId() {
//            counter += 1
//        }
//
//        let values = [kEVENTTEXT : event.eventText, kEVENTCOUNTER : eventCounter] as [String : Any]
//
//        reference(.Event).document(recent[kRECENTID] as! String).updateData(values)
//    }
    
    func clearCalendarCounter(eventGroupID: String) {
        
        reference(.Recent).whereField(kEVENTGROUPID, isEqualTo: eventID).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                for recent in snapshot.documents {
                    
                    let currentRecent = recent.data() as NSDictionary
                    
                    if currentRecent[kEVENTGROUPID] as? String == eventGroupID {
                        self.clearCalendarCounterItem(event: currentRecent)
                    }
                }
            }
        }
    }
    
    func clearCalendarCounterItem(event: NSDictionary) {
        reference(.Event).document(event[kEVENTCOUNTER] as! String).updateData([kEVENTCOUNTER : 0])
    }
    
    
}
