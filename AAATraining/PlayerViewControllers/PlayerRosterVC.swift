//
//  PlayerRosterVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/13/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD
import FirebaseFirestore

class PlayerRosterVC: UITableViewController, UISearchResultsUpdating, RosterCell_CoachDelegate {
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var filterSegmentControl: UISegmentedControl!
    
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
    
    @IBAction func filterSegmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            loadUsers(filter: "")
        case 1:
            loadUsers(filter: "Player")
        case 2:
            loadUsers(filter: "Coach")
        case 3:
            loadUsers(filter: "Parent")
        default:
            return
        }
    }
    
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
        navigationItem.searchController = searchController
        
        self.setLeftAlignedNavigationItemTitle(text: "Roster", color: .white, margin: 12)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        loadUsers(filter: "")
    }
    
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
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
    
    // MARK: - Search Bar
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
    
   
    
    // MARK: - loadUsers
    func loadUsers(filter: String) {
           ProgressHUD.show()
           var query = reference(.User).whereField(kUSERTEAMIDS, arrayContains: FUser.currentUser()!.userCurrentTeamID).order(by: kFIRSTNAME, descending: false)
        print(FUser.currentUser()!.userCurrentTeamID)
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
                    print(index)
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
       
       
       let index = allUsers.firstIndex(where: { $0.objectId == user.objectId })!
       
       cell.generateCellWith(fUser: user, indexPath: indexPath, accTypeIndexArr: userTeamAccTypeIndexArr, index: index)
       cell.delegate = self
       
       return cell
   }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            
            if searchController.isActive && searchController.searchBar.text != "" {
                return ""
            } else {
                return sectionTitleList[section]
            }
        }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
            return false
        }
        
//        override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//
//            var user: FUser
//
//            if searchController.isActive && searchController.searchBar.text != "" {
//
//                user = filteredUsers[indexPath.row]
//            } else {
//
//                let sectionTitle = self.sectionTitleList[indexPath.section]
//
//                let users = self.allUsersGroupped[sectionTitle]
//
//                user = users![indexPath.row]
//
//            }
//
//            let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
//
//                //allUsersGroupped.remove(at: users, indexPath.row)
//
//                self.deleteAUser(user: user)
//
//                self.tableView.reloadData()
//            }
//
//            return [deleteAction]
//        }
        

    
    func didTapAvatarImage(indexPath: IndexPath) {
        
    }
    
    func deleteUserPermanent(from cell: UITableViewCell) {
        
    }

}
