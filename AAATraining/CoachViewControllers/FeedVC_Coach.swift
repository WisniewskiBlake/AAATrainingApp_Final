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


    var isLoading = false
    var emptyLabelOne = UILabel()
    var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "", teamType: "", teamMemberCount: "", teamMemberAccountTypes: [""])
    let helper = Helper()
    let currentDateFormater = Helper().dateFormatter()
    
    let moreTapGestureRecognizer = UITapGestureRecognizer()
    let postTapGestureRecognizer = UITapGestureRecognizer()
    let teamImageTapGestureRecognizer = UITapGestureRecognizer()
    
    let actionButton = JJFloatingActionButton()
    
    
    
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

        emptyLabelOne = UILabel(frame: CGRect(x: 0, y: -150, width: view.bounds.size.width, height: view.bounds.size.height))
        
        

//        configureFloatingButton()
//        self.view.addSubview(actionButton)
//        self.navigationController?.view.addSubview(actionButton)
//        for family in UIFont.familyNames.sorted() {
//            let names = UIFont.fontNames(forFamilyName: family)
//            print("Family: \(family) Font names: \(names)")
//        }
        
        
    }
    
    func configureFloatingButton() {
        
//        actionButton.addItem(title: "item 1", image: UIImage(named: "First")?.withRenderingMode(.alwaysTemplate)) { item in
//          // do something
//        }
//
//        actionButton.addItem(title: "item 2", image: UIImage(named: "Second")?.withRenderingMode(.alwaysTemplate)) { item in
//          // do something
//        }
//
//        actionButton.addItem(title: "item 3", image: nil) { item in
//          // do something
//        }

        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor, constant: 16).isActive = true
        actionButton.bottomAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 16).isActive = true
        
        
        actionButton.handleSingleActionDirectly = false
        actionButton.buttonDiameter = 65
        actionButton.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.3)
        actionButton.buttonImage = UIImage(named: "Dots")
        actionButton.buttonColor = .red
        actionButton.buttonImageColor = .white
        actionButton.buttonImageSize = CGSize(width: 30, height: 30)

        actionButton.buttonAnimationConfiguration = .transition(toImage: UIImage(named: "X")!)
        actionButton.itemAnimationConfiguration = .slideIn(withInterItemSpacing: 14)

        actionButton.layer.shadowColor = UIColor.black.cgColor
        actionButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        actionButton.layer.shadowOpacity = Float(0.4)
        actionButton.layer.shadowRadius = CGFloat(2)

        actionButton.itemSizeRatio = CGFloat(0.75)
        actionButton.configureDefaultItem { item in
            item.titlePosition = .trailing

            item.titleLabel.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
            item.titleLabel.textColor = .white
            item.buttonColor = .white
            item.buttonImageColor = .red

            item.layer.shadowColor = UIColor.black.cgColor
            item.layer.shadowOffset = CGSize(width: 0, height: 1)
            item.layer.shadowOpacity = Float(0.4)
            item.layer.shadowRadius = CGFloat(2)
        }

        actionButton.addItem(title: "Balloon", image: UIImage(named: "Baloon")) { item in
            // Do something
        }

        let item = actionButton.addItem()
        item.titleLabel.text = "Owl"
        item.imageView.image = UIImage(named: "Owl")
        item.buttonColor = .black
        item.buttonImageColor = .white
        //item.buttonImageColor = CGSize(width: 30, height: 30)
        item.action = { item in
            // Do something
        }
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
        GIFHUD.shared.setGif(named: "loaderFinal.gif")
        loadPosts()
        getMembers()
        
        configureUI()
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.tableFooterView = view


    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    func configure_teamImageView() {
        let border = CALayer()
        border.borderColor = UIColor.white.cgColor
        border.borderWidth = 2
        border.frame = CGRect(x: 0, y: 0, width: teamImageView.frame.width, height: teamImageView.frame.height)
        teamImageView.layer.addSublayer(border)
        
        // rounded corners
        teamImageView.layer.cornerRadius = teamImageView.frame.width / 2
        //teamImageView.layer.masksToBounds = true
        teamImageView.clipsToBounds = true
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
        teamFeedTextLabel.font = UIFont(name: "PROGRESSPERSONALUSE", size: 28)!
        teamNameLabel.font = UIFont(name: "PROGRESSPERSONALUSE", size: 18)!
        
        team.getTeam(teamID: FUser.currentUser()!.userCurrentTeamID) { (teamReturned) in
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
        GIFHUD.shared.show(withOverlay: true)
        
        let query = reference(.Team).whereField(kTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID)
        query.getDocuments { (snapshot, error) in
 
            
            if error != nil {
                print(error!.localizedDescription)
                GIFHUD.shared.dismiss()
             self.helper.showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                 
                return
            }
            
            guard let snapshot = snapshot else {
             self.helper.showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
             self.isLoading = false
                GIFHUD.shared.dismiss(); return
            }
            
            if !snapshot.isEmpty {
                
                for userDictionary in snapshot.documents {
                    
                    let userDictionary = userDictionary.data() as NSDictionary
                    let team = Team(_dictionary: userDictionary)
                    self.membersTextLabel.text = team.teamMemberCount + " Team Members"
                    
                }
                

            }
            GIFHUD.shared.dismiss()
        }
        
    }
    
    @objc func handleRefresh() {
        loadPosts()
        self.refreshControl?.endRefreshing()
    }
    
    

    
    
    // MARK: - Load Posts
    @objc func loadPosts() {
        GIFHUD.shared.show(withOverlay: true)
        
        //DispatchQueue.main.async {
        recentListener = reference(.Post).whereField(kPOSTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID as Any).order(by: kPOSTDATE, descending: true).limit(to: 100).addSnapshotListener({ (snapshot, error) in
                   
            self.allPosts = []
            self.avas = []
            self.pictures = []
            self.postDatesArray = []
            
            if error != nil {
                print(error!.localizedDescription)
                GIFHUD.shared.dismiss()
                self.tableView.reloadData()
                return
            }
                   guard let snapshot = snapshot else { GIFHUD.shared.dismiss(); return }

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

                
            GIFHUD.shared.dismiss()
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
            
            emptyLabelOne.text = "Created posts will appear here!"
            emptyLabelOne.textAlignment = NSTextAlignment.center
            self.tableView.tableFooterView!.addSubview(emptyLabelOne)
            return 0
        } else {
            emptyLabelOne.text = ""
            emptyLabelOne.removeFromSuperview()
            
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
                        
            self.teamImageViewClicked()
                
            
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
                Team.updateTeam(teamID: FUser.currentUser()!.userCurrentTeamID, withValues: [kTEAMLOGO : cover!])
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







