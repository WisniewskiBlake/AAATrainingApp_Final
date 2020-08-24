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

class TeamLoginVC: UIViewController {
    
    @IBOutlet weak var teamCodeText: UITextField!
    @IBOutlet weak var registerTeamLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    
    let registerTeamTapGestureRecognizer = UITapGestureRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()

        registerTeamTapGestureRecognizer.addTarget(self, action: #selector(self.registerTeamClicked))
        registerTeamLabel.isUserInteractionEnabled = true
        registerTeamLabel.addGestureRecognizer(registerTeamTapGestureRecognizer)
    }
    
    @IBAction func continueButtonClicked(_ sender: Any) {
        
    }
    
    @objc func registerTeamClicked() {
        
    }


}
