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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    var allUsers: [FUser] = []
    
    
    var skip = 0
    var limit = 25
    var users: [FUser] = []
    var coaches: [FUser] = []
    var players: [FUser] = []
    var parents: [FUser] = []
    var usersToShow: [FUser] = []
    var userType = ""
    var userTeamAccTypeIndexArr : [Int] = []
    var matchedUsers: [FUser] = []
    var filteredMatchedUsers: [FUser] = []
    var allUsersGrouped = NSDictionary() as! [String : [FUser]]
    var sectionTitleList: [String] = []
    
    var intArray: [Int] = []
    
    var isGroup = true
    var memberIdsOfGroupChat: [String] = []
    var membersOfGroupChat: [FUser] = []
    
    var cellTagArray: [[Int]] = []
    var cellFullNameCheckArray: [String] = []
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.searchController = searchController
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
//        let backItem = UIBarButtonItem()
//        backItem.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        navigationItem.backBarButtonItem = backItem
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
        //to remove empty cell lines
        tableView.tableFooterView = UIView()
        
        loadUsers(filter: "")
    }
    
    @IBAction func filterSegmentValueChanged(_ sender: UISegmentedControl) {
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
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        let newGroupVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newGroupView") as! NewGroupVC_Coach
        //let newGroupVC = NewGroupVC_Coach()
        newGroupVC.memberIds = memberIdsOfGroupChat
        newGroupVC.allMembers = membersOfGroupChat
        
        self.navigationController?.pushViewController(newGroupVC, animated: true)
    }
    
    
    func loadUsers(filter: String) {
           ProgressHUD.show()
           var query = reference(.User).whereField(kUSERTEAMIDS, arrayContains: FUser.currentUser()!.userCurrentTeamID)
           query.getDocuments { (snapshot, error) in
               
               self.allUsers = []
               self.coaches = []
               self.players = []
               self.parents = []
               self.sectionTitleList = []
               self.allUsersGrouped = [:]
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
                       
                       
                       if fUser.objectId != FUser.currentId() {
                           self.allUsers.append(fUser)
                       }
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
    
       }
    
    
    

    //MARK: TableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        } else {
            return self.allUsersGrouped.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return filteredMatchedUsers.count
            
        } else {
            
            //find section Title
            let sectionTitle = self.sectionTitleList[section]
            
            //user for given title
            let users = self.allUsersGrouped[sectionTitle]
            
            return users!.count
        }
        
    }
     
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RosterCell_Coach
        
        
        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            user = filteredMatchedUsers[indexPath.row]
        } else {
            
            let sectionTitle = self.sectionTitleList[indexPath.section]
            
            let users = self.allUsersGrouped[sectionTitle]

            user = users![indexPath.row]
        }
        
        
        cell.delegate = self
        //cell.generateCellWith(fUser: user, indexPath: indexPath)
        
        print(cell.fullNameLabel.text!)
        if cellTagArray.contains([indexPath.section, indexPath.row]) && cellFullNameCheckArray.contains(cell.fullNameLabel.text!) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.tag = indexPath.row
        
        return cell
    }
    
    //MARK: TableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //print(cellTagArray[0])
        print(indexPath)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionTitle = self.sectionTitleList[indexPath.section]
        let userToChat : FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            userToChat = filteredMatchedUsers[indexPath.row]
        } else {
          let users = self.allUsersGrouped[sectionTitle]
            
            userToChat = users![indexPath.row]
        }
        
//        if let cell = tableView.cellForRow(at: indexPath) {
//
//            if cell.accessoryType == .checkmark {
//                cell.accessoryType = .none
//            } else {
//                cell.accessoryType = .checkmark
//            }
//        }
        
        let cell = tableView.cellForRow(at: indexPath) as! RosterCell_Coach
        
        
        var locationArray: [Int] = []
        locationArray.append(indexPath.section)
        locationArray.append(indexPath.row)
        if cellTagArray.contains(locationArray) && cellFullNameCheckArray.contains(cell.fullNameLabel.text!) {
            let index = cellTagArray.firstIndex(of: locationArray)!
            cellTagArray.remove(at: index)
            cellFullNameCheckArray.remove(at: index)
        } else {
            cellTagArray.append(locationArray)
            cellFullNameCheckArray.append(cell.fullNameLabel.text!)
        }
        
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            } else {
                cell.accessoryType = .checkmark
            }
        
        
            
            //add/remove user from the array
            
            let selected = memberIdsOfGroupChat.contains(userToChat.objectId)
            
            
            if selected {
                let objectIndex = memberIdsOfGroupChat.firstIndex(of: userToChat.objectId)
                
                memberIdsOfGroupChat.remove(at: objectIndex!)
                membersOfGroupChat.remove(at: objectIndex!)
            } else {
                
                memberIdsOfGroupChat.append(userToChat.objectId)
                membersOfGroupChat.append(userToChat)
            }
            
            self.navigationItem.rightBarButtonItem?.isEnabled = memberIdsOfGroupChat.count > 1
        
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        if searchController.isActive && searchController.searchBar.text != "" {
            return ""
        } else {
            return self.sectionTitleList[section]
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
    
    
    
    func appendCheckMark(cell: UITableViewCell, row: Int) {
        
    }
    
    //MARK: Search controller functions
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
    
        filteredMatchedUsers = usersToShow.filter({ (user) -> Bool in
            
            return user.firstname.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
        
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func didTapAvatarImage(indexPath: IndexPath) {
        
    }
    
    fileprivate func splitDataIntoSection() {
          
          var sectionTitle: String = ""
          
          for i in 0..<self.usersToShow.count {
              
              let currentUser = self.usersToShow[i]
              
              let firstChar = currentUser.firstname.first!
              
              let firstCarString = "\(firstChar)"
              
              
              if firstCarString != sectionTitle {
                  
                  sectionTitle = firstCarString
                  
                  self.allUsersGrouped[sectionTitle] = []
                  
                  if !sectionTitleList.contains(sectionTitle) {
                      self.sectionTitleList.append(sectionTitle)
                  }
              }
              
              self.allUsersGrouped[firstCarString]?.append(currentUser)
              
          }
    
      }

}
