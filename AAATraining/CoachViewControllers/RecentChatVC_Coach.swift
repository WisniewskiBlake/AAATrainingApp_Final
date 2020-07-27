//
//  RecentChatVC_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/23/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import FirebaseFirestore

class RecentChatVC_Coach: UIViewController, UITableViewDelegate, UITableViewDataSource, RecentChatCell_CoachDelegate, UISearchResultsUpdating {
   
    @IBOutlet weak var tableView: UITableView!
    
    
    
    var recentChats: [NSDictionary] = []
    var filteredChats: [NSDictionary] = []
    
    var recentListener: ListenerRegistration!
    
    let searchController = UISearchController(searchResultsController: nil)

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadRecentChats()
    //    self.tableView.reloadData()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    //MARK: LoadRecentChats
    
    func loadRecentChats() {
        
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            let helper = Helper()
            guard let snapshot = snapshot else { return }
            
            self.recentChats = []
            
            if !snapshot.isEmpty {
                
                let sorted = ((helper.dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                
                for recent in sorted {
                    
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                        
                        self.recentChats.append(recent)
                    }
                    
                    reference(.Recent).whereField(kCHATROOMID, isEqualTo: recent[kCHATROOMID] as! String).getDocuments(completion: { (snapshot, error) in
                        
                    })
                }
                
                self.tableView.reloadData()
            }

        })

    }
    

   @IBAction func createNewGroupButtonPressed(_ sender: Any) {
        selectUserForChat(isGroup: true)
    }
    
    //MARK: TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredChats.count
        } else {
           return recentChats.count
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "RecentCell", for: indexPath) as! RecentChatCell_Coach
           
           cell.delegate = self
           
           var recent: NSDictionary!
           
           
           if searchController.isActive && searchController.searchBar.text != "" {
               recent = filteredChats[indexPath.row]
           } else {
               recent = recentChats[indexPath.row]
           }
           
           cell.generateCell(recentChat: recent, indexPath: indexPath)
           
           
           
           return cell
       }
    
    //MARK: TableViewDelegate functions
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var tempRecent: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            tempRecent = filteredChats[indexPath.row]
        } else {
            tempRecent = recentChats[indexPath.row]
        }

        var muteTitle = "Unmute"
        var mute = false
        
        
        if (tempRecent[kMEMBERSTOPUSH] as! [String]).contains(FUser.currentId()) {
            
            muteTitle = "Mute"
            mute = true
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            self.recentChats.remove(at: indexPath.row)
            
            deleteRecentChat(recentChatDictionary: tempRecent)
            
            self.tableView.reloadData()
        }
        
        
        let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { (action, indexPath) in
            
            self.updatePushMembers(recent: tempRecent, mute: mute)
        }
        
        muteAction.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        
        return [deleteAction, muteAction]
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var recent: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            recent = filteredChats[indexPath.row]
        } else {
            recent = recentChats[indexPath.row]
        }

        restartRecentChat(recent: recent)
        
        let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatVC_Coach
        let navController = UINavigationController(rootViewController: chatVC)
        
        
        //let chatVC = ChatVC_Coach()
        chatVC.hidesBottomBarWhenPushed = true
        chatVC.title = (recent[kWITHUSERFULLNAME] as? String)!
        chatVC.memberIds = (recent[kMEMBERS] as? [String])!
        chatVC.membersToPush = (recent[kMEMBERSTOPUSH] as? [String])!
        chatVC.chatRoomId = (recent[kCHATROOMID] as? String)!
        chatVC.isGroup = (recent[kTYPE] as! String) == kGROUP
        //chatVC.allMembers = (recent[kMEMBERS])!
        
//        let backItem = UIBarButtonItem()
//        backItem.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//        navigationItem.backBarButtonItem = backItem
        
        
        //self.present(chatVC, animated: true, completion: nil)
        self.navigationController?.present(navController, animated: true, completion: nil)
        
        //navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func selectUserForChat(isGroup: Bool) {
           
           let contactsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "contactsView") as! ContactsVC_Coach
           let navigation = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addMembersNav") as! UINavigationController
           contactsVC.isGroup = isGroup
        
           
           self.present(navigation, animated: true, completion: nil)
           //self.navigationController?.pushViewController(contactsVC, animated: true)
       }
    
    
       
       func didTapAvatarImage(indexPath: IndexPath) {
//           var recentChat: NSDictionary!
//
//           if searchController.isActive && searchController.searchBar.text != "" {
//               recentChat = filteredChats[indexPath.row]
//           } else {
//               recentChat = recentChats[indexPath.row]
//           }
//
//           if recentChat[kTYPE] as! String == kPRIVATE {
//
//               reference(.User).document(recentChat[kWITHUSERUSERID] as! String).getDocument { (snapshot, error) in
//
//                   guard let snapshot = snapshot else { return }
//
//                   if snapshot.exists {
//
//                       let userDictionary = snapshot.data() as! NSDictionary
//
//                       let tempUser = FUser(_dictionary: userDictionary)
//
//                       self.showUserProfile(user: tempUser)
//                   }
//
//               }
//           }
       }
       
       //MARK: Search controller functions
       
       func filterContentForSearchText(searchText: String, scope: String = "All") {
           
           filteredChats = recentChats.filter({ (recentChat) -> Bool in
               
               return (recentChat[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())
           })
           
           tableView.reloadData()
       }
       
       func updateSearchResults(for searchController: UISearchController) {
           
           filterContentForSearchText(searchText: searchController.searchBar.text!)
       }
    
    //MARK: Helper functions
    
   
    
    func updatePushMembers(recent: NSDictionary, mute: Bool) {
        
        var membersToPush = recent[kMEMBERSTOPUSH] as! [String]
        
        if mute {
            let index = membersToPush.firstIndex(of: FUser.currentId())!
            membersToPush.remove(at: index)
        } else {
            membersToPush.append(FUser.currentId())
        }
        
        updateExistingRicentWithNewValues(chatRoomId: recent[kCHATROOMID] as! String, members: recent[kMEMBERS] as! [String], withValues: [kMEMBERSTOPUSH : membersToPush])
        
    }
    
//    func showUserProfile(user: FUser) {
//
//        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileViewTableViewController
//
//        profileVC.user = user
//        self.navigationController?.pushViewController(profileVC, animated: true)
//    }
    
     //MARK: Custom tableViewHeader
        
//        func setTableViewHeader() {
//
//    //        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45))
//    //
//    //        let buttonView = UIView(frame: CGRect(x: 0, y: 5, width: tableView.frame.width, height: 35))
//    //        let groupButton = UIButton(frame: CGRect(x: tableView.frame.width - 110, y: 10, width: 100, height: 20))
//    //        groupButton.addTarget(self, action: #selector(self.createNewGroupButtonPressed), for: .touchUpInside)
//    //        groupButton.setTitle("New Group", for: .normal)
//    //        let buttonColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
//    //        groupButton.setTitleColor(buttonColor, for: .normal)
//    //
//    //
//    //        let lineView = UIView(frame: CGRect(x: 0, y: headerView.frame.height - 1, width: tableView.frame.width, height: 1))
//    //        lineView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
//    //
//    //        buttonView.addSubview(groupButton)
//    //        headerView.addSubview(buttonView)
//    //        headerView.addSubview(lineView)
//    //
//    //        tableView.tableHeaderView = headerView
//        }
    

}
