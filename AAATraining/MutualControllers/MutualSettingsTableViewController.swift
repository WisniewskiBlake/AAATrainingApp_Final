//
//  MutualSettingsTableViewController.swift
//  AAATraining
//
//  Created by Margaret Dwan on 10/22/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import UIKit
import MediaPlayer
import ImagePicker
import Firebase
import FirebaseFirestore
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseAuth

class MutualSettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var pushNotiStatusSwitch: UISwitch!
    @IBOutlet weak var inviteOthersBtn: UIButton!
    @IBOutlet weak var backToTeamSelectBtn: UIButton!
    
    private var authListener: AuthStateDidChangeListenerHandle?
    @IBOutlet weak var versionLabel: UILabel!
    let userDefaults = UserDefaults.standard
    
    var avatarSwitchStatus = false
    var firstLoad: Bool?
    let helper = Helper()
    var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "", teamType: "", teamMemberCount: "", teamMemberAccountTypes: [""])
    override func viewDidAppear(_ animated: Bool) {
        if FUser.currentUser() != nil {
            setupUI()
            loadUserDefaults()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if var textAttributes = navigationController?.navigationBar.titleTextAttributes {
            textAttributes[NSAttributedString.Key.foregroundColor] = UIColor.black
            navigationController?.navigationBar.titleTextAttributes = textAttributes
        }


    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.tableFooterView = UIView()

        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let listener = authListener {
            Auth.auth().removeStateDidChangeListener(authListener!)
        }
    }
    
    @objc func loadUser() {
        
        let helper = Helper()
        let user = FUser.currentUser()
        
   
        guard let firstName = user?.firstname, let lastName = user?.lastname, let avaPath = user?.ava, let coverPath = user?.cover else {
               
               return
        }
           
           
            if avaPath != "" {
                helper.imageFromData(pictureData: avaPath) { (avatarImage) in
                    
                    if avatarImage != nil {
                        avatarImageView.image = avatarImage!
                    }
                }
            } else{
                avatarImageView.image = UIImage(named: "user.png")

            }
           // assigning vars which we accessed from global var, to fullnameLabel
           fullNameLabel.text = "\((firstName).capitalized) \((lastName).capitalized)"
           
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 4
        }
        return 2
    }

    //MARK: TableViewDelegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        }
        
        return 30
    }
    
    //MARK: IBActions
    
    @IBAction func leaveTeamButtonPressed(_ sender: Any) {
        let helper = Helper()
        var teamMemberAccountTypes: [String] = []
        var teamMemberIDs: [String] = []
        var teamMemberCount: String = ""
        var newTeamMemberCount: Int = 0
        
        

        
        let currentTeamID = FUser.currentUser()!.userCurrentTeamID
        let currentID = FUser.currentId()
        
        team.getTeam(teamID: currentTeamID) { (teamReturned) in
            if teamReturned.teamID != "" {
                
                teamMemberAccountTypes = teamReturned.teamMemberAccountTypes
                teamMemberIDs = teamReturned.teamMemberIDs
                teamMemberCount = teamReturned.teamMemberCount
                
                let index = teamMemberIDs.firstIndex(of: currentID)
                teamMemberAccountTypes.remove(at: index!)
                teamMemberIDs.remove(at: index!)
                newTeamMemberCount = Int(teamMemberCount)! - 1
                
                
                Team.updateTeam(teamID: teamReturned.teamID, withValues: [kTEAMMEMBERIDS: teamMemberIDs, kTEAMMEMBERACCOUNTTYPES: teamMemberAccountTypes, kTEAMMEMBERCOUNT: String(newTeamMemberCount)])
                
                fetchCurrentUserFromFirestore(userId: FUser.currentId(), completion: { (user) in

                   if user != nil && user!.firstname != "" {
                    
                    var userIsNewObserverArray = user?.userIsNewObserverArray
                    var userTeamAccountTypes = user?.userTeamAccountTypes
                    var userTeamIDs = user?.userTeamIDs
                    var userTeamNames = user?.userTeamNames
                    
                    
                    let indexUser = userTeamIDs?.firstIndex(of: teamReturned.teamID)
                    userTeamIDs?.remove(at: indexUser!)
                    userTeamAccountTypes?.remove(at: indexUser!)
                    userIsNewObserverArray?.remove(at: indexUser!)
                    userTeamNames?.remove(at: indexUser!)
                    
                    updateUserInFirestore(objectID: FUser.currentId(), withValues: [kUSERTEAMIDS: userTeamIDs, kUSERISNEWOBSERVERARRAY: userIsNewObserverArray, kUSERTEAMACCOUNTTYPES: userTeamAccountTypes, kUSERTEAMNAMES: userTeamNames, kUSERCURRENTTEAMID: ""]) { (success) in
                        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamSelectionVC") as? TeamSelectionVC
                        {
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                    
                   } else {

                   }

                })
                
//                updateUser(userID: currentID , withValues: [kUSERTEAMIDS: userTeamIDs, kUSERISNEWOBSERVERARRAY: userIsNewObserverArray, kUSERTEAMACCOUNTTYPES: userTeamAccountTypes])
                
                

                
                
            } else {
                helper.showAlert(title: "Error", message: "Can't delete right now.", in: self)
            }
        }
    }
    @IBAction func backToTeamSelectPressed(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamSelectionVC") as? TeamSelectionVC
        {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func colorThemeButtonPressed(_ sender: Any) {
        let navigationColorPicker = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColorPickerNav") as! UINavigationController
                     //let colorPickerVC = navigationColorPicker.viewControllers.first as! ColorPickerVC
        navigationColorPicker.modalPresentationStyle = .fullScreen
        
                    self.present(navigationColorPicker, animated: true, completion: nil)
    }

    @IBAction func termsConditionsPressed(_ sender: Any) {
    }
    
    
    @IBAction func showAvatartSwithValueChanged(_ sender: UISwitch) {

        avatarSwitchStatus = sender.isOn
        
        saveUserDefaults()
    }
    
    @IBAction func tellAFriendButtonPressed(_ sender: Any) {
        
        let text = "Hey! Join my team on LockrRoom with code: " + FUser.currentUser()!.userCurrentTeamID
        
        let objectsToShare:[Any] = [text]
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.setValue("Lets Chat on iCHat", forKey: "subject")

        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        
        FUser.logOutCurrentUser { (success) in
            
            if success {
                self.showLoginView()
            }
            
        }
        
    }
    
    
    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        
        let optionMenu = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete the account?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (alert) in
            
            self.deleteUser()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        //for iPad not to crash
        if ( UI_USER_INTERFACE_IDIOM() == .pad )
        {
            if let currentPopoverpresentioncontroller = optionMenu.popoverPresentationController{
                
                currentPopoverpresentioncontroller.sourceView = deleteButtonOutlet
                currentPopoverpresentioncontroller.sourceRect = deleteButtonOutlet.bounds
                
                currentPopoverpresentioncontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        }else{
            self.present(optionMenu, animated: true, completion: nil)
        }
        
    }
    
    
    func showLoginView() {
        
        if let listener = authListener {
            Auth.auth().removeStateDidChangeListener(authListener as! NSObjectProtocol)
        }
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC

        //                  {
        mainView?.modalPresentationStyle = .fullScreen

        self.present(mainView!, animated: true, completion: nil)
    }
    

    //MARK: SetupUI
    
    func setupUI() {
        let helper = Helper()
        let currentUser = FUser.currentUser()!
        
        fullNameLabel.text = currentUser.fullname
        
        if currentUser.ava != "" {
            
            helper.imageFromData(pictureData: currentUser.ava) { (avatarImage) in
                
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = version
        }
    }
    
    //MARK: Delete user
    
    func deleteUser() {
        let helper = Helper()
        var teamMemberAccountTypes: [String] = []
        var teamMemberIDs: [String] = []
        var teamMemberCount: String = ""
        var newTeamMemberCount: Int = 0
        
        var currentTeamID = FUser.currentUser()!.userCurrentTeamID
        var currentID = FUser.currentId()
        
        authListener = Auth.auth().addStateDidChangeListener { (auth, user) in

                    if let user = user {
                        self.team.getTeam(teamID: currentTeamID) { (teamReturned) in
                            if teamReturned.teamID != "" {
                                
                                teamMemberAccountTypes = teamReturned.teamMemberAccountTypes
                                teamMemberIDs = teamReturned.teamMemberIDs
                                teamMemberCount = teamReturned.teamMemberCount
                                
                                let index = teamMemberIDs.firstIndex(of: currentID)
                                teamMemberAccountTypes.remove(at: index!)
                                teamMemberIDs.remove(at: index!)
                                newTeamMemberCount = Int(teamMemberCount)! - 1
                                
                                //delet locally
                                self.userDefaults.removeObject(forKey: kPUSHID)
                                self.userDefaults.removeObject(forKey: kCURRENTUSER)
                                self.userDefaults.synchronize()
                                
                                //delete from firebase
                                reference(.User).document(currentID).delete()
                         
                                Team.updateTeam(teamID: teamReturned.teamID, withValues: [kTEAMMEMBERIDS: teamMemberIDs, kTEAMMEMBERACCOUNTTYPES: teamMemberAccountTypes, kTEAMMEMBERCOUNT: String(newTeamMemberCount)])
                                
                                user.delete(completion: { (error) in
                                    if error != nil {
                                        
                                    } else {
                                        
                                    }
                                })
                                
                                
                                
                                self.showLoginView()
                            } else {
                                helper.showAlert(title: "Error", message: "Can't delete right now.", in: self)
                            }
                        }

                        
                    } else {
                        helper.showAlert(title: "Error", message: "You are required to log out and log back in (re-authenticate) before deleting your account.", in: self)
                    }
            }

        
        
//        FUser.deleteUser { (error) in
//
//            if error != nil {
//
//                DispatchQueue.main.async {
//                    print("Couldnt delete user")
//                    ProgressHUD.showError("Couldnt delete user")
//                }
//                return
//            }
//
//            self.showLoginView()
//        }
        
    }
    deinit {
            if let listener = authListener {
                Auth.auth().removeStateDidChangeListener(authListener!)
            }
        }

    //MARK: UserDefaults
    
    func saveUserDefaults() {
        
        userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
        userDefaults.synchronize()
    }
    
    func loadUserDefaults() {
        
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !firstLoad! {
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
            userDefaults.synchronize()
        }
        
        avatarSwitchStatus = userDefaults.bool(forKey: kSHOWAVATAR)
        pushNotiStatusSwitch.isOn = avatarSwitchStatus
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

}
