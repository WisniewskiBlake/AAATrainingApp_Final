//
//  PostVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/9/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

class PostVC: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    let postID = UUID().uuidString
    
    func createPost() {
        if postTextView.text != "" {
            let fullName = FUser.currentUser()!.firstname + " " + FUser.currentUser()!.lastname
            let post = Post(postID: postID, ownerID: FUser.currentId(), text: postTextView.text, picture: "", date: "", postUserAva: FUser.currentUser()!.ava, postUserName: fullName)
            
            post.savePost()
        }
    }
    
    
    
    // code obj
    var isPictureSelected = false
    var isVideoSelected = false

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
        let helper = Helper()
        let user = FUser.currentUser()
        // safely accessing user related detailes ["key">"value"]
        guard let firstName = user?.firstname, let lastName = user?.lastname, let avaPath = user?.ava else {
            
            return
        }
        
        if avaPath != "" {
            
            helper.imageFromData(pictureData: avaPath) { (avatarImage) in
                
                if avatarImage != nil {
                    avaImageView.image = avatarImage!
                }
            }
        } else{
            avaImageView.image = UIImage(named: "user.png")
        }
        fullnameLabel.text = "\((firstName).capitalized) \((lastName).capitalized)"
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
    
    @IBAction func shareButton_clicked(_ sender: Any) {        
        createPost()
        dismiss(animated: true, completion: nil)

    }
    
    
    
    
    
    @IBAction func addPicture_clicked(_ sender: Any) {
        //showActionSheet()
    }
    
    
    
    // exec whenever the screen has been tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        postTextView.resignFirstResponder()
    }
    
    @IBAction func cancelButton_clicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
