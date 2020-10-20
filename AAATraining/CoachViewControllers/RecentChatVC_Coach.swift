//
//  RecentChatVC_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/23/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import FirebaseFirestore

class RecentChatVC_Coach: UIViewController, UITableViewDelegate, UITableViewDataSource, RecentChatCell_CoachDelegate, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
   
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    var recentChats: [NSDictionary] = []
    var filteredChats: [NSDictionary] = []
    var avas = [UIImage]()
    var recentListener: ListenerRegistration!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var feedHeader: UIView!
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var teamImageView: UIImageView!
    
    @IBOutlet weak var titleView: UIView!
    var emptyLabelOne = UILabel()
    let helper = Helper()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    let screenRect = UIScreen.main.bounds
    
    
    var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "", teamType: "", teamMemberCount: "", teamMemberAccountTypes: [""])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        
        emptyLabelOne = UILabel(frame: CGRect(x: 0, y: -125, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        
        backgroundView.layer.cornerRadius = CGFloat(25.0)
        
        backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadRecentChats()
        configureUI()
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.tableView.tableFooterView = view
        
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
    
    
    
    func configureUI () {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
//        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
//        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        //self.tableView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        //titleView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        //self.tableView.backgroundColor = .white
//        if self.recentChats.count == 0 {
//            tableView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
//        }
//
//        if emptyLabelOne.text == "No chats to show!" {
//            emptyLabelOne.text = ""
//        }
        
        team.getTeam(teamID: FUser.currentUser()!.userCurrentTeamID) { (teamReturned) in
            if teamReturned.teamID != "" {
                self.team = teamReturned
                if self.team.teamLogo != "" {
                    self.helper.imageFromData(pictureData: self.team.teamLogo) { (coverImage) in

                        if coverImage != nil {
                            self.teamImageView.image = coverImage
                        }
                    }
                } else {
                    self.teamImageView.image = UIImage(named: "HomeCover.jpg")
                    
                }
            } else {
                self.teamImageView.image = UIImage(named: "HomeCover.jpg")
            }
        }
        teamImageView.layer.cornerRadius = teamImageView.frame.width / 2
        teamImageView.clipsToBounds = true
        

//        searchContainer.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
//        searchContainer.borderColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
//        searchContainer.borderWidth = CGFloat(1.0)
        
        
        let screenWidth = screenRect.size.width
        backgroundView.backgroundColor = UIColor.white
        
        mainView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        headerView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
        searchController.searchBar.delegate = self
        searchController.delegate = self
//        searchController.searchBar.searchTextField.frame = CGRect(x: 0, y: 3, width: self.searchContainer.frame.width, height: self.searchContainer.frame.height - 3);
        searchController.searchBar.frame = CGRect(x: -5, y: 0, width: screenWidth - 3, height: 41.0)

        searchContainer.backgroundColor = UIColor.white
        searchController.searchBar.backgroundColor = UIColor.white
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.isTranslucent = true
        searchController.searchBar.borderWidth = CGFloat(2.0)
        searchController.searchBar.borderColor = UIColor.white
        //searchController.searchBar.searchTextField.backgroundColor = .systemGray4
        searchContainer.addSubview(searchController.searchBar)
        
        //tableView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        //searchContainer.bringSubviewToFront(searchController.searchBar)
        
        
        searchController.searchBar.searchTextField.clipsToBounds = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        definesPresentationContext = true
        extendedLayoutIncludesOpaqueBars = true
        //self.tableView.reloadData()
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    //MARK: LoadRecentChats
    
    func loadRecentChats() {
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).whereField(kRECENTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID).addSnapshotListener({ (snapshot, error) in
            let helper = Helper()
            guard let snapshot = snapshot else { return }
            
            self.recentChats = []
            
            if !snapshot.isEmpty {
                
                let sorted = ((helper.dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                
                for recent in sorted {
                    
                    //CHANGE THIS IF YOU WANT TO CHANGE THE FACT THAT GROUPS ARENT CREATED/SHOWN UNLESS A MESSAGE IS SENT
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                        
                        self.recentChats.append(recent)
                        self.helper.imageFromData(pictureData: recent[kAVATAR] as! String) { (avatarImage) in

                            if avatarImage != nil {
                                self.avas.append(avatarImage!.circleMasked!)
                            }
                        }
                    }
                    
                    reference(.Recent).whereField(kCHATROOMID, isEqualTo: recent[kCHATROOMID] as! String).getDocuments(completion: { (snapshot, error) in
                        
                    })
                }
                
                self.tableView.reloadData()
            }
            self.tableView.reloadData()
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
            if recentChats.count == 0 {
                
                emptyLabelOne.text = "No chats to show!"
                emptyLabelOne.textAlignment = NSTextAlignment.center
                emptyLabelOne.font = UIFont(name: "Helvetica Neue", size: 15)
                emptyLabelOne.textColor = UIColor.lightGray
                self.tableView.tableFooterView!.addSubview(emptyLabelOne)
                return 0
            } else {
                emptyLabelOne.text = ""
                emptyLabelOne.removeFromSuperview()
                return recentChats.count
            }
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
        
//           cell.avatarImageView.image = avas[indexPath.row]
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

//        let navigation = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatNavigation") as! UINavigationController
        
        
     
        
        //self.present(navigation, animated: true, completion: nil)
        
        //let chatVC = ChatVC_Coach()
        chatVC.hidesBottomBarWhenPushed = true
        chatVC.title = (recent[kWITHUSERFULLNAME] as? String)!
        chatVC.memberIds = (recent[kMEMBERS] as? [String])!
        chatVC.membersToPush = (recent[kMEMBERSTOPUSH] as? [String])!
        chatVC.chatRoomId = (recent[kCHATROOMID] as? String)!
        chatVC.isGroup = (recent[kTYPE] as! String) == kGROUP
        //chatVC.allMembers = (recent[kMEMBERS])!
        
        self.present(navController, animated: true, completion: nil)
        //self.navigationController?.present(navController, animated: true, completion: nil)
        
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
    


     
    

}
