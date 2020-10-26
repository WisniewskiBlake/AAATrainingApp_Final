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
import FirebaseAuth

class EditUserVC: UITableViewController, ImagePickerDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var allPosts: [Post] = []
    
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet var avatarTapGestureRecognizer: UITapGestureRecognizer!
    let coverTapGestureRecognizer = UITapGestureRecognizer()
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        
        tableView.tableFooterView = UIView()

        setupUI()
        coverTapGestureRecognizer.addTarget(self, action: #selector(self.coverViewClicked))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(coverTapGestureRecognizer)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPosts()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    @objc func coverViewClicked() {
        showActionSheet()
    }

    //MARK: IBAction
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        let helper = Helper()
        if firstNameTextField.text != "" && lastNameTextField.text != "" && emailTextField.text != "" {
            var credential: AuthCredential
            ProgressHUD.show("Saving...")
            
            //block save button
            saveButtonOutlet.isEnabled = false
            
            
            
            if emailTextField.text != FUser.currentUser()?.email {
                let user = Auth.auth().currentUser
                var credential: AuthCredential
                var withValues = [kFIRSTNAME : firstNameTextField.text!, kLASTNAME : lastNameTextField.text!, kEMAIL: emailTextField.text!]

                
                if let user = Auth.auth().currentUser {

                    // User re-authenticated.
                    user.updateEmail(to: emailTextField.text!) { (error) in
                        if error != nil {
                            if let errCode = AuthErrorCode(rawValue: (error?._code)!) {
                                                        switch errCode {
                                                        case .accountExistsWithDifferentCredential: helper.showAlert(title: "Error", message: "Account exists with different credentials.", in: self)
                                                        case .invalidEmail: helper.showAlert(title: "Error", message: "Invalid Email.", in: self)
                                                        case .invalidCredential: helper.showAlert(title: "Error", message: "Invalid Credentials.", in: self)
                                                        case .credentialAlreadyInUse: helper.showAlert(title: "Error", message: "Invalid Email.", in: self)
                                                            // TODO: A case for if the password field is blank
                                                            default: helper.showAlert(title: "Error", message: "You are required to log out and log back in (re-authenticate) before changing account email.", in: self)
                                                                ProgressHUD.dismiss()
                                                            }
                                                        } else {
                                                            print("Successfully Authenticated with Firebase")
                                                    }
                        } else {
                            if self.avatarImage != nil {
                                
                                let avatarData = self.avatarImage!.jpegData(compressionQuality: 0.4)!
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
                        }
                    }

                }
            } else {
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

    func showActionSheet() {
        
        // declaring action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // declaring library button
        let library = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            
            // checking availability of photo library
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.showPicker(with: .photoLibrary)
            }
            
        }
        // declaring cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        // adding buttons to the sheet
        sheet.addAction(library)
        sheet.addAction(cancel)
        
        // present action sheet to the user finally
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    func showPicker(with source: UIImagePickerController.SourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true, completion: nil)
        
    }
    
    @objc func loadPosts() {
        
            var query: Query!
            
            query = reference(.Post).whereField(kPOSTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID as Any).whereField(kPOSTOWNERID, isEqualTo: FUser.currentId()).order(by: kPOSTDATE, descending: true)
            
            query.getDocuments { (snapshot, error) in
                self.allPosts = []

                
                if error != nil {
                    print(error!.localizedDescription)
                    
                    return
                }
                
                guard let snapshot = snapshot else {
                    return
                }
                
                if !snapshot.isEmpty {
                    
                    for postDictionary in snapshot.documents {
                        let postDictionary = postDictionary.data() as NSDictionary
                        let post = Post(_dictionary: postDictionary)
                        
                        self.allPosts.append(post)
                        
                                        
                    }
                    
                }
                
            }

        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey(rawValue: convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage))] as? UIImage
        let picturePath = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        self.avatarImageView.image = picturePath
        
        // refresh global variable storing the user's profile pic
        let pictureData = image?.jpegData(compressionQuality: 0.4)!
        let avatar = pictureData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

        updateCurrentUserInFirestore(withValues: [kAVATAR : avatar!]) { (success) in
            
        }
        if !allPosts.isEmpty {
            for post in allPosts {

                post.updatePost(postID: post.postID, withValues: [kPOSTUSERAVA : avatar!])
            }

        }
        self.dismiss(animated: true)
    }
    
}
// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
