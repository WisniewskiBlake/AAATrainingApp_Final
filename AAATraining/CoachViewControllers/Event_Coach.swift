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
    @IBOutlet weak var deleteButton: UIButton!
    
    var dateString: String = ""
    let formatter = DateFormatter()
    let helper = Helper()
    var eventText: String = ""
    var updateNeeded: Bool = false
    var eventID: String = ""
    var event = Event()
    var accountType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cornerRadius(for: deleteButton)

        dateLabel.text = dateString
        textView.text = event.eventText
        if event.eventText != "" {
            placeHolderLabel.isHidden = true
        } else {
            placeHolderLabel.isHidden = false
        }
        if updateNeeded == true {
            deleteButton.isHidden = false
            self.navigationItem.rightBarButtonItem?.title = "Update"
        } else {
            deleteButton.isHidden = true
        }
        
    }
    
    func createEvent() {
        let eventText = textView.text
        
        if updateNeeded == true {

            event.updateEvent(eventID: eventID, withValues: [kEVENTTEXT : eventText!])
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createEvent"), object: nil)
        } else {
            let eventID = UUID().uuidString
            let eventOwnerID = FUser.currentId()
            let eventAccountType = FUser.currentUser()?.accountType
            //let eventDate = helper.dateFormatter().string(from: Date())
            let event = Event(eventID: eventID, eventOwnerID: eventOwnerID, eventText: eventText!, eventDate: dateString, eventAccountType: eventAccountType!)
            event.saveEvent()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createEvent"), object: nil)
        }
        
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        reference(.Event).document(eventID).delete()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deleteEvent"), object: nil)
        dismiss(animated: true, completion: nil)
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
    
    // make corners rounded for any views (objects)
    func cornerRadius(for view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
    }
    

}
