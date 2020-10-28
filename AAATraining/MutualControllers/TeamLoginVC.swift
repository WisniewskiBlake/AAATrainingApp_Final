//
//  TeamLoginVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/23/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import ProgressHUD

class TeamLoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var teamCodeText: UITextField!
    @IBOutlet weak var registerTeamLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    var userAccountType = ""
    let helper = Helper()   
    var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "", teamType: "", teamMemberCount: "", teamMemberAccountTypes: [""])
    
    let registerTeamTapGestureRecognizer = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure_continueBtn()

        registerTeamTapGestureRecognizer.addTarget(self, action: #selector(self.registerTeamClicked))
        registerTeamLabel.isUserInteractionEnabled = true
        registerTeamLabel.addGestureRecognizer(registerTeamTapGestureRecognizer)
        
        self.teamCodeText.delegate = self
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //need to check if the user is already part of a team
    @IBAction func continueButtonClicked(_ sender: Any) {
        let isPlayer = self.userAccountType.capitalizingFirstLetter() == "Player"
        
        if teamCodeText.text != "" {
            team.getTeam(teamID: teamCodeText.text!) { (teamReturned) in
                if teamReturned.teamID != "" {
                    self.team = teamReturned
                    if !self.team.teamMemberIDs.contains(FUser.currentId()) {
                        
                        let teamMemberCount = Int(teamReturned.teamMemberCount)! + 1
                        var accTypesArray = self.team.teamMemberAccountTypes
                        accTypesArray.append(self.userAccountType.capitalizingFirstLetter())
                        
                        Team.updateTeam(teamID: self.team.teamID, withValues: [kTEAMMEMBERIDS: FieldValue.arrayUnion([FUser.currentId()]), kTEAMMEMBERCOUNT: String(teamMemberCount), kTEAMMEMBERACCOUNTTYPES : accTypesArray])
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "joinedTeam"), object: nil)
                        
                        var userTeamAccTypeArray: [String]? = []
                        var userIsNewObserverArray: [String]? = []
                        fetchCurrentUserFromFirestore(userId: FUser.currentId(), completion: { (user) in

                           if user != nil && user!.firstname != "" {
                            //we have user, login
                            userTeamAccTypeArray = user?.userTeamAccountTypes
                            userTeamAccTypeArray!.append(self.userAccountType.capitalizingFirstLetter())
                            
                            userIsNewObserverArray = user?.userIsNewObserverArray
                            userIsNewObserverArray!.append("Yes")
                            
                            updateUserInFirestore(objectID: FUser.currentId(), withValues: [kUSERTEAMIDS : FieldValue.arrayUnion([self.team.teamID]), kUSERTEAMACCOUNTTYPES : userTeamAccTypeArray, kUSERTEAMNAMES : FieldValue.arrayUnion([self.team.teamName]), kUSERTEAMMEMBERS : FieldValue.arrayUnion([FUser.currentId()]), kUSERTEAMMEMBERCOUNT : FieldValue.arrayUnion([String(teamMemberCount)]), kUSERISNEWOBSERVERARRAY : userIsNewObserverArray]) { (success) in
                                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamSelectionVC") as? TeamSelectionVC
                                {
                                    vc.modalPresentationStyle = .fullScreen
                                    self.present(vc, animated: true, completion: nil)
                                }
                            }
                            if isPlayer {
                                let localReference = reference(.PlayerStat).document()
                                let statId = localReference.documentID
                                var stats: [String : Any]!
                                stats = [kPLAYERSTATID: statId, kPLAYERSTATUSERID: FUser.currentId(), kPLAYERSTATTEAMID: self.team.teamID, kPLAYERSTATHEIGHT: "", kPLAYERSTATWEIGHT: "", kPLAYERSTATPOSITION: "", kPLAYERSTATNUMBER: ""] as [String:Any]
                                localReference.setData(stats)
                            }
                            
                           } else {

                           }

                        })
                        
                        
                        
                        
                        
                    } else {
                        self.helper.showAlert(title: "Invadlid ID", message: "You're already on this team!", in: self)
                    }
                    
                } else {
                    self.helper.showAlert(title: "Invadlid ID", message: "Team ID does not exist!", in: self)
                }
            }
        } else {
            self.helper.showAlert(title: "Invadlid ID", message: "Team ID does not exist!", in: self)
        }
        
    }
    
    func configure_continueBtn() {
        continueButton.layer.cornerRadius = 5
        continueButton.layer.masksToBounds = true
        //loginButton.isEnabled = false
    }
    
    func loadTeam() {
        //this will load the team and set the current user defaults to team color and logo
        

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func registerTeamClicked() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamSelectionVC") as? TeamSelectionVC
        {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // exec whenever the screen has been tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        teamCodeText.resignFirstResponder()
    }


}
