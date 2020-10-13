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
import MapKit

class Event_Coach: UIViewController, UITextViewDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var eventTitleText: UITextField!
    @IBOutlet weak var eventLocationText: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeHolderLabel: UILabel!
    @IBOutlet weak var eventURLText: UITextView!
    @IBOutlet weak var placeHolderLabelOne: UILabel!
    @IBOutlet weak var startText: UITextField!
    @IBOutlet weak var endText: UITextField!
    
    
    @IBOutlet weak var titleLocationView: UIView!
    @IBOutlet weak var startEndView: UIView!
    @IBOutlet weak var detailsURLView: UIView!

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!

    @IBOutlet weak var navView: UIView!
    var dateFormatter = DateFormatter()
    var sendFromMultiEvent: Bool = false
    var memberIds: [String] = []
    var allMembers: [FUser] = []
    
    var dateString: String = ""
    let formatter = DateFormatter()
    let helper = Helper()
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var mapBtn: UIButton!
    
    var updateNeeded: Bool = false
    
    var event = Event()
    var accountType = ""
    
    var allEventsWithGroupID: [Event] = []

    let eventDatePicker = UIDatePicker()
    
    var index = 0
    var isNewObserverValue: String = ""
    var imageview = UIImageView()
    
    let startTapGestureRecognizer = UITapGestureRecognizer()
    let endTapGestureRecognizer = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.setLocation(_:)), name: NSNotification.Name(rawValue: "locationSet"), object: nil)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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
        
        
        
        
        if #available(iOS 14.0, *) {
            datePicker.isHidden = false
            endDatePicker.isHidden = false
            startText.isHidden = true
            endText.isHidden = true
            setDatePickerDates()
        } else {
//            startText.text = event.eventDate + " " + event.eventStart
//            endText.text = event.eventDate + " " + event.eventEnd
//            datePicker.isHidden = true
//            endDatePicker.isHidden = true
//            startText.isHidden = false
//            endText.isHidden = false
//            createStart13DatePicker()
//            createEnd13DatePicker()
            doneButton.isHidden = true
            mapBtn.isHidden = true
            eventTitleText.isUserInteractionEnabled = false
            eventLocationText.isUserInteractionEnabled = false
            datePicker.isUserInteractionEnabled = false
            endDatePicker.isUserInteractionEnabled = false
            textView.isUserInteractionEnabled = false
            eventURLText.isUserInteractionEnabled = false
            startText.isUserInteractionEnabled = false
            endText.isUserInteractionEnabled = false
            deleteButton.isHidden = true
            helper.showAlert(title: "Version Error", message: "Please update your device to iOS 14+ to create and view events.", in: self)
        }
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))

    }
    
    @objc func setLocation(_ notification: NSNotification) {
        if let searchResult = notification.userInfo?["searchResult"] as? String {
            eventLocationText.text = searchResult
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configure_titleLocationView()
        configure_startEndView()
        configure_detailsURLView()

    }
    
    @IBAction func mapBtn_pressed(_ sender: Any) {
//        let mapNav = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapNav") as! UINavigationController
//        let mapView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapController") as! MapController
//        
//        
////        self.navigationController?.pushViewController(mapNav, animated: true)
//        self.present(mapNav, animated: true)
    }
    
    
    func setDatePickerDates() {
        let dateFormatter = DateFormatter()
        
        if sendFromMultiEvent == true {
            let delimiter = " "
            let dateToken = dateString.components(separatedBy: delimiter)
            
            let dashDelimiter = "-"
            let dateWithSlash = dateToken[1].components(separatedBy: dashDelimiter)
            
            var startDateComps = datePicker.calendar.dateComponents([.month, .day, .year, .hour, .minute, .second], from: datePicker.date)
            startDateComps.month = Int(dateWithSlash[0])
            startDateComps.day = Int(dateWithSlash[1])
            startDateComps.year = Int(dateWithSlash[2])
//            startDateComps.hour = Int(startHourToken[0])
//            startDateComps.minute = Int(startMinuteToken[0])
//            startDateComps.second = 0

            datePicker.date = Calendar.current.date(from: startDateComps)!
            
            var endDateComps = endDatePicker.calendar.dateComponents([.month, .day, .year, .hour, .minute, .second], from: endDatePicker.date)
            endDateComps.month = Int(dateWithSlash[0])
            endDateComps.day = Int(dateWithSlash[1])
            endDateComps.year = Int(dateWithSlash[2])
//            endDateComps.hour = Int(endHourToken[0])
//            endDateComps.minute = Int(endMinuteToken[0])
//            endDateComps.second = 0

            endDatePicker.date = Calendar.current.date(from: endDateComps)!
        } else {
            if event.eventStart != "" && event.eventEnd != "" {
                let delimiter = " "
                let dateToken = event.eventDate.components(separatedBy: delimiter)
                
                let dashDelimiter = "-"
                let dateWithSlash = dateToken[1].components(separatedBy: dashDelimiter)
                
                let colonDelimiter = ":"
                let startHourToken = event.eventStart.components(separatedBy: colonDelimiter)
                let startMinuteToken = startHourToken[1].components(separatedBy: delimiter)
                
                let endHourToken = event.eventEnd.components(separatedBy: colonDelimiter)
                let endMinuteToken = endHourToken[1].components(separatedBy: delimiter)
                
                
                let timeEndToken = event.eventEnd.components(separatedBy: delimiter)
                let timeEndWithZeros = timeEndToken[0] + ":00 " + timeEndToken[1]
                let fullEndString = dateWithSlash[0] + "/" + dateWithSlash[1] + "/" + dateWithSlash[2] + ", " + timeEndWithZeros


                var startDateComps = datePicker.calendar.dateComponents([.month, .day, .year, .hour, .minute, .second], from: datePicker.date)
                startDateComps.month = Int(dateWithSlash[0])
                startDateComps.day = Int(dateWithSlash[1])
                startDateComps.year = Int(dateWithSlash[2])
                startDateComps.hour = Int(startHourToken[0])
                startDateComps.minute = Int(startMinuteToken[0])
                startDateComps.second = 0

                datePicker.date = Calendar.current.date(from: startDateComps)!
                
                var endDateComps = endDatePicker.calendar.dateComponents([.month, .day, .year, .hour, .minute, .second], from: endDatePicker.date)
                endDateComps.month = Int(dateWithSlash[0])
                endDateComps.day = Int(dateWithSlash[1])
                endDateComps.year = Int(dateWithSlash[2])
                endDateComps.hour = Int(endHourToken[0])
                endDateComps.minute = Int(endMinuteToken[0])
                endDateComps.second = 0

                endDatePicker.date = Calendar.current.date(from: endDateComps)!
                
            }
        }
        
    }
    
    
    
    @IBAction func doneButtonPressed(_ sender: Any) {
            
            var startDate = Date()
            var endDate = Date()
            var startTime: String = ""
            var endTime: String = ""
            
            var startMonth: String = ""
            var startDay: String = ""
            var startYear: String = ""
            var endMonth: String = ""
            var endDay: String = ""
            var endYear: String = ""
            
            
            let startDateComps = datePicker.calendar.dateComponents([.month, .day, .year, .hour, .minute, .second], from: datePicker.date)
            let endDateComps = endDatePicker.calendar.dateComponents([.month, .day, .year, .hour, .minute, .second], from: endDatePicker.date)
            if endDateComps.month == startDateComps.month && endDateComps.day == startDateComps.day && endDateComps.year == startDateComps.year {
                dateFormatter.dateFormat = "h:mm a"

                startDate = Calendar.current.date(from: startDateComps)!
                endDate = Calendar.current.date(from: endDateComps)!
                startTime = dateFormatter.string(from: startDate)
                endTime = dateFormatter.string(from: endDate)
                    
                dateFormatter.dateFormat = "YYYY-MM-dd"
                let dateForUpcomingComparison = dateFormatter.string(from: startDate)
                
                dateFormatter.dateFormat = "EEEE, MM-dd-YYYY"
                let newDateString = dateFormatter.string(from: startDate)
                    
                if eventTitleText.text != "" {
                    if self.doneButton.currentTitle == "Update" {
                        if(newDateString == self.dateString) {
                            event.updateEvent(eventGroupID: event.eventGroupID, eventOwnerID: event.eventOwnerID, eventText: textView.text!, eventTitle: eventTitleText.text!, eventStart: startTime, eventEnd: endTime, eventLocation: eventLocationText.text!, eventImage: "", eventURL: eventURLText.text!)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateEvent"), object: nil)
                        } else {
                            helper.showAlert(title: "Data Error", message: "Date to update and dates you have selected are conflicting.", in: self)
                        }
                        
                    } else {
                        
                        createEventForMembers(start: startTime, end: endTime, fullDate: newDateString , upcomingCompar: dateForUpcomingComparison)
                        sleep(UInt32(0.5))
                    }
                    
                    
                } else {
                    helper.showAlert(title: "Data Error", message: "Please fill in title.", in: self)
                }
                sleep(UInt32(1.5))
                dismiss(animated: true, completion: nil)
            } else {
                helper.showAlert(title: "Data Error", message: "Event must start and end on the same day.", in: self)
            }
                
                
    //            if #available(iOS 14.0, *) {} else {
    //                if eventTitleText.text != "" && startText.text != "" && endText.text != "" {
    //                    let delimiter = " "
    //                    let startArray = startText.text!.components(separatedBy: delimiter)
    //                    let endArray = endText.text!.components(separatedBy: delimiter)
    //                    startTime = startArray[2]
    //                    endTime = endArray[2]
    //
    //                    let dashDelimiter = "-"
    //                    let startWithSlash = startArray[1].components(separatedBy: dashDelimiter)
    //                    let endWithSlash = endArray[1].components(separatedBy: dashDelimiter)
    //
    //                    startMonth = startWithSlash[0]
    //                    startDay = startWithSlash[1]
    //                    startYear = startWithSlash[2]
    //
    //                    endMonth = endWithSlash[0]
    //                    endDay = endWithSlash[1]
    //                    endYear = endWithSlash[2]
    //
    //                    if (startMonth == endMonth) && (startDay == endDay) && (startYear == endYear) {
    //
    //                    } else {
    //                        helper.showAlert(title: "Data Error", message: "Please fill in title, start time, and end time.", in: self)
    //                    }
    //                } else {
    //                    helper.showAlert(title: "Data Error", message: "Please fill in title, start time, and end time.", in: self)
    //                }
    //
    //            }
            
            
                
            
            
            
        

        
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

        var tempMembers = memberIds
        let eventText = textView.text!
        let eventOwnerID = FUser.currentId()
        let eventAccountType = "Coach"
        let eventGroupID = UUID().uuidString
        let eventTitle = eventTitleText.text!
        let eventLocation = eventLocationText.text!
        let eventURL = eventURLText.text!
        let eventStart = start
        let eventEnd = end
        
            
        for userId in tempMembers {
            self.createEvent(eventOwnerID: eventOwnerID, eventTeamID: FUser.currentUser()!.userCurrentTeamID, eventText: eventText, eventDate: fullDate, eventAccountType: eventAccountType, eventUserID: userId, eventGroupID: eventGroupID, eventTitle: eventTitle, eventStart: eventStart, eventEnd: eventEnd, upcomingCompar: upcomingCompar, eventLocation: eventLocation, eventImage: "", eventURL: eventURL)

        }
        self.createTeamEvent(eventOwnerID: eventOwnerID, eventTeamID: FUser.currentUser()!.userCurrentTeamID, eventText: eventText, eventDate: fullDate, eventAccountType: eventAccountType, eventUserID: "", eventGroupID: eventGroupID, eventTitle: eventTitle, eventStart: eventStart, eventEnd: eventEnd, upcomingCompar: upcomingCompar, eventLocation: eventLocation, eventImage: "", eventURL: eventURL)
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
    
    
    
    func createStartiOS14Picker() {
        
//        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneStartPressed))
        
        
        
        
    }
    func createEndiOS14Picker() {
        
//        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneEndPressed))
        
        //eventEndText.inputAccessoryView = toolbar
        
        
    }

    func configureUI() {
        
        textView.text = event.eventText
        eventTitleText.text = event.eventTitle
        eventLocationText.text = event.eventLocation
        eventURLText.text = event.eventURL
        if event.eventText != "" {
            placeHolderLabel.isHidden = true
        } else {
            placeHolderLabel.isHidden = false
        }
        if event.eventURL != "" {
            placeHolderLabelOne.isHidden = true
        } else {
            placeHolderLabelOne.isHidden = false
        }
        if self.accountType != "Coach" {
            doneButton.isHidden = true
            mapBtn.isHidden = true
            eventTitleText.isUserInteractionEnabled = false
            eventLocationText.isUserInteractionEnabled = false
            datePicker.isUserInteractionEnabled = false
            endDatePicker.isUserInteractionEnabled = false
            textView.isUserInteractionEnabled = false
            eventURLText.isUserInteractionEnabled = false
            startText.isUserInteractionEnabled = false
            endText.isUserInteractionEnabled = false
            deleteButton.isHidden = true
        } else {
            if updateNeeded == true {
                
                deleteButton.isHidden = false
                self.doneButton.setTitle("Update", for: .normal)
                
            } else {
                deleteButton.isHidden = true
            }
        }
        
        
       self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
       navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
        padding(for: eventTitleText)
        padding(for: eventLocationText)
        cornerRadius(for: eventTitleText)
        cornerRadius(for: eventLocationText)
        
        padding(for: startText)
        padding(for: endText)
        cornerRadius(for: startText)
        cornerRadius(for: endText)

        cornerRadius(for: eventURLText)
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
        
        if #available(iOS 14.0, *) {
            textView.resignFirstResponder()
            eventTitleText.resignFirstResponder()
        } else {
            startText.resignFirstResponder()
            endText.resignFirstResponder()
            textView.resignFirstResponder()
            eventTitleText.resignFirstResponder()
        }

        
           return true;
       }
    
    func createStart13DatePicker() {
            let toolbar = UIToolbar()
            toolbar.sizeToFit()
            let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneStartPressed))
            toolbar.setItems([doneBtn], animated: true)
            startText.inputAccessoryView = toolbar
            startText.inputView = datePicker
            datePicker.datePickerMode = .time
            
    }
    func createEnd13DatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneEndPressed))
        toolbar.setItems([doneBtn], animated: true)
        endText.inputAccessoryView = toolbar
        endText.inputView = datePicker
        datePicker.datePickerMode = .time
        
    }
    @objc func doneStartPressed() {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            startText.text = formatter.string(from: datePicker.date)
            self.view.endEditing(true)
        }
        
        @objc func doneEndPressed() {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            endText.text = formatter.string(from: datePicker.date)
            self.view.endEditing(true)
        }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            placeHolderLabel.isHidden = false
        }
        else {
            placeHolderLabel.isHidden = true
        }
        if eventURLText.text.isEmpty{
            placeHolderLabelOne.isHidden = false
        } else {
            placeHolderLabelOne.isHidden = true
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
    
    func padding(for textField: UITextField) {
        let blankView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        textField.leftView = blankView
        textField.leftViewMode = .always
    }
    
    
    func configure_titleLocationView() {
        let width = CGFloat(1)
        let color = UIColor.lightGray.cgColor
        
        // creating layer to be a border of the view added test test
        let border = CALayer()
        border.borderWidth = width
        border.borderColor = color
        border.frame = CGRect(x: 0, y: 0, width: titleLocationView.frame.width, height: titleLocationView.frame.height)
        
        // creating layer to be a line in the center of the view
        let line = CALayer()
        line.borderWidth = width
        line.borderColor = color
        line.frame = CGRect(x: 15, y: titleLocationView.frame.height / 2 - width, width: titleLocationView.frame.width-15, height: width)
        
        // assigning created layers to the view
        titleLocationView.layer.addSublayer(border)
        titleLocationView.layer.addSublayer(line)
        // rounded corners
//        titleLocationView.layer.cornerRadius = 5
//        titleLocationView.layer.masksToBounds = true
    }
    
    func configure_startEndView() {
        let width = CGFloat(1)
        let color = UIColor.lightGray.cgColor
        
        // creating layer to be a border of the view added test test
        let border = CALayer()
        border.borderWidth = width
        border.borderColor = color
        border.frame = CGRect(x: 0, y: 0, width: startEndView.frame.width, height: startEndView.frame.height)
        
        // creating layer to be a line in the center of the view
        let line = CALayer()
        line.borderWidth = width
        line.borderColor = color
        line.frame = CGRect(x: 15, y: startEndView.frame.height / 2 - width, width: startEndView.frame.width-15, height: width)
        
        // assigning created layers to the view
        startEndView.layer.addSublayer(border)
        startEndView.layer.addSublayer(line)
        // rounded corners
//        startEndView.layer.cornerRadius = 5
//        startEndView.layer.masksToBounds = true
    }
    
    func configure_detailsURLView() {
        let width = CGFloat(1)
        let color = UIColor.lightGray.cgColor
        
        // creating layer to be a border of the view added test test
        let border = CALayer()
        border.borderWidth = width
        border.borderColor = color
        border.frame = CGRect(x: 0, y: 0, width: detailsURLView.frame.width, height: detailsURLView.frame.height)
        

        
        // assigning created layers to the view
        detailsURLView.layer.addSublayer(border)
        // rounded corners
//        detailsURLView.layer.cornerRadius = 5
//        detailsURLView.layer.masksToBounds = true
    }

}

