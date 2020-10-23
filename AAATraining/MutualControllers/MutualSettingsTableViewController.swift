//
//  MutualSettingsTableViewController.swift
//  AAATraining
//
//  Created by Margaret Dwan on 10/22/20.
//  Copyright © 2020 Blake Wisniewski. All rights reserved.
//

import UIKit
import Foundation
import ProgressHUD

class MutualSettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var pushNotiStatusSwitch: UISwitch!
    @IBOutlet weak var inviteOthersBtn: UIButton!
    
    @IBOutlet weak var versionLabel: UILabel!
    let userDefaults = UserDefaults.standard
    
    var avatarSwitchStatus = false
    var firstLoad: Bool?
    let helper = Helper()
    
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
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: getDocumentsURL().path)
            
            for file in files {
                try FileManager.default.removeItem(atPath: "\(getDocumentsURL().path)/\(file)")
            }

            ProgressHUD.showSuccess("Cache cleaned.")
        } catch {
            ProgressHUD.showError("Couldnt clean Media files.")
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
        
        //delet locally
        userDefaults.removeObject(forKey: kPUSHID)
        userDefaults.removeObject(forKey: kCURRENTUSER)
        userDefaults.synchronize()
        
        //delete from firebase
        reference(.User).document(FUser.currentId()).delete()
        
        FUser.deleteUser { (error) in
            
            if error != nil {
                
                DispatchQueue.main.async {
                    ProgressHUD.showError("Couldnt delete use")
                }
                return
            }
            
            self.showLoginView()
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
