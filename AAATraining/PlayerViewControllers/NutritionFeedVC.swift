//
//  NutritionFeedVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/19/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import ImagePicker
import Firebase
import FirebaseFirestore
import ProgressHUD

import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import JSQMessagesViewController

class NutritionFeedVC: UITableViewController, CoachPicCellDelegate {
    
   var allPosts: [Nutrition] = []
   var recentListener: ListenerRegistration!
   
   var avas = [UIImage]()
   var pictures = [UIImage]()
   var postDatesArray: [String] = []
   var skip = 0
   var limit = 25
   var isLoading = false
   var accountType: String? = ""

   let helper = Helper()
   let currentDateFormater = Helper().dateFormatter()
   
    
    @IBOutlet weak var composeButton: UIBarButtonItem!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadNutritionPosts), name: NSNotification.Name(rawValue: "createNutritionPost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadAvaAfterUpload), name: NSNotification.Name(rawValue: "uploadImage"), object: nil)
        // add observers for notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadNutritionPostsAfterDelete), name: NSNotification.Name(rawValue: "deleteNutritionPost"), object: nil)
        
        if accountType == "player" {
            composeButton.isEnabled = false
        }
        
        
        currentDateFormater.dateFormat = "MM/dd/YYYY"
       
        loadNutritionPosts()
        
    }
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNutritionPosts()
    }
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    // MARK: - Load Posts
    @objc func loadNutritionPosts() {
        ProgressHUD.show()
        
        recentListener = reference(.Nutrition).order(by: kNUTRITIONPOSTDATE, descending: true).addSnapshotListener({ (snapshot, error) in
                   
            self.allPosts = []
            self.postDatesArray = []
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
                           
                        let post = Nutrition(_dictionary: userDictionary)
                           
                           self.allPosts.append(post)
                        self.helper.imageFromData(pictureData: post.nutritionPostUserAva) { (avatarImage) in

                            if avatarImage != nil {
                                self.avas.append(avatarImage!.circleMasked!)
                            }
                        }
                        if post.nutritionPicture != "" {
                            downloadImage(imageUrl: post.nutritionPicture) { (image) in
                                
                                if image != nil {
                                    self.pictures.append(image!)
                                }
                            }
                        } else if post.nutritionVideo != "" {
                            let thumbImage = self.createThumbnailOfVideoFromRemoteUrl(url: NSURL(string: post.nutritionVideo)!)
                            self.pictures.append(thumbImage!)
                        } else {
                            self.pictures.append(UIImage())
                        }
                        let postDate = self.helper.dateFormatter().date(from: post.nutritionDate)
                        self.postDatesArray.append(self.currentDateFormater.string(from: postDate!))
                        
                       }
                       self.tableView.reloadData()
                    
                   }
            ProgressHUD.dismiss()
               })
        
    }
    
    // MARK: - Load Delete
    @objc func loadNutritionPostsAfterDelete() {
        loadNutritionPosts()
    }
    // MARK: - Load Ava
    @objc func loadAvaAfterUpload() {
        loadNutritionPosts()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return allPosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            var post: Nutrition
                    
            post = allPosts[indexPath.row]
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoachPicCell", for: indexPath) as! CoachPicCell
            
            if post.nutritionPostType == "video" {
                
                DispatchQueue.main.async {
                    
                    cell.playImageView.isHidden = false
                    cell.dateLabel.text = self.postDatesArray[indexPath.row]
                    cell.avaImageView.image = self.avas[indexPath.row]
                    
                    cell.delegate = self
                    cell.indexPath = indexPath
                    cell.fullnameLabel.text = post.nutritionPostUserName
                    cell.pictureImageView.image = self.pictures[indexPath.row]
                    cell.postTextLabel.text = post.nutritionText
                    cell.urlTextView.text = post.nutritionPostUrlLink
                    cell.optionsButton.tag = indexPath.row
                    
                    if FUser.currentUser()?.accountType == "player" {
                        cell.optionsButton.isHidden = true
                    }
                }
                
                 return cell
                
            } else if post.nutritionPostType == "picture" {
                DispatchQueue.main.async {
                    
                    cell.playImageView.isHidden = true
                    cell.dateLabel.text = self.postDatesArray[indexPath.row]
                    
                    cell.avaImageView.image = self.avas[indexPath.row]
                    cell.pictureImageView.image = self.pictures[indexPath.row]
                    
                    cell.delegate = self
                    cell.indexPath = indexPath
                    cell.fullnameLabel.text = post.nutritionPostUserName
                    cell.postTextLabel.text = post.nutritionText
                    cell.urlTextView.text = post.nutritionPostUrlLink
                    cell.optionsButton.tag = indexPath.row
                    
                    if FUser.currentUser()?.accountType == "player" {
                        cell.optionsButton.isHidden = true
                    }
                }
                
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CoachNoPicCell", for: indexPath) as! CoachNoPicCell
                
                DispatchQueue.main.async {
                    
                    cell.dateLabel.text = self.postDatesArray[indexPath.row]
                    
                    cell.avaImageView.image = self.avas[indexPath.row]
                    
                    cell.fullnameLabel.text = post.nutritionPostUserName

                    cell.postTextLabel.text = post.nutritionText

                    cell.urlTextView.text = post.nutritionPostUrlLink
                    
                    cell.optionsButton.tag = indexPath.row
                    
                    if FUser.currentUser()?.accountType == "player" {
                        cell.optionsButton.isHidden = true
                    }
                    
                    
                }
                
                 return cell
                
            }
    }
    
    @IBAction func deleteButtonClicked(_ optionButton: UIButton) {
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
        
        let postID = post.nutritionPostID
        
        reference(.Nutrition).document(postID).delete()
                
        self.allPosts.remove(at: row)
        
        // remove the cell itself from the tableView
        let indexPath = IndexPath(row: row, section: 0)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        tableView.reloadData()
        
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
    
    func didTapMediaImage(indexPath: IndexPath) {
        let post = allPosts[indexPath.row]
        let postType = post.nutritionPostType
        
        if postType == "video" {
            let mediaItem = post.nutritionVideo
            
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
            downloadImage(imageUrl: post.nutritionPicture) { (image) in
                
                if image != nil {
                    let photos = IDMPhoto.photos(withImages: [image as Any])
                    let browser = IDMPhotoBrowser(photos: photos)
                    
                    self.present(browser!, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    @IBAction func composeButtonClicked(_ sender: Any) {
        let nutritionPostVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NutritionPostVC") as! NutritionPostVC
        self.navigationController?.pushViewController(nutritionPostVC, animated: true)
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    

}
