//
//  PlayerEvent.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/7/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase
import FirebaseCore
import FirebaseFirestore

class PlayerEvent: UIViewController, UITextViewDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var eventTitleText: UITextField!
    @IBOutlet weak var eventStartText: UITextField!
    @IBOutlet weak var eventEndText: UITextField!
    @IBOutlet weak var eventEmptyLabel: UILabel!
    @IBOutlet weak var start: UILabel!
    @IBOutlet weak var end: UILabel!
    
    
    var dateString: String = ""
    let formatter = DateFormatter()
    let helper = Helper()
    var eventText: String = ""
    var eventStart: String = ""
    var eventEnd: String = ""
    var eventTitle: String = ""
    var event = Event()
    var accountType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        dateLabel.text = dateString
        textView.text = event.eventText
        
        if event.eventTitle == "" && event.eventStart == "" && event.eventEnd == "" {
            eventTitleText.isHidden = true
            eventStartText.isHidden = true
            eventEndText.isHidden = true
            start.isHidden = true
            end.isHidden = true
            placeHolderLabel.isHidden = true
            eventEmptyLabel.isHidden = false
        } else {
            eventTitleText.isHidden = false
            eventStartText.isHidden = false
            eventEndText.isHidden = false
            eventTitleText.text = event.eventTitle
            eventStartText.text = event.eventStart
            eventEndText.text = event.eventEnd
            start.isHidden = false
            end.isHidden = false
            eventEmptyLabel.isHidden = true
            if event.eventText != "" {
                placeHolderLabel.isHidden = true
            } else {
                placeHolderLabel.isHidden = false
            }
        }
        
        var bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: eventStartText.frame.height, width: eventStartText.frame.width, height: 1.0)
        bottomLine.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        eventStartText.borderStyle = UITextField.BorderStyle.none
        eventStartText.layer.addSublayer(bottomLine)
        
        var bottomLine1 = CALayer()
        bottomLine1.frame = CGRect(x: 0.0, y: eventEndText.frame.height, width: eventEndText.frame.width, height: 1.0)
        bottomLine1.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        eventEndText.borderStyle = UITextField.BorderStyle.none
        eventEndText.layer.addSublayer(bottomLine1)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
        dismiss(animated: true, completion: nil)
    }
    
    // make corners rounded for any views (objects)
    func cornerRadius(for view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
    }
    

}
