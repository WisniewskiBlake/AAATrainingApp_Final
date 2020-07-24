//
//  ContactsVC_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/23/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import Contacts
import FirebaseFirestore
import ProgressHUD

class ContactsVC_Coach: UITableViewController, UISearchResultsUpdating, RosterCell_CoachDelegate {
    
    var users: [FUser] = []
    var matchedUsers: [FUser] = []
    var filteredMatchedUsers: [FUser] = []
    var allUsersGrouped = NSDictionary() as! [String : [FUser]]
    var sectionTitleList: [String] = []
    
    var isGroup = false
    var memberIdsOfGroupChat: [String] = []
    var membersOfGroupChat: [FUser] = []
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        <#code#>
    }
    
    func didTapAvatarImage(indexPath: IndexPath) {
        <#code#>
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

   

}
