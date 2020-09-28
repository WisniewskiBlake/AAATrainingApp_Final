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

class Event_Coach: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
//    @IBOutlet weak var dateText: UITextField!
    

    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var eventTitleText: UITextField!
//    @IBOutlet weak var eventStartText: UITextField!
//    @IBOutlet weak var eventEndText: UITextField!
    
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var navView: UIView!
    var dateFormatter = DateFormatter()
      
    var memberIds: [String] = []
    var allMembers: [FUser] = []
    
    var dateString: String = ""
    let formatter = DateFormatter()
    let helper = Helper()
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    var updateNeeded: Bool = false
    
    var event = Event()
    var accountType = ""
    
    var allEventsWithGroupID: [Event] = []
    
    //var dateForUpcomingComparison: String = ""
    //var datePicker = UIDatePicker()
    let eventDatePicker = UIDatePicker()
    
    var index = 0
    var isNewObserverValue: String = ""
    var imageview = UIImageView()
    
    let startTapGestureRecognizer = UITapGestureRecognizer()
    let endTapGestureRecognizer = UITapGestureRecognizer()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if #available(iOS 14, *) {
//            datePicker.preferredDatePickerStyle = .compact
//            datePicker.sizeToFit()
//            createStartiOS14Picker()
//            createEndiOS14Picker()
//
//        } else {
//            createStartDatePicker()
//            createEndDatePicker()
//            createEventDatePicker()
//        }
        
        do {
            let gif = try UIImage(gifName: "loaderFinal.gif")
            imageview = UIImageView(gifImage: gif, loopCount: -1) // Will loop 3 times
            imageview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageview)
            let widthConstraint = NSLayoutConstraint(item: imageview, attribute: .width, relatedBy: .equal,
                                                     toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 250)

            let heightConstraint = NSLayoutConstraint(item: imageview, attribute: .height, relatedBy: .equal,
                                                      toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 250)

            let xConstraint = NSLayoutConstraint(item: imageview, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)

            let yConstraint = NSLayoutConstraint(item: imageview, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)

            NSLayoutConstraint.activate([widthConstraint, heightConstraint, xConstraint, yConstraint])
        } catch {
            print(error)
        }
        self.imageview.startAnimatingGif()
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
        self.navView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
        getAllMembers()
        getAllEvents()
        configureUI()
        
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        

//        dateText.text = dateString
        textView.text = event.eventText
        eventTitleText.text = event.eventTitle
//        eventStartText.text = event.eventStart
//        eventEndText.text = event.eventEnd
        
        if event.eventText != "" {
            placeHolderLabel.isHidden = true
        } else {
            placeHolderLabel.isHidden = false
        }
        if updateNeeded == true {
            deleteButton.isHidden = false
            self.doneButton.setTitle("Update", for: .normal)
            
        } else {
            deleteButton.isHidden = true
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
    }
    
    func createEvent(eventOwnerID: String, eventTeamID: String, eventText: String, eventDate: String, eventAccountType: String, eventUserID: String, eventGroupID: String, eventTitle: String, eventStart: String, eventEnd: String, upcomingCompar: String, eventLocation: String, eventImage: String, eventURL: String) {
        let localReference = reference(.Event).document()
        let eventId = localReference.documentID
        var event: [String : Any]!
        var eventCounter = 0
        
        if eventUserID != eventOwnerID {
            eventCounter = 1
        }
        
        
        event = [kEVENTID: eventId, kEVENTTEAMID: eventTeamID, kEVENTOWNERID: FUser.currentId(), kEVENTTEXT: eventText, kEVENTDATE: eventDate, kEVENTACCOUNTTYPE: eventAccountType, kEVENTCOUNTER: eventCounter, kEVENTUSERID: eventUserID, kEVENTGROUPID: eventGroupID, kEVENTTITLE: eventTitle, kEVENTSTART: eventStart, kEVENTEND: eventEnd, kEVENTDATEFORUPCOMINGCOMPARISON: upcomingCompar, kEVENTLOCATION: eventLocation, kEVENTIMAGE: eventImage, kEVENTURL: eventURL] as [String:Any]
        
        localReference.setData(event)
        
    }
    
    func createTeamEvent(eventOwnerID: String, eventTeamID: String, eventText: String, eventDate: String, eventAccountType: String, eventUserID: String, eventGroupID: String, eventTitle: String, eventStart: String, eventEnd: String, upcomingCompar: String, eventLocation: String, eventImage: String, eventURL: String) {
        let localReference = reference(.TeamEventCache).document(eventGroupID)
        let eventId = localReference.documentID
        var event: [String : Any]!
        var eventCounter = 0
        
        event = [kEVENTGROUPID: eventGroupID, kEVENTID: eventId, kEVENTTEAMID: eventTeamID, kEVENTOWNERID: FUser.currentId(), kEVENTTEXT: eventText, kEVENTDATE: eventDate, kEVENTACCOUNTTYPE: eventAccountType, kEVENTCOUNTER: 0, kEVENTUSERID: "", kEVENTTITLE: eventTitle, kEVENTSTART: eventStart, kEVENTEND: eventEnd, kEVENTDATEFORUPCOMINGCOMPARISON: upcomingCompar, kEVENTLOCATION: eventLocation, kEVENTIMAGE: eventImage, kEVENTURL: eventURL] as [String:Any]
        
        localReference.setData(event)
        
    }
    
    //get all events with the same teamID as current user, sort by event id and create new events for current user. The number of new events to be created will be determined by how many indexes in until the next eventUserID starts
    
    func createEventForMembers(start: String, end: String, fullDate: String, upcomingCompar: String) {
        if self.memberIds.isEmpty {
            self.memberIds.append(FUser.currentId())
        }
        var tempMembers = memberIds
        let eventText = textView.text!
        let eventOwnerID = FUser.currentId()
        let eventAccountType = "Coach"
        let eventGroupID = UUID().uuidString
        let eventTitle = eventTitleText.text!
        let eventStart = start
        let eventEnd = end
        
        

            
            
            for userId in tempMembers {
                self.createEvent(eventOwnerID: eventOwnerID, eventTeamID: FUser.currentUser()!.userCurrentTeamID, eventText: eventText, eventDate: fullDate, eventAccountType: eventAccountType, eventUserID: userId, eventGroupID: eventGroupID, eventTitle: eventTitle, eventStart: eventStart, eventEnd: eventEnd, upcomingCompar: upcomingCompar, eventLocation: "", eventImage: "", eventURL: "")

            }
        self.createTeamEvent(eventOwnerID: eventOwnerID, eventTeamID: FUser.currentUser()!.userCurrentTeamID, eventText: eventText, eventDate: fullDate, eventAccountType: eventAccountType, eventUserID: "", eventGroupID: eventGroupID, eventTitle: eventTitle, eventStart: eventStart, eventEnd: eventEnd, upcomingCompar: upcomingCompar, eventLocation: "", eventImage: "", eventURL: "")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createEvent"), object: nil)
            //sleep(UInt32(0.6))
        
        //}
    }
    
    func getAllMembers() {
   
        reference(.User).whereField(kUSERTEAMIDS, arrayContains: FUser.currentUser()!.userCurrentTeamID).getDocuments { (snapshot, error) in
              self.memberIds = []
            guard let snapshot = snapshot else { return }

            self.index = 0
            self.isNewObserverValue = ""
            self.memberIds = []
            
            if !snapshot.isEmpty {

                for userDictionary in snapshot.documents {

                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    
                    let userTeamIDArray = fUser.userTeamIDs
                    let userIsNewObserverArray = fUser.userIsNewObserverArray
                    
                    self.index = userTeamIDArray.firstIndex(of: FUser.currentUser()!.userCurrentTeamID)!
                    self.isNewObserverValue = fUser.userIsNewObserverArray[self.index]
                    
                    if self.isNewObserverValue == "No" {
                        self.memberIds.append(fUser.objectId)
                    }

                    

                }
            }
        }
    }
    
    func getAllEvents() {
        reference(.Event).whereField(kEVENTGROUPID, isEqualTo: event.eventGroupID).getDocuments { (snapshot, error) in
            self.allEventsWithGroupID = []
            
            guard let snapshot = snapshot else { return }
        
            if !snapshot.isEmpty {
                
                for eventDictionary in snapshot.documents {
                    
                    let eventDictionary = eventDictionary.data() as NSDictionary
                    let eventS = Event(_dictionary: eventDictionary)
                    if eventS.eventGroupID == self.event.eventGroupID {
                        self.allEventsWithGroupID.append(eventS)
                    }
                    
                    
                   
                }
                self.imageview.removeFromSuperview()
            }
            self.imageview.removeFromSuperview()
        }
    }
    

    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        
        //ProgressHUD.show("Deleting...", interaction: false)
        var i = 0
        
        for event in allEventsWithGroupID {
            reference(.TeamEventCache).document(event.eventGroupID).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    i += 1
                }
                
            }
            reference(.Event).document(event.eventID).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    i += 1
                }
                if i == self.allEventsWithGroupID.count {
                    //sleep(UInt32(1.7))
                    
                           
                    
                }
            }
            
        }
        self.imageview.removeFromSuperview()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deleteEvent"), object: nil)
        dismiss(animated: true, completion: nil)
//        if let eventVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Calendar_Coach") as? Calendar_Coach
//        {
//            eventVC.modalPresentationStyle = .fullScreen
//            self.present(eventVC, animated: true, completion: nil)
//        }
 }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        let startDateComps = datePicker.calendar.dateComponents([.month, .day, .year, .hour, .minute, .second], from: datePicker.date)
        let endDateComps = endDatePicker.calendar.dateComponents([.month, .day, .year, .hour, .minute, .second], from: endDatePicker.date)
        dateFormatter.dateFormat = "H:mm a"
        let startDate = Calendar.current.date(from: startDateComps)!
        let endDate = Calendar.current.date(from: endDateComps)!
        let startTime = dateFormatter.string(from: startDate)
        let endTime = dateFormatter.string(from: endDate)
        print(startTime)
        
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let dateForUpcomingComparison = dateFormatter.string(from: startDate)
        
        dateFormatter.dateFormat = "EEEE, MM-dd-YYYY"
        let dateString = dateFormatter.string(from: startDate)
        
        if eventTitleText.text != "" {
            if self.doneButton.currentTitle == "Update" {
                event.updateEvent(eventGroupID: event.eventGroupID, eventOwnerID: event.eventOwnerID, eventText: textView.text!, eventTitle: eventTitleText.text!, eventStart: startTime, eventEnd: endTime, eventLocation: event.eventLocation, eventImage: event.eventImage, eventURL: event.eventURL)
            } else {
                //ProgressHUD.show("Creating...", interaction: false)
                createEventForMembers(start: startTime, end: endTime, fullDate: dateString, upcomingCompar: dateForUpcomingComparison)
                sleep(UInt32(0.5))
            }
            
            
        } else {
            helper.showAlert(title: "Data Error", message: "Please fill in title.", in: self)
        }
        sleep(UInt32(1.5))
        dismiss(animated: true, completion: nil)
        
    }
    
    func createStartiOS14Picker() {
        
//        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneStartPressed))
        
        
        
        
    }
    func createEndiOS14Picker() {
        
//        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneEndPressed))
        
        //eventEndText.inputAccessoryView = toolbar
        
        
    }

    
//    func createStartDatePicker() {
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneStartPressed))
//        toolbar.setItems([doneBtn], animated: true)
//        eventStartText.inputAccessoryView = toolbar
//        eventStartText.inputView = datePicker
//        datePicker.datePickerMode = .time
//    }
//    func createEndDatePicker() {
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneEndPressed))
//        toolbar.setItems([doneBtn], animated: true)
//        eventEndText.inputAccessoryView = toolbar
//        eventEndText.inputView = datePicker
//        datePicker.datePickerMode = .time
//    }
    
//    func createEventDatePicker() {
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneEventDatePressed))
//        toolbar.setItems([doneBtn], animated: true)
//        dateText.inputAccessoryView = eventDatePicker
//        eventDatePicker.datePickerMode = .date
//        dateText.inputView = eventDatePicker
//
//    }
//
//    @objc func doneEventDatePressed() {
//        let formatter = DateFormatter()
//        //formatter.dateStyle = .full
//        formatter.dateFormat = "EEEE, MM-dd-YYYY"
//        self.dateString = formatter.string(from: eventDatePicker.date)
//        dateText.text = self.dateString
//        formatter.dateFormat = "YYYY-MM-dd"
//        self.dateForUpcomingComparison = formatter.string(from: eventDatePicker.date)
//        self.view.endEditing(true)
//    }
    
//    @objc func doneStartPressed() {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .none
//        formatter.timeStyle = .short
//        eventStartText.text = formatter.string(from: datePicker.date)
//        self.view.endEditing(true)
//    }
//
//    @objc func doneEndPressed() {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .none
//        formatter.timeStyle = .short
//        eventEndText.text = formatter.string(from: datePicker.date)
//        self.view.endEditing(true)
//    }
    
    func configureUI() {
        
       self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
       navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
//        var bottomLine = CALayer()
//        bottomLine.frame = CGRect(x: 0.0, y: eventStartText.frame.height, width: eventStartText.frame.width, height: 1.0)
//        bottomLine.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
//        eventStartText.borderStyle = UITextField.BorderStyle.none
//        eventStartText.layer.addSublayer(bottomLine)
        
//        var bottomLine1 = CALayer()
//        bottomLine1.frame = CGRect(x: 0.0, y: eventEndText.frame.height, width: eventEndText.frame.width, height: 1.0)
//        bottomLine1.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
//        eventEndText.borderStyle = UITextField.BorderStyle.none
//        eventEndText.layer.addSublayer(bottomLine1)

        cornerRadius(for: deleteButton)
    }
    

        
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
        //removeListeners()
        dismiss(animated: true, completion: nil)
    }
    


    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textView.resignFirstResponder()
        eventTitleText.resignFirstResponder()
//        eventStartText.resignFirstResponder()
//        eventEndText.resignFirstResponder()
        
           return true;
       }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeHolderLabel.isHidden = false
        }
        else {
            placeHolderLabel.isHidden = true
        }
    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.view.endEditing(true)
//        return false
//    }
    
    // exec whenever the screen has been tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.resignFirstResponder()
    }
    
//    @IBAction func backButtonPressed(_ sender: Any) {
//        event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
//        //removeListeners()
//        dismiss(animated: true, completion: nil)
//    }
    
    // make corners rounded for any views (objects)
    func cornerRadius(for view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
    }

}
