//
//  FeedVC_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/15/20.
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
import JSQMessagesViewController

class FeedVC_Coach: UITableViewController, CoachPicCellDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
        
    var allPosts: [Post] = []
    var allUsers: [FUser] = []
    var recentListener: ListenerRegistration!
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var teamImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var teamFeedTextLabel: UILabel!
    @IBOutlet weak var membersTextLabel: UILabel!
    
    @IBOutlet weak var moreImageView: UIImageView!
    @IBOutlet weak var postImageView: UIImageView!
    
    
    var avas = [UIImage]()
    var pictures = [UIImage]()
    var postDatesArray: [String] = []
    //var thumbImage = UIImage()
    var skip = 0
    var limit = 25
    var isLoading = false
    
    var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "", teamType: "")
 
    let helper = Helper()
    let currentDateFormater = Helper().dateFormatter()
    
    let moreTapGestureRecognizer = UITapGestureRecognizer()
    let postTapGestureRecognizer = UITapGestureRecognizer()
    let teamImageTapGestureRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMembers()

        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "createPost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "changeProPic"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadAvaAfterUpload), name: NSNotification.Name(rawValue: "uploadImage"), object: nil)
        // add observers for notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "deletePost"), object: nil)
        
        moreTapGestureRecognizer.addTarget(self, action: #selector(self.moreImageViewClicked))
        moreImageView.isUserInteractionEnabled = true
        moreImageView.addGestureRecognizer(moreTapGestureRecognizer)
        
        postTapGestureRecognizer.addTarget(self, action: #selector(self.postImageViewClicked))
        postImageView.isUserInteractionEnabled = true
        postImageView.addGestureRecognizer(postTapGestureRecognizer)
        
        teamImageTapGestureRecognizer.addTarget(self, action: #selector(self.teamImageViewClicked))
        teamImageView.isUserInteractionEnabled = true
        teamImageView.addGestureRecognizer(teamImageTapGestureRecognizer)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)

        
        // run functions
        
        loadPosts()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fillContentGap:
        if let tableFooterView = tableView.tableFooterView {
            /// The expected height for the footer under autolayout.
            let footerHeight = tableFooterView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            /// The amount of empty space to fill with the footer view.
            let gapHeight: CGFloat = tableView.bounds.height - tableView.adjustedContentInset.top - tableView.adjustedContentInset.bottom - tableView.contentSize.height
            // Ensure there is space to be filled
            guard gapHeight.rounded() > 0 else { break fillContentGap }
            // Fill the gap
            tableFooterView.frame.size.height = gapHeight + footerHeight
        }
    }
    
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMembers()
        configureUI()
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.9133789539, green: 0.9214370847, blue: 0.9337923527, alpha: 1)
        tableView.tableFooterView = view
        
        //loadPosts()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    
    
    func configureUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        
        setBadges(controller: self.tabBarController!, accountType: "coach")
        setCalendarBadges(controller: self.tabBarController!, accountType: "coach")
        
        tableView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        tableView.separatorColor = UIColor.clear
        
        titleView.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        titleView.alpha = 1.0
        
        
        
        teamImageView.layer.cornerRadius = teamImageView.frame.width / 2
        teamImageView.clipsToBounds = true
        
        teamFeedTextLabel.text = "Team Feed"
        teamFeedTextLabel.font = UIFont(name: "PROGRESSPERSONALUSE", size: 27)!
        teamNameLabel.font = UIFont(name: "PROGRESSPERSONALUSE", size: 17)!
        
        team.getTeam(teamID: FUser.currentUser()!.userTeamID) { (teamReturned) in
            if teamReturned.teamID != "" {
                self.team = teamReturned
                if self.team.teamLogo != "" {
                    self.helper.imageFromData(pictureData: self.team.teamLogo) { (coverImage) in

                        if coverImage != nil {
                            self.teamImageView.image = coverImage
                        }
                    }
                } else {
                    self.teamImageView.image = UIImage(named: "HomeCover.jpg")
                    
                }
                self.teamNameLabel.text = self.team.teamName
            } else {
                self.teamImageView.image = UIImage(named: "HomeCover.jpg")
            }
        }
        self.navigationController?.view.addSubview(self.titleView)
        self.navigationController?.navigationBar.layer.zPosition = 0;
        
        currentDateFormater.dateFormat = "MM/dd/YYYY"
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func getMembers() {
        ProgressHUD.show()
        
        var query = reference(.User).whereField(kUSERTEAMID, isEqualTo: FUser.currentUser()?.userTeamID).order(by: kFIRSTNAME, descending: false)
        query.getDocuments { (snapshot, error) in
            
            self.allUsers = []
            
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
             self.helper.showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                 
                return
            }
            
            guard let snapshot = snapshot else {
             self.helper.showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
             self.isLoading = false
                ProgressHUD.dismiss(); return
            }
            
            if !snapshot.isEmpty {
                
                for userDictionary in snapshot.documents {
                    
                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    
                    
                    self.allUsers.append(fUser)
                    
                }
                self.membersTextLabel.text = String(self.allUsers.count) + " Team Members"

            }
            ProgressHUD.dismiss()
        }
        
    }
    
    @objc func handleRefresh() {
        loadPosts()
        self.refreshControl?.endRefreshing()
    }
    
    @objc func postImageViewClicked() {
        let postNav = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "postNav") as! UINavigationController
        
            self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

            self.present(postNav, animated: true, completion: nil)
    }
    
    @objc func teamImageViewClicked() {
        showActionSheet()
    }
    
    @objc func moreImageViewClicked() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let copyCode = UIAlertAction(title: "Copy Team Code: " + FUser.currentUser()!.userTeamID, style: .default, handler: { (action) in
                        
            let pasteboard = UIPasteboard.general
            pasteboard.string = FUser.currentUser()!.userTeamID
            self.helper.showAlert(title: "Copied!", message: "Team code copied to clipboard.", in: self)
                
            
        })
        
        let colorPicker = UIAlertAction(title: "Choose Color Theme", style: .default, handler: { (action) in
                        
            
            let navigationColorPicker = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ColorPickerNav") as! UINavigationController
             //let colorPickerVC = navigationColorPicker.viewControllers.first as! ColorPickerVC
            
            
            self.present(navigationColorPicker, animated: true, completion: nil)
                
            
        })
        
        let changeLogo = UIAlertAction(title: "Change Team Logo", style: .default, handler: { (action) in
                        
            self.teamImageViewClicked()
                
            
        })
        
        // creating buttons for action sheet
        let logout = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) in
                        
            FUser.logOutCurrentUser { (success) in
                
                if success {
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamLoginVC") as? TeamLoginVC
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
        sheet.addAction(logout)
        sheet.addAction(cancel)
        
        // show action sheet
        present(sheet, animated: true, completion: nil)
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

    

    
    
    
    
    // MARK: - Load Posts
    @objc func loadPosts() {
        ProgressHUD.show()
        
        //DispatchQueue.main.async {
        recentListener = reference(.Post).whereField(kPOSTTEAMID, isEqualTo: FUser.currentUser()?.userTeamID as Any).order(by: kPOSTDATE, descending: true).limit(to: 100).addSnapshotListener({ (snapshot, error) in
                   
            self.allPosts = []
            self.avas = []
            self.pictures = []
            self.postDatesArray = []
            
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
                   guard let snapshot = snapshot else { ProgressHUD.dismiss(); return }

                   if !snapshot.isEmpty {

                       for userDictionary in snapshot.documents {
                           
                           let userDictionary = userDictionary.data() as NSDictionary
                           
                            let post = Post(_dictionary: userDictionary)
                           
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
            self.tableView.reloadData()
                ProgressHUD.dismiss()
               })
        //}
        
    }
    
    // MARK: - Load New
    // exec-d when new post is published
        @objc func loadNewPosts() {
            
            // skipping 0 posts, as we want to load the entire feed. And we are extending Limit value based on the previous loaded posts.
            loadPosts()
   
        }
    // MARK: - Load Delete
    @objc func loadPostsAfterDelete() {
            
            // skipping 0 posts, as we want to load the entire feed. And we are extending Limit value based on the previous loaded posts.
            loadPosts()
    
        }
    
    // MARK: - Load Ava
    @objc func loadAvaAfterUpload() {
            
        // skipping 0 posts, as we want to load the entire feed. And we are extending Limit value based on the previous loaded posts.
        loadPosts()
    
    }
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return allPosts.count
        if allPosts.count == 0 {
            var emptyLabelOne = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
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
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
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

                 return cellPic
                
            } else if post.postType == "picture" {
                let cellPic = tableView.dequeueReusableCell(withIdentifier: "CoachPicCell", for: indexPath) as! CoachPicCell
                
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
                
                return cellPic
                
            } else {
                let cellNoPic = tableView.dequeueReusableCell(withIdentifier: "CoachNoPicCell", for: indexPath) as!
                CoachNoPicCell
                
//                let bottomBorder = CALayer()
//
//                bottomBorder.frame = CGRect(x: 0.0, y: 43.0, width: cellNoPic.contentView.frame.size.width, height: 1.0)
//                bottomBorder.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
//                cellNoPic.contentView.layer.addSublayer(bottomBorder)
                
                cellNoPic.postTextLabel.numberOfLines = 0
                cellNoPic.postTextLabel.text = post.text
                
                //DispatchQueue.main.async {
                    
                    cellNoPic.avaImageView.image = self.avas[indexPath.row]
                    
                    cellNoPic.dateLabel.text = self.postDatesArray[indexPath.row]
                    
                    cellNoPic.fullnameLabel.text = post.postUserName

                    cellNoPic.urlTextView.text = post.postUrlLink
                //}
                                 
                 return cellNoPic
            }
        }
                
        
        
        return cellPic
        
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                    
            
            let image = info[UIImagePickerController.InfoKey(rawValue: convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage))] as? UIImage
            //picturePath = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            
            // based on the trigger we are assigning selected pictures to the appropriated imageView
            
                
                // assign selected image to CoverImageView
                self.teamImageView.image = image
                
                let pictureData = image?.jpegData(compressionQuality: 0.4)!
                let cover = pictureData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))


                updateCurrentUserInFirestore(withValues: [kCOVER : cover!]) { (success) in
                    
                    
                }
                Team.updateTeam(teamID: FUser.currentUser()!.userTeamID, withValues: [kTEAMLOGO : cover!])
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeTeamLogo"), object: nil)
                
                
                
            
            
            // completion handler, to communicate to the project that images has been selected (enable delete button)
            dismiss(animated: true) {
                
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

extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}

