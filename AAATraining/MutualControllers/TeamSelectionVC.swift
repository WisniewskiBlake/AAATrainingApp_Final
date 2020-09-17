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
    var teamLogos = [UIImage]()
    
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTeamsForUser()
        emptyLabelOne = UILabel(frame: CGRect(x: 0, y: -150, width: view.bounds.size.width, height: view.bounds.size.height))
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.tableFooterView = view
        

    }
    
    @objc func joinTeamViewClicked() {
        let teamLoginVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamLoginVC") as! TeamLoginVC
        
        teamLoginVC.modalPresentationStyle = .fullScreen
        self.present(teamLoginVC, animated: true, completion: nil)
        
    }
    
    @objc func createTeamViewClicked() {
        let teamRegisterVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamRegister") as! TeamRegisterVC
        
        teamRegisterVC.modalPresentationStyle = .fullScreen
        self.present(teamRegisterVC, animated: true, completion: nil)
    }
    
    @objc func loadTeamsForUser() {
        ProgressHUD.show()
        let query = reference(.Team).whereField(kTEAMMEMBERIDS, arrayContains: FUser.currentId()).order(by: kTEAMNAME, descending: false)
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
        
        cell.teamImageView.image = self.teamLogos[indexPath.row]
        cell.teamNameLabel.text = teams[indexPath.row].teamName
        cell.memberCountLabel.text = teams[indexPath.row].teamMemberCount
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if FUser.currentUser()?.accountType == "coach" {
            updateCurrentUserInFirestore(withValues: [kUSERCURRENTTEAMID : teams[indexPath.row].teamID]) { (success) in
                
                self.helper.instantiateViewController(identifier: "CoachTabBar", animated: true, by: self, completion: nil)
            }
            
        } else if FUser.currentUser()?.accountType == "player" {
            updateCurrentUserInFirestore(withValues: [kUSERCURRENTTEAMID : teams[indexPath.row].teamID]) { (success) in
                
                self.helper.instantiateViewController(identifier: "TabBar", animated: true, by: self, completion: nil)
            }
            
        } else {
            updateCurrentUserInFirestore(withValues: [kUSERCURRENTTEAMID : teams[indexPath.row].teamID]) { (success) in
                
                self.helper.instantiateViewController(identifier: "ParentTabBar", animated: true, by: self, completion: nil)
            }
        }
    }

}
