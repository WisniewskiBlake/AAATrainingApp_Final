//
//  TeamSelectionVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 9/16/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import UIKit

class TeamSelectionVC: UIViewController {
    
    
    @IBOutlet weak var joinTeamView: UIView!
    @IBOutlet weak var createTeamView: UIView!
    
    @IBOutlet weak var joinImageView: UIImageView!
    @IBOutlet weak var createImageView: UIImageView!
    
    let joinTapGestureRecognizer = UITapGestureRecognizer()
    let createTapGestureRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @objc func joinTeamViewClicked() {
        let coachRegisterVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CoachRegister") as! CoachRegisterVC
        
        coachRegisterVC.modalPresentationStyle = .fullScreen
        self.present(coachRegisterVC, animated: true, completion: nil)
    }
    
    @objc func createTeamViewClicked() {
        let coachRegisterVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CoachRegister") as! CoachRegisterVC
        
        coachRegisterVC.modalPresentationStyle = .fullScreen
        self.present(coachRegisterVC, animated: true, completion: nil)
    }

}
