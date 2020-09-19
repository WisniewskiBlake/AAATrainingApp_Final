//
//  PlayerFeedVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/2/20.
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

class PlayerFeedVC: UITableViewController, CoachPicCellDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var teamImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var teamFeedTextLabel: UILabel!
    @IBOutlet weak var membersTextLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var moreImageView: UIImageView!
    
    var allPosts: [Post] = []
    var allUsers: [FUser] = []
       var recentListener: ListenerRegistration!
       
    var avas = [UIImage]()
    var pictures = [UIImage]()
    var postDatesArray: [String] = []

   var isLoading = false

    var emptyLabelOne = UILabel()
    
    var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "", teamType: "", teamMemberCount: "", teamMemberAccountTypes: [""])
    
       let helper = Helper()
       let currentDateFormater = Helper().dateFormatter()
    
    let moreTapGestureRecognizer = UITapGestureRecognizer()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMembers()
        
        
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadNewPosts), name: NSNotification.Name(rawValue: "createPost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadAvaAfterUpload), name: NSNotification.Name(rawValue: "uploadImage"), object: nil)
        // add observers for notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "deletePost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "changeProPic"), object: nil)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
        moreTapGestureRecognizer.addTarget(self, action: #selector(self.moreImageViewClicked))
        moreImageView.isUserInteractionEnabled = true
        moreImageView.addGestureRecognizer(moreTapGestureRecognizer)
        
        emptyLabelOne = UILabel(frame: CGRect(x: 0, y: -150, width: view.bounds.size.width, height: view.bounds.size.height))
        
        
    
        // run function
        
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
    
    func configureUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        
        setBadges(controller: self.tabBarController!, accountType: "player")
        setCalendarBadges(controller: self.tabBarController!, accountType: "player")
        
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
        ProgressHUD.show()
               
               let query = reference(.Team).whereField(kTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID)
               query.getDocuments { (snapshot, error) in
        
                   
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
                           let team = Team(_dictionary: userDictionary)
                           self.membersTextLabel.text = team.teamMemberCount + " Team Members"
                           
                       }
                       

                   }
                   ProgressHUD.dismiss()
               }
        
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
        sheet.addAction(backToTeamSelect)
        sheet.addAction(logout)
        sheet.addAction(cancel)
        
        // show action sheet
        present(sheet, animated: true, completion: nil)
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
    
    // MARK: - Load Posts
    @objc func loadPosts() {
        ProgressHUD.show()
        
            self.recentListener = reference(.Post).whereField(kPOSTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID as Any).order(by: kPOSTDATE, descending: true).limit(to: 100).addSnapshotListener({ (snapshot, error) in
                   
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
            ProgressHUD.dismiss()
            })
        
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
                    let cellNoPic = tableView.dequeueReusableCell(withIdentifier: "CoachNoPicCell", for: indexPath) as! CoachNoPicCell
                    
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

}
