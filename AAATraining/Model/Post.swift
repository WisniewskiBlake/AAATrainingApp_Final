//
//  Post.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/27/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import Foundation
import Firebase

public class Post {
    
    var postID: String
    var postTeamID: String
    var ownerID: String
    var text: String
    var picture: String
    var date: String
    var postUserAva: String
    var postUserName: String
    var video: String
    var postType: String
    var postUrlLink: String
    
    let postDictionary: NSMutableDictionary

    init(postID: String, postTeamID: String, ownerID: String, text: String, picture: String, date: String, postUserAva: String, postUserName: String, video: String, postType: String, postUrlLink: String) {
        
        postDictionary = NSMutableDictionary(objects: [postID, postTeamID, ownerID, text, picture, postUserAva, postUserName, video, postType, postUrlLink], forKeys: [kPOSTID as NSCopying, kPOSTTEAMID as NSCopying, kPOSTOWNERID as NSCopying, kPOSTTEXT as NSCopying, kPOSTPICTURE as NSCopying, kPOSTUSERAVA as NSCopying, kPOSTUSERNAME as NSCopying, kPOSTVIDEO as NSCopying, kPOSTTYPE as NSCopying, kPOSTURLLINK as NSCopying])
        
        self.postID = postID
        self.postTeamID = postTeamID
        self.ownerID = ownerID
        self.text = text
        self.picture = picture
        self.date = date
        self.postUserAva = postUserAva
        self.postUserName = postUserName
        self.video = video
        self.postType = postType
        self.postUrlLink = postUrlLink
    }
    
    init(_dictionary: NSDictionary) {
       postID = _dictionary[kPOSTID] as! String
        postTeamID = _dictionary[kPOSTTEAMID] as! String
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
        if let vid = _dictionary[kPOSTVIDEO] {
            video = vid as! String
        } else {
            video = ""
        }
        if let tp = _dictionary[kPOSTTYPE] {
            postType = tp as! String
        } else {
            postType = ""
        }
        if let url = _dictionary[kPOSTURLLINK] {
            postUrlLink = url as! String
        } else {
            postUrlLink = ""
        }
        
        postDictionary = NSMutableDictionary(objects: [postID, postTeamID, ownerID, text, picture, postUserAva, postUserName, video, postType, postUrlLink], forKeys: [kPOSTID as NSCopying, kPOSTTEAMID as NSCopying, kPOSTOWNERID as NSCopying, kPOSTTEXT as NSCopying, kPOSTPICTURE as NSCopying, kPOSTUSERAVA as NSCopying, kPOSTUSERNAME as NSCopying, kPOSTVIDEO as NSCopying, kPOSTTYPE as NSCopying, kPOSTURLLINK as NSCopying])
        
    }

    func savePost() {
        let helper = Helper()

        let date = helper.dateFormatter().string(from: Date())
        postDictionary[kPOSTDATE] = date
        reference(.Post).document(postDictionary[kPOSTID] as! String).setData(postDictionary as! [String:Any])
    }

    public func updatePost(postID: String, withValues: [String:Any]) {
        reference(.Post).document(postID).updateData(withValues)        
        
    }
    
    
}
