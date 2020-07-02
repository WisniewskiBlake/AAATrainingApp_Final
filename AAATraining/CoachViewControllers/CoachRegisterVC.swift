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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
   
    @IBOutlet weak var coachPasswordContinueButton: UIButton!
    @IBOutlet weak var fullnameContinueButton: UIButton!
    @IBOutlet weak var emailContinueButton: UIButton!
    @IBOutlet weak var passwordContinueButton: UIButton!
    
    
    
    
    @IBOutlet weak var footerView: UIView!
    
    
    
    var accountType = 2

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
        
        cornerRadius(for: emailContinueButton)
        cornerRadius(for: fullnameContinueButton)
        cornerRadius(for: passwordContinueButton)
        cornerRadius(for: coachPasswordContinueButton)
        
        padding(for: emailTextField)
        padding(for: firstNameTextField)
        padding(for: lastNameTextField)
        padding(for: passwordTextField)
        padding(for: coachPasswordTextField)
        
        configure_footerView()
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
        // STEP 1. Declaring URL of the request; declaring the body to the URL; declaring request with the safest method - POST, that no one can grab our info.
        
        
        let url = URL(string: "http://localhost/fb/register.php")!
        
        
        let body = "email=\(emailTextField.text!.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))&firstName=\(firstNameTextField.text!.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))&lastName=\(lastNameTextField.text!.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))&password=\(passwordTextField.text!)&birthday=\(datePicker.date)&height=\(heightTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines))&weight=\(weightTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines))&position=\(positionTextField.text!.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))&number=\(numberTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines))&ava=\("http://localhost/fb/ava/user.png")&cover=\("http://localhost/fb/cover/HomeCover.jpg")&accountType=\("1")"
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
        } else if textField == emailTextField {
            
            // check email validation
            if helper.isValid(email: emailTextField.text!) {
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
