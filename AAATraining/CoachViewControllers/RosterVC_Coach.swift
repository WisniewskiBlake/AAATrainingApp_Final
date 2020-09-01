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
    var filteredUsers: [FUser] = []
    var allUsersGroupped = NSDictionary() as! [String : [FUser]]
    var sectionTitleList : [String] = []
    var userListener: ListenerRegistration!
    
    var isLoading = false
    let helper = Helper()
    var skip = 0
    var limit = 10
    
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBAction func filterSegmentValueChanged(_ sender: UISegmentedControl) {
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        self.setLeftAlignedNavigationItemTitle(text: "Roster", color: .white, margin: 12)
        
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        loadUsers(filter: "")
        
    }
    
    func loadUsers(filter: String) {
           isLoading = true
           ProgressHUD.show()
           
           var query: Query!
           
           switch filter {
            case "player":
                query = reference(.User).whereField("accountType", isEqualTo: "player").order(by: kFIRSTNAME, descending: false)
           case ("coach"):
               query = reference(.User).whereField("accountType", isEqualTo: "coach").order(by: kFIRSTNAME, descending: false)
            case ("parent"):
                query = reference(.User).whereField("accountType", isEqualTo: "parent").order(by: kFIRSTNAME, descending: false)
           default:
               query = reference(.User).order(by: kFIRSTNAME, descending: false)
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
    
    //MARK: Helper functions
      
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
        
        
        
        cell.generateCellWith(fUser: user, indexPath: indexPath)
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

        if(user.accountType == "player") {
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
        reference(.User).document(user.objectId).delete() { err in
        if let err = err {
            print("Error removing document: \(err)")
        } else {
            print("Document successfully removed!")
        }
    }
        self.tableView.reloadData()

    

}
}
