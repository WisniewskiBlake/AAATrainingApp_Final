//
//  CoachRegisterVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 6/25/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import ProgressHUD

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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
   
    @IBOutlet weak var coachPasswordContinueButton: UIButton!
    @IBOutlet weak var fullnameContinueButton: UIButton!
    @IBOutlet weak var emailContinueButton: UIButton!
    @IBOutlet weak var passwordContinueButton: UIButton!
    
    
    
    
    @IBOutlet weak var footerView: UIView!
    
    var email: String!
    var password: String!
    let height = "123456789"
    let weight = "123456789"
    let position = "coach"
    let number = "123456789"
    var id: Any!
    var birthday: Any!
    var cover = UIImage(named: "aaaCoverLogo.png")
    
    
    var accountType = "2"

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView_width.constant = self.view.frame.width * 4
        coachPassword_width.constant = self.view.frame.width
        nameView_width.constant = self.view.frame.width
        emailView_width.constant = self.view.frame.width
        passwordView_width.constant = self.view.frame.width
        
        cornerRadius(for: coachPasswordTextField)
        cornerRadius(for: firstNameTextField)
        cornerRadius(for: lastNameTextField)
        cornerRadius(for: emailTextField)
        cornerRadius(for: passwordTextField)
        cornerRadius(for: phoneTextField)
        
        cornerRadius(for: emailContinueButton)
        cornerRadius(for: fullnameContinueButton)
        cornerRadius(for: passwordContinueButton)
        cornerRadius(for: coachPasswordContinueButton)
        
        padding(for: emailTextField)
        padding(for: firstNameTextField)
        padding(for: lastNameTextField)
        padding(for: passwordTextField)
        padding(for: coachPasswordTextField)
        padding(for: phoneTextField)
        
        configure_footerView()
        
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
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
    
    @IBAction func coachPasswordContinue_clicked(_ sender: Any) {
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
    
    @IBAction func fullnameContinue_clicked(_ sender: Any) {
        let position = CGPoint(x: self.view.frame.width * 2, y: 0)
        scrollView.setContentOffset(position, animated: true)
        
        // show keyboard of next TextField
        if emailTextField.text!.isEmpty {
            emailTextField.becomeFirstResponder()
        } else if emailTextField.text!.isEmpty == false {
            emailTextField.resignFirstResponder()
        }
        
    }
    
    @IBAction func emailContinue_clicked(_ sender: Any) {
        let position = CGPoint(x: self.view.frame.width * 3, y: 0)
        scrollView.setContentOffset(position, animated: true)
        
        // show keyboard of next TextField
        if passwordTextField.text!.isEmpty {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.text!.isEmpty == false {
            passwordTextField.resignFirstResponder()
        }
    }
    
    @IBAction func passwordContinue_clicked(_ sender: Any) {
        
        let avatar = getAvatar()
        let coverIMG = cover?.jpegData(compressionQuality: 0.7)
        let coverData = coverIMG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        FUser.registerUserWith(email: self.emailTextField.text!, password: self.passwordTextField.text!, firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!, avatar: avatar, height: "", weight: "", position: "", number: "", accountType: "coach", birthday: "", cover: coverData, phoneNumber: phoneTextField.text!) { (error)  in
            
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
        helper.instantiateViewController(identifier: "CoachTabBar", animated: true, by: self, completion: nil)
    }
    
    
    
    
    
    
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        // declaring constant (shortcut) to the Helper Class
        let helper = Helper()
        
        // logic for Email TextField
        if textField == coachPasswordTextField {
            
            // check email validation
            if coachPasswordTextField.text!.count >= 6 {
                coachPasswordContinueButton.isHidden = false
            }
            
        // logic for First Name or Last Name TextFields
        } else if textField == firstNameTextField || textField == lastNameTextField {
            
            // check fullname validation
            if helper.isValid(name: firstNameTextField.text!) && helper.isValid(name: lastNameTextField.text!) {
                fullnameContinueButton.isHidden = false
            }
            
        // logic for Password TextField
        } else if textField == emailTextField || textField == phoneTextField {
            
            // check email validation
            if helper.isValid(email: emailTextField.text!) && helper.isValid(phone: phoneTextField.text!) {
                emailContinueButton.isHidden = false
            }
            
        // logic for First Name or Last Name TextFields
        } else if textField == passwordTextField {
            
            // check password validation
            if passwordTextField.text!.count >= 6 {
                passwordContinueButton.isHidden = false
            }
        } 
    }
    

    

}
