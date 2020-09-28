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
    
    var imageview = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        do {
            let gif = try UIImage(gifName: "loaderFinal.gif")
            imageview = UIImageView(gifImage: gif, loopCount: -1) // Will loop 3 times
            let screenSize: CGRect = view.bounds
            imageview.frame = CGRect(x: screenSize.width * 0.31, y: screenSize.height * 0.47, width: screenSize.width * 0.41, height: screenSize.height * 0.33)
            //imageview.frame = view.bounds

            view.addSubview(imageview)
        } catch {
            print(error)
        }
        self.imageview.startAnimatingGif()
        
        loadTeamsForUser()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
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
        
        let teamRegisterVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamRegisterVC") as! TeamRegisterVC
        teamRegisterVC.userAccountType = "Coach"
        teamRegisterVC.modalPresentationStyle = .fullScreen
        self.present(teamRegisterVC, animated: true, completion: nil)
        
//        let userTypeSelectionVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserTypeSelectionVC") as! UserTypeSelectionVC
//        userTypeSelectionVC.viewToGoTo = "create"
//        userTypeSelectionVC.modalPresentationStyle = .fullScreen
//        self.present(userTypeSelectionVC, animated: true, completion: nil)

    }

    @objc func loadTeamsForUser() {
        
            let query = reference(.Team).whereField(kTEAMMEMBERIDS, arrayContains: FUser.currentId())
            query.getDocuments { (snapshot, error) in
    
                self.teams = []
                self.teamLogos = []
    
                if error != nil {
                    print(error!.localizedDescription)
                    self.imageview.removeFromSuperview()
                 self.helper.showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
    
                    return
                }
    
                guard let snapshot = snapshot else {
                    self.helper.showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                    self.imageview.removeFromSuperview(); return
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
                    self.imageview.removeFromSuperview()
                }
                self.tableView.reloadData()
                
                self.imageview.removeFromSuperview()
                
            }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if teams.count == 0 {
            emptyLabelOne = UILabel(frame: CGRect(x: 0, y: -150, width: view.bounds.size.width, height: view.bounds.size.height))
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
        var i = 0
        for IDs in teams[indexPath.row].teamMemberIDs {
            if FUser.currentId() == IDs {
                index = i
            }
            i += 1
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
        var i = 0
        for IDs in teams[indexPath.row].teamMemberIDs {
            if FUser.currentId() == IDs {
                index = i
            }
            i += 1
        }

        if teams[indexPath.row].teamMemberAccountTypes[index] == "Coach" {
            updateCurrentUserInFirestore(withValues: [kUSERCURRENTTEAMID : teams[indexPath.row].teamID, kACCOUNTTYPE : "Coach"]) { (success) in
                
                self.helper.instantiateViewController(identifier: "CoachTabBar", animated: true, by: self, completion: nil)
            }
            
        } else if teams[indexPath.row].teamMemberAccountTypes[index] == "Player" {
            updateCurrentUserInFirestore(withValues: [kUSERCURRENTTEAMID : teams[indexPath.row].teamID, kACCOUNTTYPE : "Player"]) { (success) in
                
                self.helper.instantiateViewController(identifier: "TabBar", animated: true, by: self, completion: nil)
            }
            
        } else {
            updateCurrentUserInFirestore(withValues: [kUSERCURRENTTEAMID : teams[indexPath.row].teamID, kACCOUNTTYPE : "Parent"]) { (success) in
                
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
