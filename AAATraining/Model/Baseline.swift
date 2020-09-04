//
//  Baseline.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/11/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import Foundation
import Firebase

public class Baseline {
    var baselineID: String
    var baselineTeamID: String
    var baselineOwnerID: String
    var height: String
    var weight: String
    var wingspan: String
    var vertical: String
    var yardDash: String
    var agility: String
    var pushUp: String
    var chinUp: String
    var mileRun: String
    var baselineDate: String
    var userName: String
        
    let baselineDictionary: NSMutableDictionary

    init(baselineID: String, baselineTeamID: String, baselineOwnerID: String, height: String, weight: String, wingspan: String, vertical: String, yardDash: String, agility: String, pushUp: String, chinUp: String, mileRun: String, baselineDate: String, userName: String) {

        baselineDictionary = NSMutableDictionary(objects: [baselineID, baselineTeamID, baselineOwnerID, height, weight, wingspan, vertical, yardDash, agility, pushUp, chinUp, mileRun, baselineDate, userName], forKeys: [kBASELINEID as NSCopying, kBASELINETEAMID as NSCopying, kBASELINEOWNERID as NSCopying, kBASELINEHEIGHT as NSCopying, kBASELINEWEIGHT as NSCopying, kWINGSPAN as NSCopying, kVERTICAL as NSCopying, kYARDDASH as NSCopying, kAGILITY as NSCopying, kPUSHUP as NSCopying, kCHINUP as NSCopying, kMILERUN as NSCopying, kBASELINEDATE as NSCopying, kBASELINEUSERNAME as NSCopying])
        
        self.baselineID = baselineID
        self.baselineTeamID = baselineTeamID
        self.baselineOwnerID = baselineOwnerID
        self.height = height
        self.weight = weight
        self.wingspan = wingspan
        self.vertical = vertical
        self.yardDash = yardDash
        self.agility = agility
        self.pushUp = pushUp
        self.chinUp = chinUp
        self.mileRun = mileRun
        self.baselineDate = baselineDate
        self.userName = userName
        
    }
    
    init() {
        baselineID = ""
        baselineTeamID = ""
        baselineOwnerID = ""
        height = ""
        weight = ""
        wingspan = ""
        vertical = ""
        yardDash = ""
        agility = ""
        pushUp = ""
        chinUp = ""
        mileRun = ""
        baselineDate = ""
        userName = ""
        
        baselineDictionary = NSMutableDictionary(objects: [baselineID, baselineTeamID, baselineOwnerID, height, weight, wingspan, vertical, yardDash, agility, pushUp, chinUp, mileRun, baselineDate, userName], forKeys: [kBASELINEID as NSCopying, kBASELINETEAMID as NSCopying, kBASELINEOWNERID as NSCopying, kBASELINEHEIGHT as NSCopying, kBASELINEWEIGHT as NSCopying, kWINGSPAN as NSCopying, kVERTICAL as NSCopying, kYARDDASH as NSCopying, kAGILITY as NSCopying, kPUSHUP as NSCopying, kCHINUP as NSCopying, kMILERUN as NSCopying, kBASELINEDATE as NSCopying, kBASELINEUSERNAME as NSCopying])
    }
    
    
    init(_dictionary: NSDictionary) {
       //let helper = Helper()
       baselineID = _dictionary[kBASELINEID] as! String
       baselineTeamID = _dictionary[kBASELINETEAMID] as! String
       baselineOwnerID = _dictionary[kBASELINEOWNERID] as! String
       
       if let ht = _dictionary[kBASELINEHEIGHT] {
           height = ht as! String
       } else {
           height = ""
       }
       if let wt = _dictionary[kBASELINEWEIGHT] {
           weight = wt as! String
       } else {
           weight = ""
       }
       if let wg = _dictionary[kWINGSPAN] {
           wingspan = wg as! String
       } else {
           wingspan = ""
       }
       if let vt = _dictionary[kVERTICAL] {
           vertical = vt as! String
       } else {
           vertical = ""
       }
        if let yd = _dictionary[kYARDDASH] {
            yardDash = yd as! String
        } else {
            yardDash = ""
        }
        if let ag = _dictionary[kAGILITY] {
            agility = ag as! String
        } else {
            agility = ""
        }
        if let pu = _dictionary[kPUSHUP] {
            pushUp = pu as! String
        } else {
            pushUp = ""
        }
        if let cu = _dictionary[kCHINUP] {
            chinUp = cu as! String
        } else {
            chinUp = ""
        }
        if let mr = _dictionary[kMILERUN] {
            mileRun = mr as! String
        } else {
            mileRun = ""
        }
        if let bd = _dictionary[kBASELINEDATE] {
            baselineDate = bd as! String
        } else {
            baselineDate = ""
        }
        if let un = _dictionary[kBASELINEUSERNAME] {
            userName = un as! String
        } else {
            userName = ""
        }
        
        
        
        
        baselineDictionary = NSMutableDictionary(objects: [baselineID, baselineTeamID, baselineTeamID, baselineOwnerID, height, weight, wingspan, vertical, agility, yardDash, pushUp, chinUp, mileRun, baselineDate, userName], forKeys: [kBASELINEID as NSCopying, kBASELINETEAMID as NSCopying, kBASELINEOWNERID as NSCopying, kBASELINEHEIGHT as NSCopying, kBASELINEWEIGHT as NSCopying, kWINGSPAN as NSCopying, kVERTICAL as NSCopying, kAGILITY as NSCopying, kYARDDASH as NSCopying, kPUSHUP as NSCopying, kCHINUP as NSCopying, kMILERUN as NSCopying, kBASELINEDATE as NSCopying, kBASELINEUSERNAME as NSCopying])
        
    }

    func updateBaseline(baselineID: String, baseline: NSDictionary, height: String, weight: String, wingspan: String, vertical: String, yardDash: String, agility: String, pushUp: String, chinUp: String, mileRun: String) {

        reference(.Baseline).whereField(kBASELINEID, isEqualTo: baselineID).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                for recent in snapshot.documents {
                    
                    let currentRecent = recent.data() as NSDictionary
                    
                    self.updateBaselineItem(baseline: currentRecent, height: height, weight: weight, wingspan: wingspan, vertical: vertical, yardDash: yardDash, agility: agility, pushUp: pushUp, chinUp: chinUp, mileRun: mileRun)
                }
            }
        }
    }
    
    func updateBaselineItem(baseline: NSDictionary, height: String, weight: String, wingspan: String, vertical: String, yardDash: String, agility: String, pushUp: String, chinUp: String, mileRun: String) {
        
        let values = [kBASELINEHEIGHT : height, kBASELINEWEIGHT : weight, kWINGSPAN : wingspan, kVERTICAL : vertical, kAGILITY : agility, kYARDDASH : yardDash, kPUSHUP : pushUp, kCHINUP : chinUp, kMILERUN : mileRun] as [String : Any]
        
        reference(.Baseline).document(baseline[kBASELINEID] as! String).updateData(values)
    }
    
}
