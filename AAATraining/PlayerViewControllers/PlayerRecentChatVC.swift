//
//  PlayerRecentChatVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/1/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import FirebaseFirestore

class PlayerRecentChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, RecentChatCell_CoachDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    
    var recentChats: [NSDictionary] = []
    var filteredChats: [NSDictionary] = []
    
    var recentListener: ListenerRegistration!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        //loadRecentChats()
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.tableView.tableFooterView = view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
        loadRecentChats()
        configureUI()
    //    self.tableView.reloadData()
        //tableView.tableFooterView = UIView()
    }
    
    func configureUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
         
         navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
         
         navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
         self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
         
         let attrs = [
             NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.font: UIFont(name: "PROGRESSPERSONALUSE", size: 34)!
         ]
         
         navigationController?.navigationBar.largeTitleTextAttributes = attrs
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fillContentGap:
        if let tableFooterView = self.tableView.tableFooterView {
            /// The expected height for the footer under autolayout.
            let footerHeight = tableFooterView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            /// The amount of empty space to fill with the footer view.
            let gapHeight: CGFloat = self.tableView.bounds.height - self.tableView.adjustedContentInset.top - self.tableView.adjustedContentInset.bottom - self.tableView.contentSize.height
            // Ensure there is space to be filled
            guard gapHeight.rounded() > 0 else { break fillContentGap }
            // Fill the gap
            tableFooterView.frame.size.height = gapHeight + footerHeight
        }
        
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
            self.tableView.reloadData()
        })

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredChats.count
        } else {
//            if recentChats.count == 0 {
//                var emptyLabelOne = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
//                emptyLabelOne.text = "Chats will appear if you've been added to a group!"
//                emptyLabelOne.textAlignment = NSTextAlignment.center
//                self.tableView.backgroundView = emptyLabelOne
//                self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
//                return 0
//            } else {
//                self.tableView.backgroundView = nil
                return recentChats.count
//            }
           
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
        
        //self.present(chatVC, animated: true, completion: nil)
        self.navigationController?.present(navController, animated: true, completion: nil)
        
        //navigationController?.pushViewController(chatVC, animated: true)
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
    
    func didTapAvatarImage(indexPath: IndexPath) {
        
    }
    
    


}
