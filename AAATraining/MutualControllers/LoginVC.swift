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

class LoginVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var logo_height: NSLayoutConstraint!
        
    @IBOutlet weak var logoBackground: UIImageView!
    @IBOutlet weak var logoBackground_top: NSLayoutConstraint!
    @IBOutlet weak var logoBackground_height: NSLayoutConstraint!
    
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    

        
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
    
    let helper = Helper()
    
    var teamID: String = ""
    var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "", teamType: "")
    
    //
//    var loginRef: DatabaseReference!
    
    //executed when scene is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        // caching all values of constraints
        logoBackground_height_cache = logoBackground_height.constant
        logo_height_cache = logo_height.constant
        //registerButton_bottom_cache = registerButton_bottom.constant
        registerCoachButton_bottom_cache = registerCoachButton_bottom.constant
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    
    // executed EVERYTIME when view did appear on the screen
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)        
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
    
    @IBAction func registerButtonClicked(_ sender: Any) {

        
        let navigationSelection = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userSelectionNav") as! UINavigationController
         let selectionVC = navigationSelection.viewControllers.first as! UserTypeSelectionVC
        selectionVC.team = self.team

        self.present(navigationSelection, animated: true, completion: nil)
    }

    
    func configureUI() {
        
        padding(for: emailTextField)
        padding(for: passwordTextField)
        cornerRadius(for: emailTextField)
        cornerRadius(for: passwordTextField)
        
        //this will load the team and set the current user defaults to team color and logo
        self.helper.imageFromData(pictureData: team.teamLogo) { (teamImage) in
            
            
            if teamImage != nil {
                logo.image = teamImage
                loginBtn.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
                registerCoachBtn.setTitleColor(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1), for: .normal)
                forgotPassBtn.setTitleColor(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1), for: .normal)
            }
        }

    }
            
        // sending request to the server for proceeding Log In
        func loginUser() {
            
            let helper = Helper()
            
            reference(.User).whereField(kUSERTEAMID, isEqualTo: self.team.teamID).getDocuments { (snapshot, error) in
                
                guard let snapshot = snapshot else { return }
                
                if !snapshot.isEmpty {
                    FUser.loginUserWith(email: self.emailTextField.text!, password: self.passwordTextField.text!) { (error) in
                        
                        if error != nil {
                            ProgressHUD.showError(error!.localizedDescription)
                            return
                        }
                        
                        print(FUser.currentId())
                        self.goToApp()
                    }
                    
                } else {
                    helper.showAlert(title: "Invalid Credentials", message: "Email does not belong to this team.", in: self)
                    return
                }

                
            }
            
            
            
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
            
        } else if FUser.currentUser()?.accountType == "parent" {
            ProgressHUD.show("Login...")
            self.goToParent()
            
        }
    }
        
    func goToCoach() {
        
        let helper = Helper()
        // go to TabBar
        helper.instantiateViewController(identifier: "CoachTabBar", animated: true, by: self, completion: nil)
    }
    
    func goToPlayer() {
        
        let helper = Helper()
        // go to TabBar
        helper.instantiateViewController(identifier: "TabBar", animated: true, by: self, completion: nil)
    }
    
    func goToParent() {
        
        let helper = Helper()
        // go to TabBar
        helper.instantiateViewController(identifier: "ParentTabBar", animated: true, by: self, completion: nil)
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
        leftLabel.isHidden = true
        rightLabel.isHidden = true
        logoBackground.isHidden = false
        logo.isHidden = true
//        silhoutte_top.constant = -15
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            //registerButton_bottom.constant = keyboardSize.height + 20
            registerCoachButton_bottom.constant = keyboardSize.height + 20
            //registerButton_bottom.constant = self.view.frame.width / 1.75423
        }
        
        // animation function. Whatever in the closures below will be animated
        UIView.animate(withDuration: 0.5) {
//            self.silhouetteLogo.alpha = 0
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    // executed once the keyboard is about to be hidden
    @objc func keyboardWillHide(notification: Notification) {
      
        logoBackground_height.constant = logoBackground_height_cache
        logo_height.constant = logo_height_cache
//        silhoutte_top.constant = 177
        registerCoachButton_bottom.constant = registerCoachButton_bottom_cache
        logoBackground.isHidden = true
        logo.isHidden = false
        leftLabel.isHidden = false
        rightLabel.isHidden = false
        // animation function. Whatever in the closures below will be animated
        UIView.animate(withDuration: 0.5) {
//            self.silhouetteLogo.alpha = 1
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
    

    
    func configure_registerCoachButton(btn: UIButton) {
        // creating constant named 'border' of type layer which acts as a border frame
        let border = CALayer()
//        border.borderColor = UIColor(hexString: team.teamColorOne)?.cgColor
        border.borderColor = #colorLiteral(red: 0.1626327634, green: 0.1581403017, blue: 0.1580258608, alpha: 1)
        border.borderWidth = 2
        border.frame = CGRect(x: 0, y: 0, width: btn.frame.width, height: btn.frame.height)
        
        // assign border to the obj (button)
        btn.layer.addSublayer(border)
        
        
        // rounded corner
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        
    }

    
    

    

}
