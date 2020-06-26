//
//  CoachRegisterVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 6/25/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class CoachRegisterVC: UIViewController {
    
    @IBOutlet weak var coachPassword_width: NSLayoutConstraint!
    @IBOutlet weak var nameView_width: NSLayoutConstraint!
    @IBOutlet weak var emailView_width: NSLayoutConstraint!
    @IBOutlet weak var passwordView_width: NSLayoutConstraint!
    
    @IBOutlet weak var contentView_width: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var coachPasswordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var emailContinueButton: UIButton!
    @IBOutlet weak var fullnameContinueButton: UIButton!
    
    
    
    
    @IBOutlet weak var footerView: UIView!
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView_width.constant = self.view.frame.width * 4
        coachPassword_width.constant = self.view.frame.width
        
    }
    

    

}
