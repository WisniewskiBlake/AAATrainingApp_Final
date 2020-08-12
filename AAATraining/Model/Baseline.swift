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
    var ownerID: String
    var height: String
    var weight: String
    var wingspan: String
    var vertical: String
    var yardDash: String
    var agility: String
    var pushUp: String
    var chinUp: String
    var mileRun: String
    var date: String
        
    let baselineDictionary: NSMutableDictionary

    init(baselineID: String, ownerID: String, height: String, weight: String, wingspan: String, vertical: String, yardDash: String, agility: String, pushUp: String, chinUp: String, mileRun: String, date: String) {

        postDictionary = NSMutableDictionary(objects: [postID, ownerID, text, picture, postUserAva, postUserName], forKeys: [kPOSTID as NSCopying, kPOSTOWNERID as NSCopying, kPOSTTEXT as NSCopying, kPOSTPICTURE as NSCopying, kPOSTUSERAVA as NSCopying, kPOSTUSERNAME as NSCopying])
        
        self.postID = postID
        self.ownerID = ownerID
        self.text = text
        self.picture = picture
        self.date = date
        self.postUserAva = postUserAva
        self.postUserName = postUserName
    }
    
    init(_dictionary: NSDictionary) {
        
        
       //let helper = Helper()
       postID = _dictionary[kPOSTID] as! String
        ownerID = _dictionary[kOWNERID] as! String
       
       
       if let fname = _dictionary[kPOSTUSERNAME] {
           postUserName = fname as! String
       } else {
           postUserName = ""
       }
       if let txt = _dictionary[kPOSTTEXT] {
           text = txt as! String
       } else {
           text = ""
       }
       if let pic = _dictionary[kPOSTPICTURE] {
           picture = pic as! String
       } else {
           picture = ""
       }
       if let dt = _dictionary[kPOSTDATE] {
           date = dt as! String
       } else {
           date = ""
       }
        if let ava = _dictionary[kPOSTUSERAVA] {
            postUserAva = ava as! String
        } else {
            postUserAva = ""
        }
        
        postDictionary = NSMutableDictionary(objects: [postID, ownerID, text, picture, postUserAva, postUserName], forKeys: [kPOSTID as NSCopying, kPOSTOWNERID as NSCopying, kPOSTTEXT as NSCopying, kPOSTPICTURE as NSCopying, kPOSTUSERAVA as NSCopying, kPOSTUSERNAME as NSCopying])
        
    }
    
}
