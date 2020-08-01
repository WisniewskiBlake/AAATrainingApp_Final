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
import ProgressHUD

class CoachProfileViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, ImagePickerDelegate {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    var profileIcon: UIImage?
    var coverIcon: UIImage?
    
    // code obj (to build logic of distinguishing tapped / shown Cover / Ava)
    var isCover = false
    var isAva = false
    
    var posts: [NSDictionary] = []
    var filteredPosts: [NSDictionary] = []
    var allPostsGrouped = NSDictionary() as! [String : [Post]]
    var allPosts: [Post] = []
    
    let helper = Helper()
    let user = FUser.currentUser()
       
    var recentListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // dynamic cell height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
//        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "createPost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadUser), name: NSNotification.Name(rawValue: "updateUser"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadNewPosts), name: NSNotification.Name(rawValue: "uploadPost"), object: nil)
        


        configure_avaImageView()
        loadUser()
//        loadPosts()
        

    }

    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        loadPosts()
        tableView.tableFooterView = UIView()
        // hide navigation bar on Home Pagex
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //recentListener.remove()
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
               coverImageView.image = UIImage(named: "aaaCoverLogo.png")
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
    @objc func loadPosts() {
        ProgressHUD.show()
        
        var query: Query!
        
        query = reference(.Post).whereField(kPOSTOWNERID, isEqualTo: FUser.currentId()).order(by: kPOSTDATE, descending: true)
        
        query.getDocuments { (snapshot, error) in
            self.allPosts = []
            self.allPostsGrouped = [:]
            
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            
            guard let snapshot = snapshot else {
                ProgressHUD.dismiss(); return
            }
            
            if !snapshot.isEmpty {
                
                for postDictionary in snapshot.documents {
                                let postDictionary = postDictionary.data() as NSDictionary
                                let post = Post(_dictionary: postDictionary)
                                   self.allPosts.append(post)
                                    print(self.allPosts)
                                    
                }
                self.tableView.reloadData()
            
            }
            ProgressHUD.dismiss()
        }
        
//        recentListener = reference(.Post).whereField(kPOSTOWNERID, isEqualTo: FUser.currentId()).order(by: kPOSTDATE, descending: true).addSnapshotListener({ (snapshot, error) in
           
           
//           self.allPosts = []
//            self.allPostsGrouped = [:]
//
//        guard let snapshot = snapshot else {  ProgressHUD.dismiss(); return }
//
//           if !snapshot.isEmpty {
//
//
//               for postDictionary in snapshot.documents {
//                let postDictionary = postDictionary.data() as NSDictionary
//
//                   if postDictionary[kPOSTTEXT] as! String != "" {
//
//                       let post = Post(_dictionary: postDictionary)
//
//                           self.allPosts.append(post)
//                    print(self.allPosts)
//                    }
//                }
//            self.tableView.reloadData()
//            }
//
//              ProgressHUD.dismiss()
//        })

       
        
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
   
    
    // MARK: - Images tapped
    @IBAction func avaImageView_tapped(_ sender: Any) {
        showIconOptions()
    }
    
    @IBAction func coverImageView_tapped(_ sender: Any) {
        //showIconOptions()
    }
    
   
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allPosts.count
    }
    
    // heights of the cells
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoachNoPicCell", for: indexPath) as! CoachNoPicCell
        
        var post: Post
        
        var date: Date!
        print(indexPath.row)
        print(indexPath)
        post = allPosts[indexPath.row]
        
        date = helper.dateFormatter().date(from: post.date)
        
         cell.dateLabel.text = helper.timeElapsed(date: date)
         
         
         
             helper.imageFromData(pictureData: post.postUserAva) { (avatarImage) in

                 if avatarImage != nil {

                     cell.avaImageView.image = avatarImage!.circleMasked
                 }
             }
         
         cell.fullnameLabel.text = post.postUserName

         cell.postTextLabel.text = post.text
        
//        var date: Date!
//
//        if let created = posts[indexPath.row][kPOSTDATE] {
//            if (created as! String).count != 14 {
//                date = Date()
//            } else {
//                date = helper.dateFormatter().date(from: created as! String)!
//            }
//        } else {
//            date = Date()
//        }
//        cell.dateLabel.text = helper.timeElapsed(date: date)
//
//
//        cell.avaImageView.image = self.avaImageView.image
//        cell.fullnameLabel.text = user!.firstname + " " + user!.lastname
//
//        cell.postTextLabel.text = posts[indexPath.row][kPOSTTEXT] as? String
//
//        //cell.commentsButton.tag = indexPath.row
//        cell.optionsButton.tag = indexPath.row
        
        return cell
        
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
            if !allPosts.isEmpty {
                for post in allPosts {
                    
                    post.updatePost(postID: post.postID, withValues: [kPOSTUSERAVA : avatar!])
                }
                
            }
            
        }
        loadPosts()
        self.dismiss(animated: true, completion: nil)
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
        let post = allPosts[row]
        
        let postID = post.postID
        
        reference(.Post).document(postID ).delete()
                
        self.allPosts.remove(at: row)
        

        
        
        // remove the cell itself from the tableView
        let indexPath = IndexPath(row: row, section: 0)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        tableView.reloadData()
        
    }
    
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
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
                   self.avaImageView.image = UIImage(named: "user.png")
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
    
    

}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}



