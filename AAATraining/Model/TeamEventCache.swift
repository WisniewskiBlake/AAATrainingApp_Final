//
//  TeamEventCache.swift
//  AAATraining
//
//  Created by Margaret Dwan on 9/24/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import Foundation
import Firebase

public class TeamEventCache {
    var eventID: String
    var eventTeamID: String
    var eventOwnerID: String
    var eventText: String
    var eventDate: String
    var eventAccountType: String
    var eventCounter: Int
    var eventUserID: String
    var eventGroupID: String
    var eventTitle: String
    var eventStart: String
    var eventEnd: String
    var dateForUpcomingComparison: String
    var eventLocation: String
    var eventImage: String
    var eventURL: String
    
    
    let eventDictionary: NSMutableDictionary
    
    init() {
        eventID = ""
        eventTeamID = ""
        eventOwnerID = ""
        eventText = ""
        eventDate = ""
        eventAccountType = ""
        eventCounter = 0
        eventUserID = ""
        eventGroupID = ""
        eventTitle = ""
        eventStart = ""
        eventEnd = ""
        dateForUpcomingComparison = ""
        eventLocation = ""
        eventImage = ""
        eventURL = ""
        
        eventDictionary = NSMutableDictionary(objects: [eventGroupID, eventID, eventTeamID, eventOwnerID, eventText, eventDate, eventAccountType, eventCounter, eventUserID, eventTitle, eventStart, eventEnd, dateForUpcomingComparison, eventLocation, eventImage, eventURL], forKeys: [kEVENTGROUPID as NSCopying, kEVENTID as NSCopying, kEVENTTEAMID as NSCopying, kEVENTOWNERID as NSCopying, kEVENTTEXT as NSCopying, kEVENTDATE as NSCopying, kEVENTACCOUNTTYPE as NSCopying, kEVENTCOUNTER as NSCopying, kEVENTUSERID as NSCopying, kEVENTTITLE as NSCopying, kEVENTSTART as NSCopying, kEVENTEND as NSCopying, kEVENTDATEFORUPCOMINGCOMPARISON as NSCopying, kEVENTLOCATION as NSCopying, kEVENTIMAGE as NSCopying, kEVENTURL as NSCopying])
    }

    init(eventGroupID: String, eventID: String, eventTeamID: String, eventOwnerID: String, eventText: String, eventDate: String, eventAccountType: String, eventCounter: Int, eventUserID: String, eventTitle: String, eventStart: String, eventEnd: String, dateForUpcomingComparison: String, eventLocation: String, eventImage: String, eventURL: String) {

        eventDictionary = NSMutableDictionary(objects: [eventGroupID, eventID, eventTeamID, eventOwnerID, eventText, eventDate, eventAccountType, eventCounter, eventUserID, eventTitle, eventStart, eventEnd, dateForUpcomingComparison, eventLocation, eventImage, eventURL], forKeys: [kEVENTGROUPID as NSCopying, kEVENTID as NSCopying, kEVENTTEAMID as NSCopying, kEVENTOWNERID as NSCopying, kEVENTTEXT as NSCopying, kEVENTDATE as NSCopying, kEVENTACCOUNTTYPE as NSCopying, kEVENTCOUNTER as NSCopying, kEVENTUSERID as NSCopying, kEVENTTITLE as NSCopying, kEVENTSTART as NSCopying, kEVENTEND as NSCopying, kEVENTDATEFORUPCOMINGCOMPARISON as NSCopying, kEVENTLOCATION as NSCopying, kEVENTIMAGE as NSCopying, kEVENTURL as NSCopying])
        
        self.eventGroupID = eventGroupID
        self.eventID = eventID
        self.eventTeamID = eventTeamID
        self.eventOwnerID = eventOwnerID
        self.eventText = eventText
        self.eventDate = eventDate
        self.eventAccountType = eventAccountType
        self.eventCounter = eventCounter
        self.eventUserID = eventUserID
        self.eventTitle = eventTitle
        self.eventStart = eventStart
        self.eventEnd = eventEnd
        self.dateForUpcomingComparison = dateForUpcomingComparison
        self.eventLocation = eventLocation
        self.eventImage = eventImage
        self.eventURL = eventURL
    }
    
    init(_dictionary: NSDictionary) {
        
        if let egID = _dictionary[kEVENTGROUPID] {
            eventGroupID = egID as! String
        } else {
            eventGroupID = ""
        }
        
       //let helper = Helper()
       eventID = _dictionary[kEVENTID] as! String
       eventOwnerID = _dictionary[kEVENTOWNERID] as! String
       eventTeamID = _dictionary[kEVENTTEAMID] as! String
       
       
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
        if let eT = _dictionary[kEVENTTITLE] {
            eventTitle = eT as! String
        } else {
            eventTitle = ""
        }
        if let eS = _dictionary[kEVENTSTART] {
            eventStart = eS as! String
        } else {
            eventStart = ""
        }
        if let eE = _dictionary[kEVENTEND] {
            eventEnd = eE as! String
        } else {
            eventEnd = ""
        }
        if let dC = _dictionary[kEVENTDATEFORUPCOMINGCOMPARISON] {
            dateForUpcomingComparison = dC as! String
        } else {
            dateForUpcomingComparison = ""
        }
        if let eL = _dictionary[kEVENTLOCATION] {
            eventLocation = eL as! String
        } else {
            eventLocation = ""
        }
        if let eI = _dictionary[kEVENTIMAGE] {
            eventImage = eI as! String
        } else {
            eventImage = ""
        }
        if let eU = _dictionary[kEVENTURL] {
            eventURL = eU as! String
        } else {
            eventURL = ""
        }
        
       
        
        eventDictionary = NSMutableDictionary(objects: [eventGroupID, eventID, eventTeamID, eventOwnerID, eventText, eventDate, eventAccountType, eventCounter, eventUserID, eventTitle, eventStart, eventEnd, dateForUpcomingComparison, eventLocation, eventImage, eventURL], forKeys: [kEVENTGROUPID as NSCopying, kEVENTID as NSCopying, kEVENTTEAMID as NSCopying, kEVENTOWNERID as NSCopying, kEVENTTEXT as NSCopying, kEVENTDATE as NSCopying, kEVENTACCOUNTTYPE as NSCopying, kEVENTCOUNTER as NSCopying, kEVENTUSERID as NSCopying, kEVENTTITLE as NSCopying, kEVENTSTART as NSCopying, kEVENTEND as NSCopying, kEVENTDATEFORUPCOMINGCOMPARISON as NSCopying, kEVENTLOCATION as NSCopying, kEVENTIMAGE as NSCopying, kEVENTURL as NSCopying])
        
    }


    public func updateTeamEvent(eventGroupID: String, eventOwnerID: String, eventText : String, eventTitle: String, eventStart: String, eventEnd: String, eventLocation: String, eventImage: String, eventURL: String) {
        reference(.Event).whereField(kEVENTGROUPID, isEqualTo: eventGroupID).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                for recent in snapshot.documents {
                    
                    let currentRecent = recent.data() as NSDictionary
                    
                    self.updateTeamEventItem(event: currentRecent, eventText: eventText, eventTitle: eventTitle, eventStart: eventStart, eventEnd: eventEnd, eventLocation: eventLocation, eventImage: eventImage, eventURL: eventURL)
                }
            }
        }
        
    }
    
    func updateTeamEventItem(event: NSDictionary, eventText: String, eventTitle: String, eventStart: String, eventEnd: String, eventLocation: String, eventImage: String, eventURL: String) {

        var counter = event[kEVENTCOUNTER] as! Int

        if event[kEVENTUSERID] as? String != FUser.currentId() {
            counter += 1
        }

        let values = [kEVENTTEXT : eventText, kEVENTCOUNTER : counter, kEVENTTITLE : eventTitle, kEVENTSTART : eventStart, kEVENTEND : eventEnd] as [String : Any]

        reference(.Event).document(event[kEVENTID] as! String).updateData(values)
    }
    
    
}
