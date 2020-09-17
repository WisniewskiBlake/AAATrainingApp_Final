//
//  RegisterVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 6/18/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import ProgressHUD
import GoogleMobileAds

class RegisterVC: UIViewController, UITextFieldDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var contentView_width: NSLayoutConstraint!
    @IBOutlet weak var emailView_width: NSLayoutConstraint!
    @IBOutlet weak var nameView_width: NSLayoutConstraint!
    @IBOutlet weak var passwordView_width: NSLayoutConstraint!
    
    @IBOutlet weak var genderView_width: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //@IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var positionTextField: UITextField!
    @IBOutlet weak var numberTextField: UITextField!
    
    @IBOutlet weak var emailContinueButton: UIButton!
    @IBOutlet weak var fullnameContinueButton: UIButton!
    @IBOutlet weak var passwordContinueButton: UIButton!
        
    @IBOutlet weak var statsContinueButton: UIButton!
    
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    // code obj
    var datePicker: UIDatePicker!
    var cover = UIImage(named: "aaaCoverLogo.png")
    
    var accountType = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configure_footerView()
        configureButtons()
        
        self.emailTextField.delegate = self
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.heightTextField.delegate = self
        self.weightTextField.delegate = self
        self.positionTextField.delegate = self
        self.numberTextField.delegate = self
        
        bannerView.adUnitID = "ca-app-pub-8479238648739219/2436200347"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
                               
        // implementation of Swipe Gesture
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handle(_:)))
        swipe.direction = .right
        self.view.addGestureRecognizer(swipe)
        
    }
    
    func configureUI() {
        contentView_width.constant = self.view.frame.width * 4
        emailView_width.constant = self.view.frame.width
        nameView_width.constant = self.view.frame.width
        passwordView_width.constant = self.view.frame.width
        genderView_width.constant = self.view.frame.width
        
        // make corners of the objects rounded
        cornerRadius(for: emailTextField)
        cornerRadius(for: firstNameTextField)
        cornerRadius(for: lastNameTextField)
        cornerRadius(for: passwordTextField)
        
        cornerRadius(for: heightTextField)
        cornerRadius(for: weightTextField)
        cornerRadius(for: positionTextField)
        cornerRadius(for: numberTextField)
        
        cornerRadius(for: emailContinueButton)
        cornerRadius(for: fullnameContinueButton)
        cornerRadius(for: passwordContinueButton)
        cornerRadius(for: statsContinueButton)        

        padding(for: emailTextField)
        padding(for: firstNameTextField)
        padding(for: lastNameTextField)
        padding(for: passwordTextField)
        
        padding(for: heightTextField)
        padding(for: weightTextField)
        padding(for: positionTextField)
        padding(for: numberTextField)
    }
    
    func configureButtons() {
        
        emailContinueButton.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        fullnameContinueButton.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        passwordContinueButton.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        statsContinueButton.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
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
    
    
    @IBAction func emailContinueButton_clicked(_ sender: Any) {
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
    
    @IBAction func fullnameContinueButton_clicked(_ sender: Any) {
        // move scrollView horizontally (by X to the 2x WIDTH as a pointer)
        let position = CGPoint(x: self.view.frame.width * 2, y: 0)
        scrollView.setContentOffset(position, animated: true)
        
        // show keyboard of next TextField
        if passwordTextField.text!.isEmpty {
            passwordTextField.becomeFirstResponder()
        } else if passwordTextField.text!.isEmpty == false {
            passwordTextField.resignFirstResponder()
        }
    }
    
    @IBAction func passwordContinueButton_clicked(_ sender: Any) {
        // move scrollView horizontally (by X to the 3x WIDTH as a pointer)
        let position = CGPoint(x: self.view.frame.width * 3, y: 0)
        scrollView.setContentOffset(position, animated: true)
        
        
    }
   
    
    @IBAction func statsContinueButton_clicked(_ sender: Any) {
        
        let avatar = getAvatar()
        let defaultTeamColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1).htmlRGBaColor
                  
        FUser.registerUserWith(email: self.emailTextField.text!, password: self.passwordTextField.text!, firstName: self.firstNameTextField.text!, lastName: self.lastNameTextField.text!, avatar: avatar, height: self.heightTextField.text!, weight: self.weightTextField.text!, position: self.positionTextField.text!, number: self.numberTextField.text!, accountType: "player", birthday: "", cover: "", phoneNumber: "", userCurrentTeamID: "", userTeamColorOne: defaultTeamColor, userTeamColorTwo: "", userTeamColorThree: "", userTeamIDs: [""]) { (error)  in
            
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
        helper.instantiateViewController(identifier: "TabBar", animated: true, by: self, completion: nil)
    }
    
    
    @IBAction func cancelButton_clicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        
        // declaring constant (shortcut) to the Helper Class
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
                fullnameContinueButton.isHidden = false
            }
            
        // logic for Password TextField
        } else if textField == passwordTextField {
            
            // check password validation
            if passwordTextField.text!.count >= 6 {
                passwordContinueButton.isHidden = false
            }
        } else if textField == positionTextField || textField == weightTextField || textField == numberTextField || textField == heightTextField {
            if helper.isValid(position: positionTextField.text!) && helper.isValid(weight: weightTextField.text!) && helper.isValid(number: numberTextField.text!) && helper.isValid(height: heightTextField.text!) {
                statsContinueButton.isHidden = false
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

    
    // called once Swiped to the direction Right ->
    @objc func handle(_ gesture: UISwipeGestureRecognizer) {
        print(gesture)
        // getting current position of the ScrollView (horizontal position)
        let current_x = scrollView.contentOffset.x
        
        // getting the width of the screen (deduct this size)
        let screen_width = self.view.frame.width
        
        // from current position of ScrollView, we comeback by width of the screen
        let new_x = CGPoint(x: current_x - screen_width, y: 0)
        
        // ... until unless it's more than 0 (0 - 1st page)
        if current_x > 0 {
            scrollView.setContentOffset(new_x, animated: true)
        }
        
    }
    
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
           
    
    
}
