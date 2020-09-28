//
//  MultiEvent_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 9/25/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import UIKit

class MultiEvent_Coach: UITableViewController {
    
    var allEventsSameDate: [Event] = []
    var datesForUpcomingComparison: [String] = []
    var dateString: String = ""
    var eventsToShow: [Event] = []
    
    @IBOutlet weak var eventCounterLabel: UILabel!
    
    @IBOutlet weak var titleView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loadEvents()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadEvents()
        
    }
    
    func loadEvents() {
        for event in allEventsSameDate {
            if event.eventUserID == FUser.currentId() {
                eventsToShow.append(event)
            }
            
        }
        eventCounterLabel.text = String(eventsToShow.count) + " Events"
        titleView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        titleView.alpha = 1.0
        tableView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        tableView.separatorColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        self.navigationController?.view.addSubview(self.titleView)
        self.navigationController?.navigationBar.layer.zPosition = 0;
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return eventsToShow.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventCell
        cell.eventDateLabel.text = eventsToShow[indexPath.row].eventDate
        cell.eventTitleText.text = eventsToShow[indexPath.row].eventTitle
        cell.eventStartText.text = eventsToShow[indexPath.row].eventStart
        cell.eventEndText.text = eventsToShow[indexPath.row].eventEnd
        cell.eventText.text = eventsToShow[indexPath.row].eventText
        if cell.eventText.text != "" {
            cell.placeholderLabel.isHidden = true
        } else {
            cell.placeholderLabel.isHidden = false
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = eventsToShow[indexPath.row]
        
        if let eventVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Event_Coach") as? Event_Coach
        {
            eventVC.hidesBottomBarWhenPushed = true
            eventVC.dateString = event.eventDate
            eventVC.dateForUpcomingComparison = event.dateForUpcomingComparison
            eventVC.updateNeeded = true
            eventVC.event = event
            eventVC.dateForUpcomingComparison = event.dateForUpcomingComparison
            eventVC.modalPresentationStyle = .fullScreen
            self.present(eventVC, animated: true, completion: nil)
        }
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        for event in eventsToShow {
            event.clearCalendarCounter(eventGroupID: event.eventGroupID, eventUserID : event.eventUserID)
        }
        //removeListeners()
        dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
