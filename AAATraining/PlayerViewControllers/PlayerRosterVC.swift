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
            loadUsers(filter: "player")
        case 2:
            loadUsers(filter: "coach")
        case 3:
            loadUsers(filter: "parent")
        default:
            return
        }
    }
    
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationItem.searchController = searchController
        
        self.setLeftAlignedNavigationItemTitle(text: "Roster", color: .white, margin: 12)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        loadUsers(filter: "")
    }
    
    // MARK: - Search Bar
    fileprivate func splitDataIntoSection() {
          
          var sectionTitle: String = ""
          
          for i in 0..<self.allUsers.count {
              let currentUser = self.allUsers[i]
              
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
           isLoading = true
           ProgressHUD.show()
           
           var query: Query!
           
           switch filter {
            case "player":
                query = reference(.User).whereField("accountType", isEqualTo: "player").whereField(kUSERTEAMID, isEqualTo: FUser.currentUser()?.userTeamID).order(by: kFIRSTNAME, descending: false)
           case ("coach"):
               query = reference(.User).whereField("accountType", isEqualTo: "coach").whereField(kUSERTEAMID, isEqualTo: FUser.currentUser()?.userTeamID).order(by: kFIRSTNAME, descending: false)
            case ("parent"):
                query = reference(.User).whereField("accountType", isEqualTo: "parent").whereField(kUSERTEAMID, isEqualTo: FUser.currentUser()?.userTeamID).order(by: kFIRSTNAME, descending: false)
           default:
               query = reference(.User).whereField(kUSERTEAMID, isEqualTo: FUser.currentUser()?.userTeamID).order(by: kFIRSTNAME, descending: false)
        }
           
           query.getDocuments { (snapshot, error) in
               
               self.allUsers = []
               self.sectionTitleList = []
               self.allUsersGroupped = [:]
               
               if error != nil {
                   print(error!.localizedDescription)
                   ProgressHUD.dismiss()
                self.helper.showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    self.isLoading = false
                   self.tableView.reloadData()
                   return
               }
               
               guard let snapshot = snapshot else {
                self.helper.showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                self.isLoading = false
                   ProgressHUD.dismiss(); return
               }
               
               if !snapshot.isEmpty {
                   
                   for userDictionary in snapshot.documents {
                       
                       let userDictionary = userDictionary.data() as NSDictionary
                       let fUser = FUser(_dictionary: userDictionary)
                       
                       if fUser.objectId != FUser.currentId() {
                           self.allUsers.append(fUser)
                       }
                   }
                   
                   self.splitDataIntoSection()
                   self.tableView.reloadData()
               }
               self.isLoading = false
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
       
       
       
       cell.generateCellWith(fUser: user, indexPath: indexPath)
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
