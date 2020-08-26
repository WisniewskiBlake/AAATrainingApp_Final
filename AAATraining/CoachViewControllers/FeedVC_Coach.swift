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

class FeedVC_Coach: UITableViewController, CoachPicCellDelegate {
        
    var allPosts: [Post] = []
    var recentListener: ListenerRegistration!
    
    var avas = [UIImage]()
    var pictures = [UIImage]()
    var skip = 0
    var limit = 25
    var isLoading = false
 
    let helper = Helper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //configureNavBar()
        // dynamic cell height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        setBadges(controller: self.tabBarController!, accountType: "coach")       
        setCalendarBadges(controller: self.tabBarController!, accountType: "coach")
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "createPost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadAvaAfterUpload), name: NSNotification.Name(rawValue: "uploadImage"), object: nil)
        // add observers for notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPostsAfterDelete), name: NSNotification.Name(rawValue: "deletePost"), object: nil)
        

        // run function
        loadPosts()
        //createImages()
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
    
   
    
    func configureNavBar() {
        let imageView = UIImageView(image: UIImage(named: "aaaLogo.png"))        
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
    }
    

    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadPosts()
       
        //navigationController?.setNavigationBarHidden(true, animated: true)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    
    // MARK: - Load Posts
    @objc func loadPosts() {
        ProgressHUD.show()
        
        DispatchQueue.main.async {
            self.recentListener = reference(.Post).order(by: kPOSTDATE, descending: true).addSnapshotListener({ (snapshot, error) in
                   
            self.allPosts = []
            self.avas = []
            self.pictures = []
            
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
                                downloadImage(imageUrl: post.picture) { (image) in
                                    
                                    if image != nil {
                                        self.pictures.append(image!)
                                    }
                                }
                            } else if post.video != "" {
                                let thumbImage = self.createThumbnailOfVideoFromRemoteUrl(url: NSURL(string: post.video)!)
                                self.pictures.append(thumbImage!)
                            } else {
                                self.pictures.append(UIImage())
                            }
                       }
                       self.tableView.reloadData()
                    
                   }
            ProgressHUD.dismiss()
               })
        }
        
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
    
    // MARK: - Load More
    // loading more posts from the server via PHP protocol
    @objc func loadMore() {
        
    }

    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allPosts.count
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var post: Post
                
        post = allPosts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoachPicCell", for: indexPath) as! CoachPicCell
        

        if post.postType == "video" {
            
            DispatchQueue.main.async {
                
                var date: String?
                let currentDateFormater = self.helper.dateFormatter()
                currentDateFormater.dateFormat = "MM/dd/YYYY"
                let postDate = self.helper.dateFormatter().date(from: post.date)
                date = currentDateFormater.string(from: postDate!)
                cell.avaImageView.image = self.avas[indexPath.row]
                
                
                cell.pictureImageView.image = self.pictures[indexPath.row]
                cell.playImageView.isHidden = false
                cell.dateLabel.text = date
                cell.delegate = self
                cell.indexPath = indexPath
                cell.fullnameLabel.text = post.postUserName
                cell.postTextLabel.text = post.text
                cell.urlTextView.text = post.postUrlLink
            }
             return cell
            
        } else if post.postType == "picture" {
            
            var date: String?
            let currentDateFormater = helper.dateFormatter()
            currentDateFormater.dateFormat = "MM/dd/YYYY"
            let postDate = helper.dateFormatter().date(from: post.date)
            date = currentDateFormater.string(from: postDate!)
            
            DispatchQueue.main.async {
                cell.avaImageView.image = self.avas[indexPath.row]
                cell.pictureImageView.image = self.pictures[indexPath.row]
                
                cell.playImageView.isHidden = true
                            
                cell.dateLabel.text = date
                cell.delegate = self
                cell.indexPath = indexPath
                cell.fullnameLabel.text = post.postUserName
                cell.postTextLabel.text = post.text
                cell.urlTextView.text = post.postUrlLink
            }
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachNoPicCell", for: indexPath) as! CoachNoPicCell
            
            var date: String?
            let currentDateFormater = helper.dateFormatter()
            currentDateFormater.dateFormat = "MM/dd/YYYY"
            let postDate = helper.dateFormatter().date(from: post.date)
            date = currentDateFormater.string(from: postDate!)
            
            DispatchQueue.main.async {

                cell.avaImageView.image = self.avas[indexPath.row]
                
                cell.dateLabel.text = date
                
                cell.fullnameLabel.text = post.postUserName

                cell.postTextLabel.text = post.text

                cell.urlTextView.text = post.postUrlLink
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
    

    
    // MARK: - Scroll Did Scroll
    // executed always whenever tableView is scrolling
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // load more posts when the scroll is about to reach the bottom AND currently is not loading (posts)
        let a = tableView.contentOffset.y - tableView.contentSize.height + 60
        let b = -tableView.frame.height
        
        if a > b && isLoading == false {
            loadMore()

        }
        
    }

    
    

}

extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}
