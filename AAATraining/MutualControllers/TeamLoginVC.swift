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
    let helper = Helper()   
    var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "", teamType: "")
    
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
    
    @IBAction func continueButtonClicked(_ sender: Any) {
        if teamCodeText.text != "" {
            team.getTeam(teamID: teamCodeText.text!) { (teamReturned) in
                if teamReturned.teamID != "" {
                    self.team = teamReturned
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                    {
                        vc.team = self.team
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
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
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamRegisterVC") as? TeamRegisterVC
        {
            vc.modalPresentationStyle = .automatic
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // exec whenever the screen has been tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        teamCodeText.resignFirstResponder()
    }


}
