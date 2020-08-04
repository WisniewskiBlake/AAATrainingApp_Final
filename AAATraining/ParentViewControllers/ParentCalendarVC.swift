//
//  ParentCalendarVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/3/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import FSCalendar
import Firebase
import FirebaseFirestore
import ProgressHUD

class ParentCalendarVC: UIViewController, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    @IBOutlet weak var calendar: FSCalendar!
    
    var allEvents: [Event] = []
    var recentListener: ListenerRegistration!
    var allEventDates: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    


}
