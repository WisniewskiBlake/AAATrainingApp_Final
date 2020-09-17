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
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var coachImageView: UIImageView!
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var parentImageView: UIImageView!
       
    var viewToGoTo = ""
    
    let coachTapGestureRecognizer = UITapGestureRecognizer()
    let playerTapGestureRecognizer = UITapGestureRecognizer()
    let parentTapGestureRecognizer = UITapGestureRecognizer()
    
    let helper = Helper()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        coachTapGestureRecognizer.addTarget(self, action: #selector(self.coachViewClicked))
        coachView.isUserInteractionEnabled = true
        coachView.addGestureRecognizer(coachTapGestureRecognizer)
        
        playerTapGestureRecognizer.addTarget(self, action: #selector(self.playerViewClicked))
        playerView.isUserInteractionEnabled = true
        playerView.addGestureRecognizer(playerTapGestureRecognizer)
        
        parentTapGestureRecognizer.addTarget(self, action: #selector(self.parentViewClicked))
        parentView.isUserInteractionEnabled = true
        parentView.addGestureRecognizer(parentTapGestureRecognizer)
        
//        coachView_height.constant = containerView.frame.height/3
//        playerView_height.constant = containerView.frame.height/3
//        parentView_height.constant = containerView.frame.height/3
//        print(coachView_height.constant)
//        print(playerView_height.constant)
//        print(parentView_height.constant)
//        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
        coachImageView.layer.cornerRadius = coachImageView.frame.width / 2
        coachImageView.clipsToBounds = true
        playerImageView.layer.cornerRadius = playerImageView.frame.width / 2
               playerImageView.clipsToBounds = true
        parentImageView.layer.cornerRadius = parentImageView.frame.width / 2
               parentImageView.clipsToBounds = true
           self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)

    }
    
    @objc func coachViewClicked() {
        let coachRegisterVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CoachRegister") as! CoachRegisterVC

        coachRegisterVC.modalPresentationStyle = .fullScreen
        self.present(coachRegisterVC, animated: true, completion: nil)
    }
    
    @objc func playerViewClicked() {
        
       let playerRegisterVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerRegister") as! RegisterVC

       playerRegisterVC.modalPresentationStyle = .fullScreen
       self.present(playerRegisterVC, animated: true, completion: nil)

    }
    
    @objc func parentViewClicked() {
        let parentRegisterVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParentRegister") as! ParentRegisterVC

        parentRegisterVC.modalPresentationStyle = .fullScreen
        self.present(parentRegisterVC, animated: true, completion: nil)
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


