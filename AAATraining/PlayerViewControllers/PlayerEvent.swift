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
    var updateNeeded: Bool = false
    var eventID: String = ""
    var event = Event()
    var accountType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    

}
