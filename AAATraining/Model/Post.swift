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
    let postDictionary: NSMutableDictionary

    init(postID: String, ownerID: String, text: String, picture: String, date: String) {

        postDictionary = NSMutableDictionary(objects: [postID, ownerID, text, picture], forKeys: [kPOSTID as NSCopying, kPOSTOWNERID as NSCopying, kPOSTTEXT as NSCopying, kPOSTPICTURE as NSCopying])
    }

    func savePost() {
        let helper = Helper()

        let date = helper.dateFormatter().string(from: Date())
        postDictionary[kPOSTDATE] = date
        reference(.Post).document(postDictionary[kPOSTID] as! String).setData(postDictionary as! [String:Any])
    }

    class func updatePost(postID: String, withValues: [String:Any]) {
        reference(.Post).document(postID).updateData(withValues)
    }
}
