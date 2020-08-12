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
        
    let baselineDictionary: NSMutableDictionary

    init(baselineID: String, baselineOwnerID: String, height: String, weight: String, wingspan: String, vertical: String, yardDash: String, agility: String, pushUp: String, chinUp: String, mileRun: String, baselineDate: String) {

        baselineDictionary = NSMutableDictionary(objects: [baselineID, baselineOwnerID, height, weight, wingspan, vertical, yardDash, agility, pushUp, chinUp, mileRun], forKeys: [kBASELINEID as NSCopying, kBASELINEOWNERID as NSCopying, kBASELINEHEIGHT as NSCopying, kBASELINEWEIGHT as NSCopying, kWINGSPAN as NSCopying, kVERTICAL as NSCopying, kYARDDASH as NSCopying, kAGILITY as NSCopying, kPUSHUP as NSCopying, kCHINUP as NSCopying, kMILERUN as NSCopying])
        
        self.baselineID = baselineID
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
    }
    
    init(_dictionary: NSDictionary) {
       //let helper = Helper()
       baselineID = _dictionary[kBASELINEID] as! String
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
        
        
        baselineDictionary = NSMutableDictionary(objects: [baselineID, baselineOwnerID, height, weight, wingspan, vertical, agility, pushUp, chinUp, vertical, mileRun], forKeys: [kBASELINEID as NSCopying, kBASELINEOWNERID as NSCopying, kBASELINEHEIGHT as NSCopying, kBASELINEWEIGHT as NSCopying, kWINGSPAN as NSCopying, kYARDDASH as NSCopying, kAGILITY as NSCopying, kPUSHUP as NSCopying, kCHINUP as NSCopying, kMILERUN as NSCopying])
        
    }
    
    func saveBaseline() {
        let helper = Helper()

        let date = helper.dateFormatter().string(from: Date())
        baselineDictionary[kBASELINEDATE] = date
        reference(.Baseline).document(baselineDictionary[kBASELINEDATE] as! String).setData(baselineDictionary as! [String:Any])
    }

    public func updateBaseline(baselineID: String, withValues: [String:Any]) {
        reference(.Baseline).document(baselineID).updateData(withValues)
        
    }
    
}
