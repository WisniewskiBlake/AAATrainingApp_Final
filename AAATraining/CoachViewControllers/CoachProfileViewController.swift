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
    
    var pictureToUpload: String? = ""
    
    // code obj (to build logic of distinguishing tapped / shown Cover / Ava)
    var isCover = false
    var isAva = false
    var imageViewTapped = ""
    
    var posts: [NSDictionary] = []
    var filteredPosts: [NSDictionary] = []
    var allPostsGrouped = NSDictionary() as! [String : [Post]]
    var picturePath: UIImage = UIImage()
    
    var allPosts: [Post] = []
    var avas = [UIImage]()
    var pictures = [UIImage]()
    var postDatesArray: [String] = []
    
    let helper = Helper()
    let user = FUser.currentUser()
    let currentDateFormater = Helper().dateFormatter()
    
    var uiColorOne: UIColor?
    var uiColorTwo: UIColor?
    var uiColorThree: UIColor?
    
    var teamColorOne: String?
    var teamColorTwo: String?
    var teamColorThree: String?
    
    let baselineTapGestureRecognizer = UITapGestureRecognizer()
    let nutritionTapGestureRecognizer = UITapGestureRecognizer()
    let postTapGestureRecognizer = UITapGestureRecognizer()
    let logoutTapGestureRecognizer = UITapGestureRecognizer()
    let coverTapGestureRecognizer = UITapGestureRecognizer()
       
    //var recentListener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "createPost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadUser), name: NSNotification.Name(rawValue: "updateUser"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "changeProPic"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "uploadPost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "deletePost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadUser), name: NSNotification.Name(rawValue: "changeTeamLogo"), object: nil)
        
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
        
        coverTapGestureRecognizer.addTarget(self, action: #selector(self.coverViewClicked))
        coverImageView.isUserInteractionEnabled = true
        coverImageView.addGestureRecognizer(coverTapGestureRecognizer)
        

        configure_avaImageView()
        
        

    }

    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUser()
        loadPosts()
        tableView.tableFooterView = UIView()
        // hide navigation bar on Home Pagex
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
   func configureUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
               
        currentDateFormater.dateFormat = "MM/dd/YYYY"
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    @objc func handleRefresh() {
        loadPosts()
        self.refreshControl?.endRefreshing()
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
            self.helper.imageFromData(pictureData: post.picture) { (pictureImage) in

                if pictureImage != nil {
                    let photos = IDMPhoto.photos(withImages: [pictureImage as Any])
                    let browser = IDMPhotoBrowser(photos: photos)
                    
                    self.present(browser!, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    
    
    @objc func baselineViewClicked() {

        let navigation = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "allBaselinesNav") as! UINavigationController
        
        self.present(navigation, animated: true, completion: nil)

    }
    
    @objc func nutritionViewClicked() {
        let navigationNutrition = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nutritionNav") as! UINavigationController
         let nutritionVC = navigationNutrition.viewControllers.first as! NutritionFeedVC
        nutritionVC.accountType = FUser.currentUser()?.accountType
        
        self.present(navigationNutrition, animated: true, completion: nil)
    }
    
    @objc func postViewClicked() {
        let postNav = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "postNav") as! UINavigationController
        
        
        postNav.modalPresentationStyle = .fullScreen
    
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        self.present(postNav, animated: true, completion: nil)
    }
    
    @objc func logoutViewClicked() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let copyCode = UIAlertAction(title: "Copy Team Code: " + FUser.currentUser()!.userCurrentTeamID, style: .default, handler: { (action) in
                        
            let pasteboard = UIPasteboard.general
            pasteboard.string = FUser.currentUser()!.userCurrentTeamID
            self.helper.showAlert(title: "Copied!", message: "Team code copied to clipboard.", in: self)
                
            
        })
        
        let colorPicker = UIAlertAction(title: "Choose Color Theme", style: .default, handler: { (action) in
                        
            
            let navigationColorPicker = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColorPickerNav") as! UINavigationController
             //let colorPickerVC = navigationColorPicker.viewControllers.first as! ColorPickerVC
            
            
            self.present(navigationColorPicker, animated: true, completion: nil)
                
            
        })
        
        let changeLogo = UIAlertAction(title: "Change Team Logo", style: .default, handler: { (action) in
                        
            self.coverViewClicked()
                
            
        })
        
        let backToTeamSelect = UIAlertAction(title: "Back To Team Select", style: .default, handler: { (action) in
                        
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamSelectionVC") as? TeamSelectionVC
            {
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
                
            
        })
        
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
        sheet.addAction(copyCode)
        sheet.addAction(colorPicker)
        sheet.addAction(changeLogo)
        sheet.addAction(backToTeamSelect)
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
        var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "", teamType: "", teamMemberCount: "", teamMemberAccountTypes: [""])
        
        team.getTeam(teamID: FUser.currentUser()!.userCurrentTeamID) { (teamReturned) in
            if teamReturned.teamID != "" {
                team = teamReturned
                if team.teamLogo != "" {
                    helper.imageFromData(pictureData: team.teamLogo) { (coverImage) in

                        if coverImage != nil {
                            self.coverImageView.image = coverImage!
                            self.isCover = true
                        }
                    }
                } else {
                    self.coverImageView.image = UIImage(named: "HomeCover.jpg")
                    self.isCover = false
                }
            } else {
                self.coverImageView.image = UIImage(named: "HomeCover.jpg")
                self.isCover = false
            }
        }
        
//        reference(.Team).document(FUser.currentUser()!.userTeamID).getDocument { (snapshot, error) in
//
//            guard let snapshot = snapshot else {  return }
//
//            if snapshot.exists {
//
//                let team = Team(_dictionary: snapshot.data()! as NSDictionary)
//
//                helper.imageFromData(pictureData: team.teamLogo) { (coverImage) in
//
//                    if coverImage != nil {
//                        self.coverImageView.image = coverImage!
//                        self.isCover = true
//                    }
//                }
//
//
//            } else {
//                self.coverImageView.image = UIImage(named: "HomeCover.jpg")
//                self.isCover = false
//            }
//        }
   
        guard let firstName = user?.firstname, let lastName = user?.lastname, let avaPath = user?.ava, let coverPath = user?.cover else {
               
               return
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
                self.avas = []
                self.pictures = []
                self.postDatesArray = []
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
                        self.helper.imageFromData(pictureData: post.postUserAva) { (avatarImage) in

                            if avatarImage != nil {
                                self.avas.append(avatarImage!.circleMasked!)
                            }
                            
                        }
                        if post.picture != "" {
                                self.helper.imageFromData(pictureData: post.picture) { (pictureImage) in

                                    if pictureImage != nil {
                                        self.pictures.append(pictureImage!)
                                    }
                                    
                                }

                            } else if post.video != "" {
                                
                                self.helper.imageFromData(pictureData: post.picture) { (pictureImage) in

                                    if pictureImage != nil {
                                        self.pictures.append(pictureImage!)
                                    }
                                }
                                
                            } else {
                                self.pictures.append(UIImage())
                            }
                        let postDate = self.helper.dateFormatter().date(from: post.date)
                        self.postDatesArray.append(self.currentDateFormater.string(from: postDate!))
                                        
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
        
        if allPosts.count == 0 {
            var emptyLabelOne = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 25))
            emptyLabelOne.text = "Created posts will appear here!"
            emptyLabelOne.textAlignment = NSTextAlignment.center
            self.tableView.backgroundView = emptyLabelOne
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            return 0
        } else {
            self.tableView.backgroundView = nil
            return allPosts.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var post: Post
                
            let cellPic = tableView.dequeueReusableCell(withIdentifier: "CoachPicCell", for: indexPath) as! CoachPicCell
            
            if allPosts.count > 0 {
                post = allPosts[indexPath.row]

                if post.postType == "video" {
                    
                    cellPic.avaImageView.image = self.avas[indexPath.row]
                    cellPic.pictureImageView.image = self.pictures[indexPath.row]
                    cellPic.playImageView.isHidden = false
                    
                    cellPic.postTextLabel.numberOfLines = 0
                    cellPic.postTextLabel.text = post.text
                    //DispatchQueue.main.async {
                        cellPic.dateLabel.text = self.postDatesArray[indexPath.row]
                        
                        
                        cellPic.delegate = self
                        cellPic.indexPath = indexPath
                        cellPic.fullnameLabel.text = post.postUserName
                        
                        cellPic.urlTextView.text = post.postUrlLink
                    //}
                        cellPic.optionsButton.tag = indexPath.row
                     return cellPic
                    
                } else if post.postType == "picture" {
                    
                    
                    cellPic.avaImageView.image = self.avas[indexPath.row]
                    cellPic.pictureImageView.image = self.pictures[indexPath.row]
                    
                    cellPic.postTextLabel.numberOfLines = 0
                    cellPic.postTextLabel.text = post.text
                    
                    //DispatchQueue.main.async {
                        
                        
                        cellPic.playImageView.isHidden = true
                                    
                        cellPic.dateLabel.text = self.postDatesArray[indexPath.row]
                        cellPic.delegate = self
                        cellPic.indexPath = indexPath
                        cellPic.fullnameLabel.text = post.postUserName
                        
                        cellPic.urlTextView.text = post.postUrlLink
                    //}
                    cellPic.optionsButton.tag = indexPath.row
                    return cellPic
                    
                } else {
                    let cellNoPic = tableView.dequeueReusableCell(withIdentifier: "CoachNoPicCell", for: indexPath) as! CoachNoPicCell
                    
                    cellNoPic.postTextLabel.numberOfLines = 0
                    cellNoPic.postTextLabel.text = post.text
                    
                    //DispatchQueue.main.async {
                    
                    cellNoPic.avaImageView.image = self.avas[indexPath.row]
                        
                    cellNoPic.dateLabel.text = self.postDatesArray[indexPath.row]
                    
                    cellNoPic.fullnameLabel.text = post.postUserName

                    cellNoPic.urlTextView.text = post.postUrlLink
                    //}
                     cellNoPic.optionsButton.tag = indexPath.row
                     return cellNoPic
                }
            }
                    
            
            
            return cellPic
    }
    
    // MARK: - Scroll Did Scroll
    // executed always whenever tableView is scrolling
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        // load more posts when the scroll is about to reach the bottom AND currently is not loading (posts)
//        let a = tableView.contentOffset.y - tableView.contentSize.height + 60
//        let b = -tableView.frame.height
//
//    }
    
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
        
        reference(.Post).document(postID).delete()
                
        self.allPosts.remove(at: row)
        
        
        
        // remove the cell itself from the tableView
        let indexPath = IndexPath(row: row, section: 0)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        tableView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "deletePost"), object: nil)
        
    }
    
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
    }



    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func coverViewClicked() {

        imageViewTapped = "cover"
        
        showActionSheet()
    }
    
    // MARK: - Images tapped
    @IBAction func avaImageView_tapped(_ sender: Any) {
        
        imageViewTapped = "ava"
        showActionSheet()
        //showIconOptions()
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
        
//        if ( UI_USER_INTERFACE_IDIOM() == .pad )
//        {
//            if let currentPopoverpresentioncontroller = sheet.popoverPresentationController{
//
//                currentPopoverpresentioncontroller.sourceView = self.inputToolbar.contentView.leftBarButtonItem
//                currentPopoverpresentioncontroller.sourceRect = self.inputToolbar.contentView.leftBarButtonItem.bounds
//
//                currentPopoverpresentioncontroller.permittedArrowDirections = .up
//                self.present(sheet, animated: true, completion: nil)
//            }
//        }else{
//            self.present(sheet, animated: true, completion: nil)
//        }
        
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                
        
        let image = info[UIImagePickerController.InfoKey(rawValue: convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage))] as? UIImage
        let picturePath = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        // based on the trigger we are assigning selected pictures to the appropriated imageView
        if imageViewTapped == "cover" {
            
            // assign selected image to CoverImageView
            self.coverImageView.image = picturePath
            
            let pictureData = image?.jpegData(compressionQuality: 0.4)!
            let cover = pictureData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))

            updateCurrentUserInFirestore(withValues: [kCOVER : cover!]) { (success) in
                //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeProPic"), object: nil)
                self.loadUser()
            }
            Team.updateTeam(teamID: FUser.currentUser()!.userCurrentTeamID, withValues: [kTEAMLOGO : cover!])
//            self.loadUser()
            
            
            
        } else if imageViewTapped == "ava" {
            
            
            // assign selected image to AvaImageView
            self.avaImageView.image = picturePath
            
            // refresh global variable storing the user's profile pic
            let pictureData = image?.jpegData(compressionQuality: 0.4)!
            let avatar = pictureData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            
            //FUser.currentUser().ava = self.avaImageView.image
            
            updateCurrentUserInFirestore(withValues: [kAVATAR : avatar!]) { (success) in
                //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeProPic"), object: nil)
            }
            if !allPosts.isEmpty {
                for post in allPosts {
    
                    post.updatePost(postID: post.postID, withValues: [kPOSTUSERAVA : avatar!])
                }
    
            }
            
            self.loadPosts()
            
        }
        
        // completion handler, to communicate to the project that images has been selected (enable delete button)
        dismiss(animated: true) {
            if self.imageViewTapped == "cover" {
                self.isCover = true
            } else if self.imageViewTapped == "ava" {
                self.isAva = true
            }
        }

//        profileIcon = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
//
//        let pictureData = profileIcon?.jpegData(compressionQuality: 0.4)!
//        let avatar = pictureData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
//
//
//        self.avaImageView.image = profileIcon
//
//        updateCurrentUserInFirestore(withValues: [kAVATAR : avatar!]) { (success) in
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeProPic"), object: nil)
//        }
//        if !allPosts.isEmpty {
//            for post in allPosts {
//
//                post.updatePost(postID: post.postID, withValues: [kPOSTUSERAVA : avatar!])
//            }
//
//        }
//
//        loadPosts()
//        picker.dismiss(animated: true, completion: nil)
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
    

    //MARK: HelperFunctions
       
       func showIconOptions() {

           let optionMenu = UIAlertController(title: "Choose Profile Picture", message: nil, preferredStyle: .actionSheet)
        
       
        //            camera.PresentPhotoLibrary(target: self, canEdit: false)
       

           let takePhotoActio = UIAlertAction(title: "Choose Photo", style: .default) { (alert) in
            //UIImagePickerController.SourceType = .photoLibrary
            let imagePicker = ImagePickerController()
            
               imagePicker.delegate = self
               //imagePicker.sourceType = .photoLibrary
            
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



