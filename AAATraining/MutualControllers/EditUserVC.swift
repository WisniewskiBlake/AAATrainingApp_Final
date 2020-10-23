//
//  EditUserVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 10/23/20.
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
class EditUserVC: UITableViewController, ImagePickerDelegate {
    
    
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet var avatarTapGestureRecognizer: UITapGestureRecognizer!
    
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        
        tableView.tableFooterView = UIView()

        setupUI()
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }

    //MARK: IBAction
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if firstNameTextField.text != "" && lastNameTextField.text != "" && emailTextField.text != "" {
            
            ProgressHUD.show("Saving...")
            
            //block save button
            saveButtonOutlet.isEnabled = false
            
            let fullName = firstNameTextField.text! + " " + lastNameTextField.text!
            
            var withValues = [kFIRSTNAME : firstNameTextField.text!, kLASTNAME : lastNameTextField.text!]
            
            if avatarImage != nil {
                
                let avatarData = avatarImage!.jpegData(compressionQuality: 0.4)!
                let avatarString = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                withValues[kAVATAR] = avatarString
            }
            
            //update current user
            
            updateCurrentUserInFirestore(withValues: withValues) { (error) in
                
                if error != nil {
                    DispatchQueue.main.async {
                        ProgressHUD.showError(error!.localizedDescription)
                        print("couldn update user \(error!.localizedDescription)")
                    }
                    self.saveButtonOutlet.isEnabled = true
                    return
                }
                
                ProgressHUD.showSuccess("Saved")
                
                self.saveButtonOutlet.isEnabled = true
                self.navigationController?.popViewController(animated: true)
            }
            
        } else {
            ProgressHUD.showError("All fields are required!")
        }
        
    }
    
    @IBAction func avatarTap(_ sender: Any) {
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageLimit = 1
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    //MARK: SetupUI
    
    func setupUI() {
        let helper = Helper()
        let currentUser = FUser.currentUser()!
        
        avatarImageView.isUserInteractionEnabled = true
        
        firstNameTextField.text = currentUser.firstname
        lastNameTextField.text = currentUser.lastname
        emailTextField.text = currentUser.email
        
        if currentUser.ava != "" {
            
            helper.imageFromData(pictureData: currentUser.ava) { (avatarImage) in
                
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
    }

    
    //MARK: ImagePickerDelegate
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        if images.count > 0 {
            self.avatarImage = images.first!
            self.avatarImageView.image = self.avatarImage!.circleMasked
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }


    
}
