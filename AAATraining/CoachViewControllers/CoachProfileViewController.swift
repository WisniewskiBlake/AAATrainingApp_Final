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
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit

class CoachProfileViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, ImagePickerDelegate, CoachPicCellDelegate {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    
    @IBOutlet weak var baselineView: UIView!
    @IBOutlet weak var nutritionView: UIView!
    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var logoutView: UIView!
    
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
    
    let baselineTapGestureRecognizer = UITapGestureRecognizer()
    let nutritionTapGestureRecognizer = UITapGestureRecognizer()
    let postTapGestureRecognizer = UITapGestureRecognizer()
    let logoutTapGestureRecognizer = UITapGestureRecognizer()
       
    //var recentListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // dynamic cell height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200

        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "createPost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadUser), name: NSNotification.Name(rawValue: "updateUser"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadNewPosts), name: NSNotification.Name(rawValue: "uploadPost"), object: nil)
        
        baselineTapGestureRecognizer.addTarget(self, action: #selector(self.baselineViewClicked))
        baselineView.isUserInteractionEnabled = true
        baselineView.addGestureRecognizer(baselineTapGestureRecognizer)
        
        nutritionTapGestureRecognizer.addTarget(self, action: #selector(self.nutritionViewClicked))
        nutritionView.isUserInteractionEnabled = true
        nutritionView.addGestureRecognizer(nutritionTapGestureRecognizer)
        
        postTapGestureRecognizer.addTarget(self, action: #selector(self.postViewClicked))
        postView.isUserInteractionEnabled = true
        postView.addGestureRecognizer(postTapGestureRecognizer)
        
        logoutTapGestureRecognizer.addTarget(self, action: #selector(self.logoutViewClicked))
        logoutView.isUserInteractionEnabled = true
        logoutView.addGestureRecognizer(logoutTapGestureRecognizer)
        

        configure_avaImageView()
        loadUser()
        

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
    
    @objc func baselineViewClicked() {
//        let navigation = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "baselineNav") as! UINavigationController
//        let newBaselineVC = navigation.viewControllers.first as! PlayerBaselineVC
//        newBaselineVC.userBeingViewed = userBeingViewed
//
//        self.present(navigation, animated: true, completion: nil)
    }
    
    @objc func nutritionViewClicked() {
        let navigationNutrition = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nutritionNav") as! UINavigationController
         let nutritionVC = navigationNutrition.viewControllers.first as! NutritionFeedVC
        nutritionVC.accountType = FUser.currentUser()?.accountType
        
        self.present(navigationNutrition, animated: true, completion: nil)
    }
    
    @objc func postViewClicked() {
        let postNav = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "postNav") as! UINavigationController
    
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        self.present(postNav, animated: true, completion: nil)
    }
    
    @objc func logoutViewClicked() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // creating buttons for action sheet
        let logout = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) in
                        
            FUser.logOutCurrentUser { (success) in
                
                if success {
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
                    {
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
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
        DispatchQueue.main.async {
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
        }
        
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
    
    func didTapMediaImage(indexPath: IndexPath) {
        let post = allPosts[indexPath.row]
        let postType = post.postType
        
        if postType == "video" {
            let mediaItem = post.video
            
            let player = AVPlayer(url: Foundation.URL(string: mediaItem)!)
            let moviewPlayer = AVPlayerViewController()
            
            let session = AVAudioSession.sharedInstance()
            
            try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)

            moviewPlayer.player = player
            
            self.present(moviewPlayer, animated: true) {
                moviewPlayer.player!.play()
            }
        }
        if postType == "picture" {
            downloadImage(imageUrl: post.picture) { (image) in
                
                if image != nil {
                    let photos = IDMPhoto.photos(withImages: [image as Any])
                    let browser = IDMPhotoBrowser(photos: photos)
                    
                    self.present(browser!, animated: true, completion: nil)
                }
            }
            
        }
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
                var post: Post
                
        post = allPosts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoachPicCell", for: indexPath) as! CoachPicCell
        
        if post.postType == "video" {
            
            DispatchQueue.main.async {
                cell.playImageView.isHidden = false
                
                let thumbImage = self.createThumbnailOfVideoFromRemoteUrl(url: NSURL(string: post.video)!)
                         
                 var date: Date!
                 
                date = self.helper.dateFormatter().date(from: post.date)
                
                cell.dateLabel.text = self.helper.timeElapsed(date: date)
                         
                 
                self.helper.imageFromData(pictureData: post.postUserAva) { (avatarImage) in

                     if avatarImage != nil {

                         cell.avaImageView.image = avatarImage!.circleMasked
                     }
                 }
                
                cell.delegate = self
                cell.indexPath = indexPath
                cell.fullnameLabel.text = post.postUserName
                cell.pictureImageView.image = thumbImage
                cell.postTextLabel.text = post.text
                cell.urlTextView.text = post.postUrlLink
                cell.optionsButton.tag = indexPath.row
            }
            

            return cell
            
        } else if post.postType == "picture" {
            
            DispatchQueue.main.async {
                cell.playImageView.isHidden = true
                
                  var date: Date!
                  
                date = self.helper.dateFormatter().date(from: post.date)
                 
                cell.dateLabel.text = self.helper.timeElapsed(date: date)
                          
                  
                self.helper.imageFromData(pictureData: post.postUserAva) { (avatarImage) in

                      if avatarImage != nil {

                          cell.avaImageView.image = avatarImage!.circleMasked
                      }
                  }
                 downloadImage(imageUrl: post.picture) { (image) in
                     
                     if image != nil {
                         cell.pictureImageView.image = image!
                     }
                 }

                 cell.delegate = self
                 cell.indexPath = indexPath
                 cell.fullnameLabel.text = post.postUserName
                 cell.postTextLabel.text = post.text
                 cell.urlTextView.text = post.postUrlLink
                 cell.optionsButton.tag = indexPath.row
            }
            

             return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachNoPicCell", for: indexPath) as! CoachNoPicCell
             DispatchQueue.main.async {
                var date: Date!
                 
                date = self.helper.dateFormatter().date(from: post.date)
                
                cell.dateLabel.text = self.helper.timeElapsed(date: date)
                         
                 
                self.helper.imageFromData(pictureData: post.postUserAva) { (avatarImage) in

                     if avatarImage != nil {

                         cell.avaImageView.image = avatarImage!.circleMasked
                     }
                 }
                 
                 cell.fullnameLabel.text = post.postUserName

                 cell.postTextLabel.text = post.text
                
                 cell.urlTextView.text = post.postUrlLink
                
                 cell.optionsButton.tag = indexPath.row
            }
             
            
             return cell
            
        }
    }
    
    func createThumbnailOfVideoFromRemoteUrl(url: NSURL) -> UIImage? {
        let asset = AVAsset(url: url as URL)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        //Can set this to improve performance if target size is known before hand
        //assetImgGenerate.maximumSize = CGSize(width,height)
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
          print(error.localizedDescription)
          return nil
        }
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



