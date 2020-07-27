//
//  CoachProfileViewController.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/8/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import MediaPlayer
import ImagePicker
import Firebase
import FirebaseFirestore

class CoachProfileViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if images.count > 0 {
            self.profileIcon = images.first!
            self.avaImageView.image = self.profileIcon!
            //self.editAvatarButtonOutlet.isHidden = false
            
            let avatarData = profileIcon?.jpegData(compressionQuality: 0.4)!
            let avatar = avatarData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            updateCurrentUserInFirestore(withValues: [kAVATAR : avatar!]) { (success) in
                
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    var profileIcon: UIImage?
    var coverIcon: UIImage?
    
    // code obj (to build logic of distinguishing tapped / shown Cover / Ava)
    var isCover = false
    var isAva = false
    
    var posts: [NSDictionary] = []
    var filteredChats: [NSDictionary] = []
       
    var recentListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // dynamic cell height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
//        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadUser), name: NSNotification.Name(rawValue: "updateStats"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadUser), name: NSNotification.Name(rawValue: "updateUser"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadNewPosts), name: NSNotification.Name(rawValue: "uploadPost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "uploadImage"), object: nil)
        
        

        configure_avaImageView()
        loadUser()
//        loadPosts(offset: skip, limit: limit)
        

    }
    
//    @objc func refresh(sender:AnyObject)
//    {
//        refreshing = true
//        loadPosts(offset: skip, limit: limit)
//        self.tableView.reloadData()
//        self.refreshControl?.endRefreshing()
//
//    }
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide navigation bar on Home Pagex
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    // exec-d when new post is published
    @objc func loadNewPosts() {
        
    }
    
    // MARK: - Load User
    // loads all user related information to be shown in the header
    @objc func loadUser() {
        let helper = Helper()
        let user = FUser.currentUser()
   
        guard let firstName = user?.firstname, let lastName = user?.lastname, let avaPath = user?.ava, let coverPath = user?.cover else {
               
               return
           }
           
           if coverPath != "" {
               helper.imageFromData(pictureData: coverPath) { (coverImage) in
                   
                   if coverImage != nil {
                       coverImageView.image = coverImage!
                       isCover = true
                   }
               }
           } else {
               coverImageView.image = UIImage(named: "HomeCover.jpg")
               isCover = false
           }
            if avaPath != "" {
                
                helper.imageFromData(pictureData: avaPath) { (avatarImage) in
                    
                    if avatarImage != nil {
                        avaImageView.image = avatarImage!
                        isAva = true
                    }
                }
            } else{
                avaImageView.image = UIImage(named: "user.png")
                isAva = false
            }
           // assigning vars which we accessed from global var, to fullnameLabel
           fullnameLabel.text = "\((firstName).capitalized) \((lastName).capitalized)"
           
    }
    
    // MARK: - Load Posts
    // loading posts from the server via@objc  PHP protocol
    @objc func loadPosts(offset: Int, limit: Int) {
       
        
    }
    
    // MARK: - Load More
    // loading more posts from the server via PHP protocol
    func loadMore(offset: Int, limit: Int) {
        
        
    }
    
    // MARK: - Upload Image
    // sends request to the server to upload the Image (ava/cover)
    func uploadImage(from imageView: UIImageView, action: String) {
                
    }
    
    // configuring the appearance of AvaImageView
    func configure_avaImageView() {
        
        // creating layer that will be applied to avaImageView (layer - broders of ava)
        let border = CALayer()
        border.borderColor = UIColor.white.cgColor
        border.borderWidth = 5
        border.frame = CGRect(x: 0, y: 0, width: avaImageView.frame.width, height: avaImageView.frame.height)
        avaImageView.layer.addSublayer(border)
        
        // rounded corners
        avaImageView.layer.cornerRadius = 10
        avaImageView.layer.masksToBounds = true
        avaImageView.clipsToBounds = true
    }
    
    func saveProfilePic() {
        
    }
    
    
    
    
    
    // MARK: - Images tapped
    @IBAction func avaImageView_tapped(_ sender: Any) {
        showIconOptions()
    }
    
    @IBAction func coverImageView_tapped(_ sender: Any) {
        //showIconOptions()
    }
    
   //MARK: HelperFunctions
   
   func showIconOptions() {

       let optionMenu = UIAlertController(title: "Choose Profile Picture", message: nil, preferredStyle: .actionSheet)

       let takePhotoActio = UIAlertAction(title: "Choose Photo", style: .default) { (alert) in

           let imagePicker = ImagePickerController()
           imagePicker.delegate = self
           imagePicker.imageLimit = 1

           self.present(imagePicker, animated: true, completion: nil)
       }

       let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in

       }

       if profileIcon != nil {

           let resetAction = UIAlertAction(title: "Reset", style: .default) { (alert) in

               self.profileIcon = nil
               self.avaImageView.image = UIImage(named: "cameraIcon")
               //self.editAvatarButtonOutlet.isHidden = true
           }
           optionMenu.addAction(resetAction)
       }

       optionMenu.addAction(takePhotoActio)
       optionMenu.addAction(cancelAction)

       if ( UI_USER_INTERFACE_IDIOM() == .pad )
       {
           if let currentPopoverpresentioncontroller = optionMenu.popoverPresentationController{

//               currentPopoverpresentioncontroller.sourceView = editAvatarButtonOutlet
//               currentPopoverpresentioncontroller.sourceRect = editAvatarButtonOutlet.bounds


               currentPopoverpresentioncontroller.permittedArrowDirections = .up
               self.present(optionMenu, animated: true, completion: nil)
           }
       } else {
           self.present(optionMenu, animated: true, completion: nil)
       }

   }
    
    
    
    
    
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }
    
    // heights of the cells
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            return UITableView.automaticDimension
        
    }
    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoachNoPicCell", for: indexPath) as! CoachNoPicCell
        
        
        return cell
        
    }
    
    
    
    
    
    // MARK: - Scroll Did Scroll
    // executed always whenever tableView is scrolling
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // load more posts when the scroll is about to reach the bottom AND currently is not loading (posts)
        let a = tableView.contentOffset.y - tableView.contentSize.height + 60
        let b = -tableView.frame.height
        
//        if a > b && isLoading == false {
//            //loadMore(offset: skip, limit: limit)
//
//        }
        
    }
    
    // MARK: - More Clicked
    @IBAction func moreButton_clicked(_ sender: Any) {
        // creating action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // creating buttons for action sheet
        let logout = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) in
            
            // access/instantiate loginViewController
            let loginvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            
            FUser.logOutCurrentUser { (success) in
                
                if success {
                    self.present(loginvc, animated: false, completion: nil)
                }
                
            }
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // add buttons to action sheet
        sheet.addAction(logout)
        sheet.addAction(cancel)
        
        // show action sheet
        present(sheet, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Option Button Click
    @IBAction func optionsButton_clicked(_ optionButton: UIButton) {
        // accessing indexPath of the button / cell
        let indexPathRow = optionButton.tag
        
        
        // creating actionSheet
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // creating Delete button
        let delete = UIAlertAction(title: "Delete Post", style: .destructive) { (delete) in
            self.deletePost(_: indexPathRow)
        }
        
        // creating Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // assigning buttons to the sheet
        alert.addAction(delete)
        alert.addAction(cancel)
        
        // showing actionSheet
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Delete Posts
    // sends request to the server to delete the post
    @objc func deletePost(_ row: Int) {
        
        // accessing id of the post which is stored in the tapped cell
        guard let id = posts[row]["id"] else {
            return
        }
        
        
        // remove the cell itself from the tableView
        let indexPath = IndexPath(row: row, section: 0)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        tableView.reloadData()
        
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



