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
    
    
    
    let eventDictionary: NSMutableDictionary

    init(eventID: String, eventOwnerID: String, eventText: String, eventDate: String, eventAccountType: String) {

        eventDictionary = NSMutableDictionary(objects: [eventID, eventOwnerID, eventText, eventDate, eventAccountType], forKeys: [kEVENTID as NSCopying, kEVENTOWNERID as NSCopying, kEVENTTEXT as NSCopying, kEVENTDATE as NSCopying, kEVENTACCOUNTTYPE as NSCopying])
        
        self.eventID = eventID
        self.eventOwnerID = eventOwnerID
        self.eventText = eventText
        self.eventDate = eventDate
        self.eventAccountType = eventAccountType
        
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
       
        
        eventDictionary = NSMutableDictionary(objects: [eventID, eventOwnerID, eventText, eventDate, eventAccountType], forKeys: [kEVENTID as NSCopying, kEVENTOWNERID as NSCopying, kEVENTTEXT as NSCopying, kEVENTDATE as NSCopying, kEVENTACCOUNTTYPE as NSCopying])
        
    }

    func saveEvent() {
        
        reference(.Event).document(eventDictionary[kEVENTID] as! String).setData(eventDictionary as! [String:Any])
    }

    public func updatePost(postID: String, withValues: [String:Any]) {
        reference(.Event).document(eventID).updateData(withValues)
        
        
    }
    
    
}
