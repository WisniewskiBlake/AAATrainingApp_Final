//
//  Event_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/28/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase
import FirebaseCore
import FirebaseFirestore

class Event_Coach: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    var date = Date()
    let formatter = DateFormatter()
    let helper = Helper()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        formatter.dateFormat = "EEEE, MM-dd-YYYY"
        //formatter.dateFormat = "MM-dd-YYYY"
        let string = formatter.string(from: date)
        dateLabel.text = string
    }
    
    func createEvent() {
        let eventText = textView.text
        let eventID = UUID().uuidString
        let eventOwnerID = FUser.currentId()
        let eventAccountType = FUser.currentUser()?.accountType
        let eventDate = helper.dateFormatter().string(from: Date())
        let event = Event(eventID: eventID, eventOwnerID: eventOwnerID, eventText: eventText!, eventDate: dateLabel.text!, eventAccountType: eventAccountType!)
        
        event.saveEvent()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createEvent"), object: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if textView.text != "" {
            createEvent()
        } else {
            helper.showAlert(title: "Data Error", message: "Please fill in info.", in: self)
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeHolderLabel.isHidden = false
        }
        else {
            placeHolderLabel.isHidden = true
        }
    }
    
    
    // exec whenever the screen has been tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.resignFirstResponder()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

}
