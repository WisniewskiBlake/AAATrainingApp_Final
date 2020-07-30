//
//  LoginVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 6/15/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseFirestore
import Firebase

class LoginVC: UIViewController {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var logo_height: NSLayoutConstraint!
        
    @IBOutlet weak var logoBackground: UIImageView!
    @IBOutlet weak var logoBackground_top: NSLayoutConstraint!
    @IBOutlet weak var logoBackground_height: NSLayoutConstraint!
    
    @IBOutlet weak var silhouetteLogo: UIImageView!
    @IBOutlet weak var silhoutte_top: NSLayoutConstraint!
    @IBOutlet weak var silhoutte_height: NSLayoutConstraint!
        
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var forgotPassBtn: UIButton!
    @IBOutlet weak var registerAccBtn: UIButton!
    @IBOutlet weak var textFieldsView: UIView!    
    @IBOutlet weak var leftLineView: UIView!
    @IBOutlet weak var rightLineView: UIView!
    
    @IBOutlet weak var registerButton_bottom: NSLayoutConstraint!
    @IBOutlet weak var registerCoachBtn: UIButton!
    @IBOutlet weak var registerCoachButton_bottom: NSLayoutConstraint!
    
    // cache obj
    var logoBackground_height_cache: CGFloat!
    var logo_height_cache: CGFloat!
    var registerButton_bottom_cache: CGFloat!
    var registerCoachButton_bottom_cache: CGFloat!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    //
//    var loginRef: DatabaseReference!
    
    //executed when scene is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // caching all values of constraints
        logoBackground_height_cache = logoBackground_height.constant
        logo_height_cache = logo_height.constant
        //registerButton_bottom_cache = registerButton_bottom.constant
        registerCoachButton_bottom_cache = registerCoachButton_bottom.constant
    }
    
    // executed EVERYTIME when view did appear on the screen
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // declaring notification observation in order to catch UIKeyboardWillShow / UIKeyboardWillHide Notification
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)        
    }
    
    
    // executed EVERYTIME when view did disappear from the screen
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // switch off notification center, so it wouldn't in action / running
        NotificationCenter.default.removeObserver(self)
     }
    
    @IBAction func loginButton_clicked(_ sender: Any) {
          // accessing Helper Class that stores multi-used functions
                let helper = Helper()
                
                // 1st Varification: if etnered text in EmailTextField doesn't match our expression/rule, show alert
                if helper.isValid(email: emailTextField.text!) == false {
                    helper.showAlert(title: "Invalid Email", message: "Please enter registered Email address", in: self)
                    return
                    
                // 2nd Varification: if password is less than 6 chars, then return do not executed further
                } else if passwordTextField.text!.count < 6 {
                    helper.showAlert(title: "Invalid Password", message: "Password must contain at least 6 characters", in: self)
                    return
                }
                
            loginUser()
      }
    
//    @IBAction func registerButtonClicked(_ sender: Any) {
//        let cRegisterVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserTypeSelection") as! UserTypeSelectionVC
//        let navController = UINavigationController(rootViewController: cRegisterVC)
//        
//        self.navigationController?.pushViewController(navController, animated: true)
//    }
    
            
            
            // sending request to the server for proceeding Log In
            func loginUser() {
                
                
                FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
                    
                    if error != nil {
                        ProgressHUD.showError(error!.localizedDescription)
                        return
                    }
                    
                    print(FUser.currentId())
                    self.goToApp()
                    
                    
                }
                
                print(FUser.currentUser()?.accountType)
               
                
                
                            
                        
                
            }
    
    func goToApp() {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        print(FUser.currentId())
        print(FUser.currentUser()?.accountType)
        print(FUser.currentUser()?.height)
        
        
        if FUser.currentUser()?.accountType == "coach" {
            ProgressHUD.show("Login...")
            self.goToCoach()
            

            

        } else if FUser.currentUser()?.accountType == "player" {
            ProgressHUD.show("Login...")
            self.goToPlayer()
            
        }
    }
        
        func goToCoach() {
            
            let helper = Helper()
            
            
            // go to TabBar
            helper.instantiateViewController(identifier: "CoachTabBar", animated: true, by: self, completion: nil)
            
            
        }
    
    func goToPlayer() {
        
        let helper = Helper()
        
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        // go to TabBar
        helper.instantiateViewController(identifier: "TabBar", animated: true, by: self, completion: nil)
        
    }
    
    // executed always when the Screen's White Space (anywhere excluding objects) tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // end editing - hide keyboards
        self.view.endEditing(false)
    }
    
    
    //THERE IS A BUG IN THIS METHOD WHEN CLICKING BETWEEN EMAIL AND PASSWORD, IT CAN PROBABLY BE FIXED BY THE CODE IN Q&A ON VIDEO 20 or 18
    @objc func keyboardWillShow(notification: Notification) {
        
        logoBackground_height.constant = self.view.frame.width/5
        logo_height.constant = self.view.frame.width/5
        silhoutte_top.constant = -15
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            //registerButton_bottom.constant = keyboardSize.height + 20
            registerCoachButton_bottom.constant = keyboardSize.height + 20
            //registerButton_bottom.constant = self.view.frame.width / 1.75423
        }
        
        // animation function. Whatever in the closures below will be animated
        UIView.animate(withDuration: 0.5) {
            self.silhouetteLogo.alpha = 0
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    // executed once the keyboard is about to be hidden
    @objc func keyboardWillHide(notification: Notification) {
      
        logoBackground_height.constant = logoBackground_height_cache
        logo_height.constant = logo_height_cache
        silhoutte_top.constant = 177
        //registerButton_bottom.constant = registerButton_bottom_cache
        registerCoachButton_bottom.constant = registerCoachButton_bottom_cache
        
        // animation function. Whatever in the closures below will be animated
        UIView.animate(withDuration: 0.5) {
            self.silhouetteLogo.alpha = 1
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    // executed after aligning the objects
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configure_textFieldsView()
        configure_loginBtn()
        configure_orLabel()
//        configure_registerButton(btn: registerAccBtn)
        configure_registerCoachButton(btn: registerCoachBtn)
    }
    
    // this func stores code which configures appearance of the textFields' View
    func configure_textFieldsView() {
        // declaring constants to store information which later on will be assigned to certain 'object'
        let width = CGFloat(2)
        let color = UIColor.lightGray.cgColor
        
        // creating layer to be a border of the view added test test
        let border = CALayer()
        border.borderWidth = width
        border.borderColor = color
        border.frame = CGRect(x: 0, y: 0, width: textFieldsView.frame.width, height: textFieldsView.frame.height)
        
        // creating layer to be a line in the center of the view
        let line = CALayer()
        line.borderWidth = width
        line.borderColor = color
        line.frame = CGRect(x: 0, y: textFieldsView.frame.height / 2 - width, width: textFieldsView.frame.width, height: width)
        
        // assigning created layers to the view
        textFieldsView.layer.addSublayer(border)
        textFieldsView.layer.addSublayer(line)
        // rounded corners
        textFieldsView.layer.cornerRadius = 5
        textFieldsView.layer.masksToBounds = true
    }
    
    func configure_loginBtn() {
        loginBtn.layer.cornerRadius = 5
        loginBtn.layer.masksToBounds = true
        //loginButton.isEnabled = false
    }
    
    func configure_orLabel() {
     
       // shortcuts
       let width = CGFloat(2)
        let color = UIColor.lightGray.cgColor
       // create Left Line object (layer), by assigning width and color values (constants)
       let leftLine = CALayer()
       leftLine.borderWidth = width
       leftLine.borderColor = color
       leftLine.frame = CGRect(x: 0, y: leftLineView.frame.height / 2 - width, width: leftLineView.frame.width, height: width)
       
       // create Right Line object (layer), by assingning width and color values declared above (for shorter way)
       let rightLine = CALayer()
       rightLine.borderWidth = width
       rightLine.borderColor = color
       rightLine.frame = CGRect(x: 0, y: rightLineView.frame.height / 2 - width, width: rightLineView.frame.width, height: width)
       
       // assign lines (layer objects) to the UI obj (views)
       leftLineView.layer.addSublayer(leftLine)
       rightLineView.layer.addSublayer(rightLine)
    }
    
    func configure_registerButton(btn: UIButton) {
        // creating constant named 'border' of type layer which acts as a border frame
        let border = CALayer()
        border.borderColor = #colorLiteral(red: 0.01220451668, green: 0.2841129601, blue: 0.7098029256, alpha: 1)
        border.borderWidth = 2
        border.frame = CGRect(x: 0, y: 0, width: btn.frame.width, height: btn.frame.height)
        
        // assign border to the obj (button)
        btn.layer.addSublayer(border)
        
        
        // rounded corner
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        
    }
    
    func configure_registerCoachButton(btn: UIButton) {
        // creating constant named 'border' of type layer which acts as a border frame
        let border = CALayer()
        border.borderColor = #colorLiteral(red: 0.01220451668, green: 0.2841129601, blue: 0.7098029256, alpha: 1)
        border.borderWidth = 2
        border.frame = CGRect(x: 0, y: 0, width: btn.frame.width, height: btn.frame.height)
        
        // assign border to the obj (button)
        btn.layer.addSublayer(border)
        
        
        // rounded corner
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        
    }

    
    

    

}
