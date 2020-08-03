//
//  ParentRegisterVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/29/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class ParentRegisterVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailContinueButton: UIButton!
    @IBOutlet weak var nameContinueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func emailContinueClicked(_ sender: Any) {
    }
    
    @IBAction func nameContinueClicked(_ sender: Any) {
    }
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
    }
    
}
