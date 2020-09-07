//
//  ParentRegisterVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/29/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import ProgressHUD

class ParentRegisterVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var coachPassword_width: NSLayoutConstraint!
    @IBOutlet weak var nameView_width: NSLayoutConstraint!
    @IBOutlet weak var emailView_width: NSLayoutConstraint!
    @IBOutlet weak var passwordView_width: NSLayoutConstraint!
    @IBOutlet weak var contentView_width: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var emailContinueButton: UIButton!
    @IBOutlet weak var nameContinueButton: UIButton!
    @IBOutlet weak var phoneContinueButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    
    @IBOutlet weak var footerView: UIView!
    
    var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "")
    
    var email: String!
    var password: String!
    let height = "123456789"
    let weight = "123456789"
    let position = "parent"
    let number = "123456789"
    var id: Any!
    var birthday: Any!
    var cover = UIImage(named: "aaaCoverLogo.png")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentView_width.constant = self.view.frame.width * 4
        coachPassword_width.constant = self.view.frame.width
        nameView_width.constant = self.view.frame.width
        emailView_width.constant = self.view.frame.width
        passwordView_width.constant = self.view.frame.width
        
        cornerRadius(for: firstNameTextField)
        cornerRadius(for: lastNameTextField)
        cornerRadius(for: emailTextField)
        cornerRadius(for: passwordTextField)
        cornerRadius(for: phoneTextField)
        
        cornerRadius(for: emailContinueButton)
        cornerRadius(for: nameContinueButton)
        cornerRadius(for: phoneContinueButton)
        cornerRadius(for: finishButton)
        
        padding(for: emailTextField)
        padding(for: firstNameTextField)
        padding(for: lastNameTextField)
        padding(for: passwordTextField)
        padding(for: phoneTextField)
        
        self.emailTextField.delegate = self
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.phoneTextField.delegate = self
        
        
        configure_footerView()
        
        configureButtons()
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    
    func configureButtons() {
//        emailContinueButton.backgroundColor = UIColor(hexString: team.teamColorOne)
//        nameContinueButton.backgroundColor = UIColor(hexString: team.teamColorOne)
//        phoneContinueButton.backgroundColor = UIColor(hexString: team.teamColorOne)
//        finishButton.backgroundColor = UIColor(hexString: team.teamColorOne)
        emailContinueButton.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        nameContinueButton.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        phoneContinueButton.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        finishButton.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
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
    
    // configuring the appearance of the footerView
    func configure_footerView() {
        // adding the line at the top of the footerView
        let topLine = CALayer()
        topLine.borderWidth = 1
        topLine.borderColor = UIColor.lightGray.cgColor
        topLine.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1)
        
        footerView.layer.addSublayer(topLine)
    }
    
    @IBAction func emailContinueClicked(_ sender: Any) {
        // move scrollView horizontally (by X to the WIDTH as a pointer)
        let position = CGPoint(x: self.view.frame.width, y: 0)
        scrollView.setContentOffset(position, animated: true)
        
        // show keyboard of next TextField
        if firstNameTextField.text!.isEmpty {
            firstNameTextField.becomeFirstResponder()
        } else if lastNameTextField.text!.isEmpty {
            lastNameTextField.becomeFirstResponder()
        } else if firstNameTextField.text!.isEmpty == false && lastNameTextField.text!.isEmpty == false {
            firstNameTextField.resignFirstResponder()
            lastNameTextField.resignFirstResponder()
        }
    }
    
    @IBAction func nameContinueClicked(_ sender: Any) {
        let position = CGPoint(x: self.view.frame.width * 2, y: 0)
        scrollView.setContentOffset(position, animated: true)
        
        // show keyboard of next TextField
        if phoneTextField.text!.isEmpty {
            phoneTextField.becomeFirstResponder()
        } else if phoneTextField.text!.isEmpty == false {
            phoneTextField.resignFirstResponder()
        }
    }
    
    @IBAction func phoneContinueClicked(_ sender: Any) {
        let position = CGPoint(x: self.view.frame.width * 3, y: 0)
        scrollView.setContentOffset(position, animated: true)
        
        // show keyboard of next TextField
        if passwordTextField.text!.isEmpty {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.text!.isEmpty == false {
            passwordTextField.resignFirstResponder()
        }
    }
    
    @IBAction func finishButtonClicked(_ sender: Any) {
        let avatar = getAvatar()
        let coverIMG = cover?.jpegData(compressionQuality: 0.7)
        _ = coverIMG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        let defaultTeamColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1).htmlRGBaColor
        
        FUser.registerUserWith(email: self.emailTextField.text!, password: self.passwordTextField.text!, firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!, avatar: avatar, height: "", weight: "", position: "", number: "", accountType: "parent", birthday: "", cover: team.teamLogo, phoneNumber: phoneTextField.text!, userTeamID: team.teamID, userTeamColorOne: defaultTeamColor, userTeamColorTwo: team.teamColorTwo, userTeamColorThree: team.teamColorThree) { (error)  in
            
                            if error != nil {
                                ProgressHUD.dismiss()
                                ProgressHUD.showError(error!.localizedDescription)
                                return
                            }
            
                            self.goToApp()
            }
    }
    
    func getAvatar() -> String {
        let helper = Helper()
        var avatar = ""
        
        helper.imageFromInitials(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!) { (avatarInitials) in
                
                let avatarIMG = avatarInitials.jpegData(compressionQuality: 0.7)
                avatar = avatarIMG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        }
        return avatar
    }
    
    func goToApp() {
        let helper = Helper()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        // go to TabBar
        helper.instantiateViewController(identifier: "ParentTabBar", animated: true, by: self, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        let helper = Helper()
        
        // logic for Email TextField
        if textField == emailTextField {
            
            // check email validation
            if helper.isValid(email: emailTextField.text!) {
                emailContinueButton.isHidden = false
            }
            
        // logic for First Name or Last Name TextFields
        } else if textField == firstNameTextField || textField == lastNameTextField {
            
            // check fullname validation
            if helper.isValid(name: firstNameTextField.text!) && helper.isValid(name: lastNameTextField.text!) {
                nameContinueButton.isHidden = false
            }
            
        // logic for Password TextField
        } else if textField == phoneTextField {
            
            // check email validation
            if helper.isValid(phone: phoneTextField.text!) {
                phoneContinueButton.isHidden = false
            }
            
        // logic for First Name or Last Name TextFields
        } else if textField == passwordTextField {
            
            // check password validation
            if passwordTextField.text!.count >= 6 {
                finishButton.isHidden = false
            }
        }
    }
    
}
