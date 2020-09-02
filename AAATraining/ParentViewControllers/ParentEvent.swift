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
    
    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    var dateString: String = ""
    let formatter = DateFormatter()
    let helper = Helper()
    var eventText: String = ""
    var event = Event()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
        dateLabel.text = dateString
        textView.text = event.eventText
        if event.eventText != "" {
            placeHolderLabel.isHidden = true
        } else {
            placeHolderLabel.isHidden = false
        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
        dismiss(animated: true, completion: nil)
    }
    
    

}
