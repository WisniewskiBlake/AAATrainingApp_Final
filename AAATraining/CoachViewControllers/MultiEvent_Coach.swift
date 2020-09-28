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
    var emptyLabelOne = UILabel()
    @IBOutlet weak var eventCounterLabel: UILabel!
    
    @IBOutlet weak var titleView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //loadEvents()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emptyLabelOne = UILabel(frame: CGRect(x: 0, y: -150, width: view.bounds.size.width, height: view.bounds.size.height))
        titleView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        titleView.alpha = 1.0
        tableView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        tableView.separatorColor = UIColor.clear
        self.navigationController?.view.addSubview(self.titleView)
        self.navigationController?.navigationBar.layer.zPosition = 0;
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.tableFooterView = view
        loadEvents()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fillContentGap:
        if let tableFooterView = tableView.tableFooterView {
            /// The expected height for the footer under autolayout.
            let footerHeight = tableFooterView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            /// The amount of empty space to fill with the footer view.
            let gapHeight: CGFloat = tableView.bounds.height - tableView.adjustedContentInset.top - tableView.adjustedContentInset.bottom - tableView.contentSize.height
            // Ensure there is space to be filled
            guard gapHeight.rounded() > 0 else { break fillContentGap }
            // Fill the gap
            tableFooterView.frame.size.height = gapHeight + footerHeight
        }
    }
    
    func loadEvents() {
        self.eventsToShow = []
        for event in allEventsSameDate {
            if event.eventUserID == FUser.currentId() {
                eventsToShow.append(event)
            }
            
        }
        eventCounterLabel.text = String(eventsToShow.count) + " Events"
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if eventsToShow.count == 0 {
            
            emptyLabelOne.text = "Created posts will appear here!"
            emptyLabelOne.textAlignment = NSTextAlignment.center
            self.tableView.tableFooterView!.addSubview(emptyLabelOne)
            return 0
        } else {
            emptyLabelOne.text = ""
            emptyLabelOne.removeFromSuperview()
            
            return eventsToShow.count
        }
        
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
            eventVC.updateNeeded = true
            eventVC.event = event            
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
