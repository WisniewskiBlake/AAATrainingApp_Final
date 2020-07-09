//
//  PostVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/9/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class PostVC: UIViewController {
    
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    
    // code obj
    var isPictureSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()

        loadUser()
    }
    
    // loaded after adjusting the layouts
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // rounded corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
    }
    
    // loading user
    func loadUser() {
        
        // safely accessing user related detailes ["key">"value"]
        guard let firstName = currentUser?["firstName"], let lastName = currentUser?["lastName"], let avaPath = currentUser?["ava"] else {
            return
        }
        
        // assigning accessed details to the functions which loads the user
        Helper().loadFullname(firstName: firstName as! String, lastName: lastName as! String, showIn: fullnameLabel)
        Helper().downloadImage(from: avaPath as! String, showIn: avaImageView, orShow: "user.png")
    }
    
    // tracks whenver textView gets changed
    func textViewDidChange(_ textView: UITextView) {
        
        // if textview isn't empty -> there's some text in textView, show the label, otherwise -> hide
        if textView.text.isEmpty {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }
        
    }
    

    

}
