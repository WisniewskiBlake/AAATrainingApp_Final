//
//  RosterVC_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/23/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import FirebaseFirestore

class RosterVC_Coach: UITableViewController, UISearchResultsUpdating, RosterCell_CoachDelegate{
        

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    var allUsers: [FUser] = []
    var coaches: [FUser] = []
    var players: [FUser] = []
    var parents: [FUser] = []
    var usersToShow: [FUser] = []
    var userType = ""
    var userTeamAccTypeIndexArr : [Int] = []
    var filteredUsers: [FUser] = []
    var allUsersGroupped = NSDictionary() as! [String : [FUser]]
    var sectionTitleList : [String] = []
    var userListener: ListenerRegistration!
    
    
    var isLoading = false
    let helper = Helper()
    var skip = 0
    var limit = 10
    
    let searchController = UISearchController(searchResultsController: nil)
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        getAllTeamMembers()
//        getFilteredUsers()
//        loadUsers(filter: "")

        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        self.setLeftAlignedNavigationItemTitle(text: "Roster", color: .white, margin: 12)
        
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        //getTeam()
        getTeam(filter: "")
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //getTeam()
//        getAllTeamMembers()
//        getFilteredUsers()
//        loadUsers(filter: "")
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        configureUI()
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.tableFooterView = view
        
        
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
    
    func configureUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.tableView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func filterSegmentValueChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            getTeam(filter: "")
        case 1:
            getTeam(filter: "Player")
        case 2:
            getTeam(filter: "Coach")
        case 3:
            getTeam(filter: "Parent")
        default:
            return
        }
        
    }
    
    func getTeam(filter: String) {
        ProgressHUD.show()
        var query = reference(.User).whereField(kUSERTEAMIDS, arrayContains: FUser.currentUser()!.userCurrentTeamID)
        query.getDocuments { (snapshot, error) in
            
            self.allUsers = []
            self.coaches = []
            self.players = []
            self.parents = []
            self.sectionTitleList = []
            self.allUsersGroupped = [:]
            self.usersToShow = []
            
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            
            guard let snapshot = snapshot else {
                ProgressHUD.dismiss(); return
            }
            
            if !snapshot.isEmpty {
                
                for userDictionary in snapshot.documents {
                    
                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    
                    
                    self.allUsers.append(fUser)
                    let index = fUser.userTeamIDs.firstIndex(of: FUser.currentUser()!.userCurrentTeamID)!
                    self.userTeamAccTypeIndexArr.append(index)
                    if fUser.userTeamAccountTypes[index] == "Coach" {
                        self.coaches.append(fUser)
                    } else if fUser.userTeamAccountTypes[index] == "Player" {
                        self.players.append(fUser)
                    } else {
                        self.parents.append(fUser)
                    }
                    
                }
                
                switch filter {
                   case "Player":
                        self.usersToShow = self.players

                  case ("Coach"):
                        self.usersToShow = self.coaches

                   case ("Parent"):
                       self.usersToShow = self.parents

                  default:
                        self.usersToShow = self.allUsers

                }
                self.splitDataIntoSection()
                self.tableView.reloadData()
            }
            
            self.tableView.reloadData()
            ProgressHUD.dismiss()
            
        }
        
//        team.getTeam(teamID: FUser.currentUser()!.userCurrentTeamID) { (teamReturned) in
//            if teamReturned.teamID != "" {
//                //self.team = teamReturned
//                self.getAllTeamMembers(teamReturned: teamReturned)
//
//            } else {
//                self.helper.showAlert(title: "Invadlid ID", message: "Team ID does not exist!", in: self)
//            }
//        }
    }
    
//    func getAllTeamMembers(teamReturned: Team) {
//        for ID in teamReturned.teamMemberIDs {
//            fetchUserFromFirestore(userId: ID, completion: { (user) in
//                self.allUsers.append(user!)
//
//            })
//
//        }
//        self.getFilteredUsers()
//        print(allUsers.count)
//    }
//
//    func getFilteredUsers() {
//        for user in allUsers {
//            let index = user.userTeamIDs.firstIndex(of: FUser.currentUser()!.userCurrentTeamID)!
//            userTeamAccTypeIndexArr.append(index)
//            if user.userTeamAccountTypes[index] == "Coach" {
//                coaches.append(user)
//            } else if user.userTeamAccountTypes[index] == "Player" {
//                players.append(user)
//            } else {
//                parents.append(user)
//            }
//
//        }
//        self.loadUsers(filter: "")
//        print(coaches.count)
//        print(players.count)
//        print(parents.count)
//
//    }
    
    
    
    
    //query User for documents where userTeamIDs contains the same current team ID of the FUser.currentUser. Store that user then determine what type of account he has by matching the position of userteamaccounttypes to position of userteamID
//    func loadUsers(filter: String) {
//           isLoading = true
//        self.getTeam()
//           ProgressHUD.show()
//
//
//           usersToShow = []
//            self.sectionTitleList = []
//            self.allUsersGroupped = [:]
//
//
//
//        self.splitDataIntoSection()
//        self.tableView.reloadData()
//        ProgressHUD.dismiss()
//
//
//       }
    
    //MARK: Helper functions
      
      fileprivate func splitDataIntoSection() {
          
          var sectionTitle: String = ""
          
          for i in 0..<self.usersToShow.count {
              let currentUser = self.usersToShow[i]
              
              let firstChar = currentUser.firstname.first!
              
              let firstCarString = "\(firstChar)"
              if firstCarString != sectionTitle {
                  sectionTitle = firstCarString
                  self.allUsersGroupped[sectionTitle] = []
                  if !sectionTitleList.contains(sectionTitle) {
                      self.sectionTitleList.append(sectionTitle)
                  }
              }
              self.allUsersGroupped[firstCarString]?.append(currentUser)
          }
    
      }
    
    
    
    
    func didTapAvatarImage(indexPath: IndexPath) {
        
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // load more posts when the scroll is about to reach the bottom AND currently is not loading (posts)
        //print("Called")
                let a = tableView.contentOffset.y - tableView.contentSize.height + 60
                let b = -tableView.frame.height
                
                if a > b && isLoading == false {
                    //loadMore(offset: skip, limit: limit)
                    //print("Scrolled")
                }
    }
    
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        } else {
            return allUsersGroupped.count
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if searchController.isActive && searchController.searchBar.text != "" {
            
            return filteredUsers.count
            
        } else {
            
            //find section Title
            let sectionTitle = self.sectionTitleList[section]
            
            //user for given title
            let users = self.allUsersGroupped[sectionTitle]
            
            return users!.count
        }

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RosterCell_Coach

        
        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            user = filteredUsers[indexPath.row]
        } else {
            
            let sectionTitle = self.sectionTitleList[indexPath.section]
            
            let users = self.allUsersGroupped[sectionTitle]

            user = users![indexPath.row]
        }
        
        
        
        cell.generateCellWith(fUser: user, indexPath: indexPath, accTypeIndexArr: userTeamAccTypeIndexArr)
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        var user: FUser

        if searchController.isActive && searchController.searchBar.text != "" {

            user = filteredUsers[indexPath.row]
        } else {

            let sectionTitle = self.sectionTitleList[indexPath.section]

            let users = self.allUsersGroupped[sectionTitle]

            user = users![indexPath.row]
        }

        if(user.userTeamAccountTypes[userTeamAccTypeIndexArr[indexPath.row]] == "Player") {
            let playerProfileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            playerProfileVC.userBeingViewed = user
            self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            self.navigationController?.navigationBar.isTranslucent = false
            //self.navigationController?.navigationBar.autoresizesSubviews = true
            //self.navigationController?.navigationBar.insetsLayoutMarginsFromSafeArea = true
            
            //self.navigationController?.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
            self.navigationController?.pushViewController(playerProfileVC, animated: true)
        }

    }
    
    
    //MARK: TableView Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return ""
        } else {
            return sectionTitleList[section]
        }
    }

    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return nil
        } else {
            return self.sectionTitleList
        }
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        return index
    }
    
    //MARK: Search controller functions
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
    
        filteredUsers = allUsers.filter({ (user) -> Bool in
            
            return user.firstname.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        var user: FUser

        if searchController.isActive && searchController.searchBar.text != "" {

            user = filteredUsers[indexPath.row]
        } else {

            let sectionTitle = self.sectionTitleList[indexPath.section]

            let users = self.allUsersGroupped[sectionTitle]

            user = users![indexPath.row]

            
        }

        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in

            //allUsersGroupped.remove(at: users, indexPath.row)

            self.deleteAUser(user: user)

            self.tableView.reloadData()
        }
        
        
        
        return [deleteAction]
    }
    
    func deleteAUser(user : FUser) {
        print(user.objectId)
        
        updateUser(userID: user.objectId, withValues: [kUSERTEAMIDS: FieldValue.arrayRemove([FUser.currentUser()!.userCurrentTeamID])])
        Team.updateTeam(teamID: FUser.currentUser()!.userCurrentTeamID, withValues: [kTEAMMEMBERIDS: FieldValue.arrayRemove([user.objectId])])
            
//            { err in
//        if let err = err {
//            print("Error removing document: \(err)")
//        } else {
//            print("Document successfully removed!")
//        }
//    }
        self.tableView.reloadData()

    

}
}
