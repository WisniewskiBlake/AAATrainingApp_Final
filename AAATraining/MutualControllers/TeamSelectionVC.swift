//
//  TeamSelectionVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 9/16/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import ProgressHUD

class TeamSelectionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var joinTeamView: UIView!
    @IBOutlet weak var createTeamView: UIView!
    
    @IBOutlet weak var joinImageView: UIImageView!
    @IBOutlet weak var createImageView: UIImageView!
    
    let joinTapGestureRecognizer = UITapGestureRecognizer()
    let createTapGestureRecognizer = UITapGestureRecognizer()
    
    let helper = Helper()
    var emptyLabelOne = UILabel()
    
    var teams: [Team] = []
    var currentUser = FUser()
    var teamLogos = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(loadTeams), name: NSNotification.Name(rawValue: "joinedTeam"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(loadTeams), name: NSNotification.Name(rawValue: "createdTeam"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadTeamsForUser), name: NSNotification.Name(rawValue: "joinedTeam"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadTeamsForUser), name: NSNotification.Name(rawValue: "createdTeam"), object: nil)

        
        joinImageView.layer.cornerRadius = joinImageView.frame.width / 2
        joinImageView.clipsToBounds = true
        createImageView.layer.cornerRadius = createImageView.frame.width / 2
        createImageView.clipsToBounds = true
        
        joinTapGestureRecognizer.addTarget(self, action: #selector(self.joinTeamViewClicked))
        joinTeamView.isUserInteractionEnabled = true
        joinTeamView.addGestureRecognizer(joinTapGestureRecognizer)
        
        createTapGestureRecognizer.addTarget(self, action: #selector(self.createTeamViewClicked))
        createTeamView.isUserInteractionEnabled = true
        createTeamView.addGestureRecognizer(createTapGestureRecognizer)
        
//        loadTeams()
//        loadUser()

        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTeamsForUser()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        emptyLabelOne = UILabel(frame: CGRect(x: 0, y: -150, width: view.bounds.size.width, height: view.bounds.size.height))
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.tableFooterView = view
        

    }
    
    @objc func joinTeamViewClicked() {
        
        let userTypeSelectionVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserTypeSelectionVC") as! UserTypeSelectionVC
        userTypeSelectionVC.viewToGoTo = "join"
        userTypeSelectionVC.modalPresentationStyle = .fullScreen
        self.present(userTypeSelectionVC, animated: true, completion: nil)
//        let teamLoginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserTypeSelectionVC") as! UserTypeSelectionVC
//
//        teamLoginVC.modalPresentationStyle = .fullScreen
//        self.present(teamLoginVC, animated: true, completion: nil)
        
    }
    
    @objc func createTeamViewClicked() {
        
        let userTypeSelectionVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserTypeSelectionVC") as! UserTypeSelectionVC
        userTypeSelectionVC.viewToGoTo = "create"
        userTypeSelectionVC.modalPresentationStyle = .fullScreen
        self.present(userTypeSelectionVC, animated: true, completion: nil)
//        let teamRegisterVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamRegisterVC") as! TeamRegisterVC
//
//        teamRegisterVC.modalPresentationStyle = .fullScreen
//        self.present(teamRegisterVC, animated: true, completion: nil)
    }

    @objc func loadTeamsForUser() {
            ProgressHUD.show()
            let query = reference(.Team).whereField(kTEAMMEMBERIDS, arrayContains: FUser.currentId())
            query.getDocuments { (snapshot, error) in
    
                self.teams = []
                self.teamLogos = []
    
                if error != nil {
                    print(error!.localizedDescription)
                    ProgressHUD.dismiss()
                 self.helper.showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
    
                    return
                }
    
                guard let snapshot = snapshot else {
                    self.helper.showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                    ProgressHUD.dismiss(); return
                }
    
                if !snapshot.isEmpty {
    
                    for teamDictionary in snapshot.documents {
    
                        let teamDictionary = teamDictionary.data() as NSDictionary
                        let team = Team(_dictionary: teamDictionary)
                        self.teams.append(team)
                        self.helper.imageFromData(pictureData: team.teamLogo) { (avatarImage) in
    
                            if avatarImage != nil {
                                self.teamLogos.append(avatarImage!.circleMasked!)
                            }
                        }
    
                    }
                    self.tableView.reloadData()
                }
                self.tableView.reloadData()
                ProgressHUD.dismiss()
            }
    }
    
//    @objc func loadUser() {
//
//        ProgressHUD.show()
//        let query2 = reference(.User).whereField(kOBJECTID, isEqualTo: FUser.currentId())
//
//            query2.getDocuments { (snapshot, error) in
//                self.currentUser = FUser()
//
//
//
//                if error != nil {
//                    print(error!.localizedDescription)
//
//                    return
//                }
//
//                guard let snapshot = snapshot else {
//                    return
//                }
//
//                if !snapshot.isEmpty {
//
//                    for userDoc in snapshot.documents {
//                        let userDoc = userDoc.data() as NSDictionary
//                        let userCurr = FUser(_dictionary: userDoc)
//                        self.currentUser = userCurr
//                    }
//
//
//                self.tableView.reloadData()
//                }
//            self.tableView.reloadData()
//            ProgressHUD.dismiss()
//            }
//    }
//
//    func loadTeams() {
//        var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "", teamType: "", teamMemberCount: "", teamMemberAccountTypes: [""])
//        self.teams = []
//        self.teamLogos = []
//        for teamID in self.currentUser.userTeamIDs {
//            if teamID != "" {
//                team.getTeam(teamID: teamID) { (teamReturned) in
//                    team = teamReturned
//                    self.teams.append(teamReturned)
//                    self.helper.imageFromData(pictureData: teamReturned.teamLogo) { (avatarImage) in
//
//                        if avatarImage != nil {
//                            self.teamLogos.append(avatarImage!.circleMasked!)
//                        }
//                    }
//                }
//            }
//
//        }
//    }
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if teams.count == 0 {
            emptyLabelOne.text = "No teams to show!"
            emptyLabelOne.textAlignment = NSTextAlignment.center
            self.tableView.tableFooterView!.addSubview(emptyLabelOne)
            return 0
        } else {
            emptyLabelOne.text = ""
            emptyLabelOne.removeFromSuperview()
            return self.teams.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath) as! TeamCell
        print(indexPath.row)
        
        var index = 0
        for IDs in teams[indexPath.row].teamMemberIDs {
            if FUser.currentId() != IDs {
                index += 1
            }
        }
        
        
        cell.teamImageView.image = self.teamLogos[indexPath.row]
        cell.teamNameLabel.text = teams[indexPath.row].teamName
        cell.memberCountLabel.text = teams[indexPath.row].teamMemberCount + " Team Members"

       // cell.accountTypeLabel.text = currentUser.userTeamAccountTypes[indexPath.row]
        cell.accountTypeLabel.text = teams[indexPath.row].teamMemberAccountTypes[index]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var index = 0
        for IDs in teams[indexPath.row].teamMemberIDs {
            if FUser.currentId() != IDs {
                index += 1
            }
        }

        if teams[indexPath.row].teamMemberAccountTypes[index] == "Coach" {
            updateCurrentUserInFirestore(withValues: [kUSERCURRENTTEAMID : teams[indexPath.row].teamID]) { (success) in
                
                self.helper.instantiateViewController(identifier: "CoachTabBar", animated: true, by: self, completion: nil)
            }
            
        } else if teams[indexPath.row].teamMemberAccountTypes[index] == "Player" {
            updateCurrentUserInFirestore(withValues: [kUSERCURRENTTEAMID : teams[indexPath.row].teamID]) { (success) in
                
                self.helper.instantiateViewController(identifier: "TabBar", animated: true, by: self, completion: nil)
            }
            
        } else {
            updateCurrentUserInFirestore(withValues: [kUSERCURRENTTEAMID : teams[indexPath.row].teamID]) { (success) in
                
                self.helper.instantiateViewController(identifier: "ParentTabBar", animated: true, by: self, completion: nil)
            }
        }
    }
    
    @IBAction func more_clicked(_ sender: Any) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        // creating buttons for action sheet
        let logout = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) in
                        
            FUser.logOutCurrentUser { (success) in
                
                if success {
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                    {
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // add buttons to action sheet
        sheet.addAction(logout)
        sheet.addAction(cancel)
        
        // show action sheet
        present(sheet, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    

}
