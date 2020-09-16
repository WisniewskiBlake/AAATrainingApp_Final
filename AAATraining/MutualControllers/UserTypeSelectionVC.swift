//
//  UserTypeSelectionVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/29/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class UserSelectionCellClass: UITableViewCell {
    
}

class UserTypeSelectionVC: UIViewController {
    
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var coachView: UIView!
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var containerView: UIView!
    

    var viewToGoTo = ""
    
    var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "", teamType: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        coachView.he
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           

        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)

           
       }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.navigationController?.navigationBar.isTranslucent = false
        if viewToGoTo == "PlayerRegister" {
            let pRegisterVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerRegister") as! RegisterVC
            pRegisterVC.team = self.team
            
            self.navigationController?.pushViewController(pRegisterVC, animated: true)
        } else if viewToGoTo == "ParentRegister" {
            let newGroupVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParentRegister") as! ParentRegisterVC
            newGroupVC.team = self.team
            
            self.navigationController?.pushViewController(newGroupVC, animated: true)
        } else if viewToGoTo == "CoachRegister" {
            let cRegisterVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CoachRegister") as! CoachRegisterVC
            cRegisterVC.team = self.team
            
            self.navigationController?.pushViewController(cRegisterVC, animated: true)
        }
    }
    
    // make corners rounded for any views (objects)
    func cornerRadius(for view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
    }
    
    // add blank view to the left side of the TextField (it'll act as a blank gap)
    func padding(for textField: UITextField) {
        let blankView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        textField.leftView = blankView
        textField.leftViewMode = .always
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}


