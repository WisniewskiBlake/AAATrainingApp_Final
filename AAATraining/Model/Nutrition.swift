//
//  Nutrition.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/19/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import Foundation
import Firebase

public class Nutrition {
    var nutritionPostID: String
    var nutritionTeamID: String
    var nutritionOwnerID: String
    var nutritionText: String
    var nutritionPicture: String
    var nutritionDate: String
    var nutritionPostUserAva: String
    var nutritionPostUserName: String
    var nutritionVideo: String
    var nutritionPostType: String
    var nutritionPostUrlLink: String
    
    let nutritionPostDictionary: NSMutableDictionary
    
    init(nutritionPostID: String, nutritionTeamID: String, nutritionOwnerID: String, nutritionText: String, nutritionPicture: String, nutritionDate: String, nutritionPostUserAva: String, nutritionPostUserName: String, nutritionVideo: String, nutritionPostType: String, nutritionPostUrlLink: String) {
        
        nutritionPostDictionary = NSMutableDictionary(objects: [nutritionPostID, nutritionTeamID, nutritionOwnerID, nutritionText, nutritionPicture, nutritionPostUserAva, nutritionPostUserName, nutritionVideo, nutritionPostType, nutritionPostUrlLink], forKeys: [kNUTRITIONPOSTID as NSCopying, kNUTRITIONTEAMID as NSCopying, kNUTRITIONPOSTOWNERID as NSCopying, kNUTRITIONPOSTTEXT as NSCopying, kNUTRITIONPOSTPICTURE as NSCopying, kNUTRITIONPOSTUSERAVA as NSCopying, kNUTRITIONPOSTUSERNAME as NSCopying, kNUTRITIONPOSTVIDEO as NSCopying, kNUTRITIONPOSTTYPE as NSCopying, kNUTRITIONPOSTURLLINK as NSCopying])
        
        self.nutritionPostID = nutritionPostID
        self.nutritionTeamID = nutritionTeamID
        self.nutritionOwnerID = nutritionOwnerID
        self.nutritionText = nutritionText
        self.nutritionPicture = nutritionPicture
        self.nutritionDate = nutritionDate
        self.nutritionPostUserAva = nutritionPostUserAva
        self.nutritionPostUserName = nutritionPostUserName
        self.nutritionVideo = nutritionVideo
        self.nutritionPostType = nutritionPostType
        self.nutritionPostUrlLink = nutritionPostUrlLink
    }
    
    init(_dictionary: NSDictionary) {
       nutritionPostID = _dictionary[kNUTRITIONPOSTID] as! String
        nutritionTeamID = _dictionary[kNUTRITIONTEAMID] as! String
       nutritionOwnerID = _dictionary[kNUTRITIONPOSTOWNERID] as! String
       
       if let fname = _dictionary[kNUTRITIONPOSTUSERNAME] {
           nutritionPostUserName = fname as! String
       } else {
           nutritionPostUserName = ""
       }
       if let txt = _dictionary[kNUTRITIONPOSTTEXT] {
           nutritionText = txt as! String
       } else {
           nutritionText = ""
       }
       if let pic = _dictionary[kNUTRITIONPOSTPICTURE] {
           nutritionPicture = pic as! String
       } else {
           nutritionPicture = ""
       }
       if let dt = _dictionary[kNUTRITIONPOSTDATE] {
           nutritionDate = dt as! String
       } else {
           nutritionDate = ""
       }
        if let ava = _dictionary[kNUTRITIONPOSTUSERAVA] {
            nutritionPostUserAva = ava as! String
        } else {
            nutritionPostUserAva = ""
        }
        if let vid = _dictionary[kNUTRITIONPOSTVIDEO] {
            nutritionVideo = vid as! String
        } else {
            nutritionVideo = ""
        }
        if let tp = _dictionary[kNUTRITIONPOSTTYPE] {
            nutritionPostType = tp as! String
        } else {
            nutritionPostType = ""
        }
        if let url = _dictionary[kNUTRITIONPOSTURLLINK] {
            nutritionPostUrlLink = url as! String
        } else {
            nutritionPostUrlLink = ""
        }
        
        nutritionPostDictionary = NSMutableDictionary(objects: [nutritionPostID, nutritionTeamID, nutritionOwnerID, nutritionText, nutritionPicture, nutritionPostUserAva, nutritionPostUserName, nutritionVideo, nutritionPostType, nutritionPostUrlLink], forKeys: [kNUTRITIONPOSTID as NSCopying, kNUTRITIONTEAMID as NSCopying, kNUTRITIONPOSTOWNERID as NSCopying, kNUTRITIONPOSTTEXT as NSCopying, kNUTRITIONPOSTPICTURE as NSCopying, kNUTRITIONPOSTUSERAVA as NSCopying, kNUTRITIONPOSTUSERNAME as NSCopying, kNUTRITIONPOSTVIDEO as NSCopying, kNUTRITIONPOSTTYPE as NSCopying, kNUTRITIONPOSTURLLINK as NSCopying])
        
    }
    
    func savePost() {
        let helper = Helper()

        let date = helper.dateFormatter().string(from: Date())
        nutritionPostDictionary[kNUTRITIONPOSTDATE] = date
        reference(.Nutrition).document(nutritionPostDictionary[kNUTRITIONPOSTID] as! String).setData(nutritionPostDictionary as! [String:Any])
    }

    public func updatePost(postID: String, withValues: [String:Any]) {
        reference(.Nutrition).document(nutritionPostID).updateData(withValues)
        
    }
    
    
}
