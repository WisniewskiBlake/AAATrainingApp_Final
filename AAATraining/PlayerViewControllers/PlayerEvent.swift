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
    
    var dateString: String = ""
    let formatter = DateFormatter()
    let helper = Helper()
    var eventText: String = ""
    var event = Event()
    var accountType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.text = dateString
        textView.text = event.eventText
        if event.eventText != "" {
            placeHolderLabel.isHidden = true
        } else {
            placeHolderLabel.isHidden = false
        }
        
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
