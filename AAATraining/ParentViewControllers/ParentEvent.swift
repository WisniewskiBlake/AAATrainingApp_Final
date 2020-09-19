//
//  ParentEvent.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/8/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase
import FirebaseCore
import FirebaseFirestore

class ParentEvent: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {    

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var eventTitleText: UITextField!
    @IBOutlet weak var eventStartText: UITextField!
    @IBOutlet weak var eventEndText: UITextField!
    @IBOutlet weak var start: UILabel!
    @IBOutlet weak var end: UILabel!
    @IBOutlet weak var noEventsLabel: UILabel!
    
    
    
    var dateString: String = ""
    let formatter = DateFormatter()
    let helper = Helper()
    var eventText: String = ""
    var event = Event()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        dateLabel.text = dateString
        textView.text = event.eventText
        
        if event.eventTitle == "" && event.eventStart == "" && event.eventEnd == "" {
            eventTitleText.isHidden = true
            eventStartText.isHidden = true
            eventEndText.isHidden = true
            start.isHidden = true
            end.isHidden = true
            placeHolderLabel.isHidden = true
            noEventsLabel.isHidden = false
        } else {
            eventTitleText.isHidden = false
            eventStartText.isHidden = false
            eventEndText.isHidden = false
            eventTitleText.text = event.eventTitle
            eventStartText.text = event.eventStart
            eventEndText.text = event.eventEnd
            start.isHidden = false
            end.isHidden = false
            noEventsLabel.isHidden = true
            if event.eventText != "" {
                placeHolderLabel.isHidden = true
            } else {
                placeHolderLabel.isHidden = false
            }
        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
        dismiss(animated: true, completion: nil)
    }
    
    

}
