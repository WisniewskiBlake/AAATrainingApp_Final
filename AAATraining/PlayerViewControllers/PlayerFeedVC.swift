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

class PlayerFeedVC: UITableViewController, CoachPicCellDelegate {
    
    var allPosts: [Post] = []
       var recentListener: ListenerRegistration!
       
       var avas = [UIImage]()
       var pictures = [UIImage]()
       var postDatesArray: [String] = []
       var skip = 0
       var limit = 25
       var isLoading = false
       var liked = [Int]()
       
       var lastNames : [String] = []
    
       let helper = Helper()
       let currentDateFormater = Helper().dateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadNewPosts), name: NSNotification.Name(rawValue: "createPost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadAvaAfterUpload), name: NSNotification.Name(rawValue: "uploadImage"), object: nil)
        // add observers for notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPostsAfterDelete), name: NSNotification.Name(rawValue: "deletePost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "changeProPic"), object: nil)
        
        
        
        self.setLeftAlignedNavigationItemTitle(text: "Team Feed", color: .white, margin: 12)
    
        // run function
        loadPosts()
    }
    
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        tableView.tableFooterView = UIView()
        //loadPosts()
        //navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    func configureUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        
        setBadges(controller: self.tabBarController!, accountType: "player")
        setCalendarBadges(controller: self.tabBarController!, accountType: "player")
        
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
    
    // MARK: - Load Posts
    @objc func loadPosts() {
        ProgressHUD.show()
        
            self.recentListener = reference(.Post).whereField(kPOSTTEAMID, isEqualTo: FUser.currentUser()?.userTeamID as Any).order(by: kPOSTDATE, descending: true).limit(to: 100).addSnapshotListener({ (snapshot, error) in
                   
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
        return allPosts.count
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
    
    
    // MARK: - Scroll Did Scroll
    // executed always whenever tableView is scrolling
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        // load more posts when the scroll is about to reach the bottom AND currently is not loading (posts)
//        let a = tableView.contentOffset.y - tableView.contentSize.height + 60
//        let b = -tableView.frame.height
//
//        if a > b && isLoading == false {
//            loadMore()
//
//        }
//
//    }

}
