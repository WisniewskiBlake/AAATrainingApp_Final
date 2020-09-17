//
//  TeamSelectionVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 9/16/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import UIKit

class TeamSelectionVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTeamsForUser()

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
    
    func loadTeamsForUser() {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
    }

}
