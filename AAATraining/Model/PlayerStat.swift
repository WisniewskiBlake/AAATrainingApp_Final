//
//  PlayerStat.swift
//  AAATraining
//
//  Created by Margaret Dwan on 10/27/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

public class PlayerStat {

    var playerStatID: String
    var playerStatUserID: String
    var playerStatTeamID: String
    var playerStatHeight: String
    var playerStatWeight: String
    var playerStatPosition: String
    var playerStatNumber: String

    let playerStatDictionary: NSMutableDictionary
    
    init(playerStatID: String, playerStatUserID: String, playerStatTeamID: String, playerStatHeight: String, playerStatWeight: String, playerStatPosition: String, playerStatNumber: String) {
        
        playerStatDictionary = NSMutableDictionary(objects: [playerStatID, playerStatUserID, playerStatTeamID, playerStatHeight, playerStatWeight, playerStatPosition, playerStatNumber], forKeys: [kPLAYERSTATID as NSCopying, kPLAYERSTATUSERID as NSCopying, kPLAYERSTATTEAMID as NSCopying, kPLAYERSTATHEIGHT as NSCopying, kPLAYERSTATWEIGHT as NSCopying, kPLAYERSTATPOSITION as NSCopying, kPLAYERSTATNUMBER as NSCopying])
        
        self.playerStatID = playerStatID
        self.playerStatUserID = playerStatUserID
        self.playerStatTeamID = playerStatTeamID
        self.playerStatHeight = playerStatHeight
        self.playerStatWeight = playerStatWeight
        self.playerStatPosition = playerStatPosition
        self.playerStatNumber = playerStatNumber
        
    }
    
    init(_dictionary: NSDictionary) {
       
        playerStatID = _dictionary[kPLAYERSTATID] as! String
       
       if let sid = _dictionary[kPLAYERSTATUSERID] {
            playerStatUserID = sid as! String
       } else {
            playerStatUserID = ""
       }
       if let stid = _dictionary[kPLAYERSTATTEAMID] {
            playerStatTeamID = stid as! String
       } else {
            playerStatTeamID = ""
       }
       if let sH = _dictionary[kPLAYERSTATHEIGHT] {
            playerStatHeight = sH as! String
       } else {
            playerStatHeight = ""
       }
       if let sW = _dictionary[kPLAYERSTATWEIGHT] {
            playerStatWeight = sW as! String
       } else {
            playerStatWeight = ""
       }
       if let sP = _dictionary[kPLAYERSTATPOSITION] {
            playerStatPosition = sP as! String
       } else {
            playerStatPosition = ""
       }
       if let sN = _dictionary[kPLAYERSTATNUMBER] {
            playerStatNumber = sN as! String
       } else {
            playerStatNumber = ""
       }
               
        playerStatDictionary = NSMutableDictionary(objects: [playerStatID, playerStatUserID, playerStatTeamID, playerStatHeight, playerStatWeight, playerStatPosition, playerStatNumber], forKeys: [kPLAYERSTATID as NSCopying, kPLAYERSTATUSERID as NSCopying, kPLAYERSTATTEAMID as NSCopying, kPLAYERSTATHEIGHT as NSCopying, kPLAYERSTATWEIGHT as NSCopying, kPLAYERSTATPOSITION as NSCopying, kPLAYERSTATNUMBER as NSCopying])
       
    }
    
    func getStats(teamID: String, completion: @escaping (_ team: PlayerStat) -> Void) {
        
        reference(.PlayerStat).document(teamID).getDocument { (snapshot, error) in
            
            guard let snapshot = snapshot else {  return }
            
            if snapshot.exists {
                
                let stats = PlayerStat(_dictionary: snapshot.data()! as NSDictionary)
                
                completion(stats)
                
                
            } else {
                let stats = PlayerStat(playerStatID: "", playerStatUserID: "", playerStatTeamID: "", playerStatHeight: "", playerStatWeight: "", playerStatPosition: "", playerStatNumber: "")
                
                completion(stats)
            }
            
            
            
        }
    }
    
    func saveStats() {
        reference(.PlayerStat).document(playerStatDictionary[kPLAYERSTATID] as! String).setData(playerStatDictionary as! [String:Any])        
    }
    
    func updateStats(playerStatID: String, withValues: [String:Any]) {
        reference(.PlayerStat).document(playerStatID).updateData(withValues)
    }
    

    
}
