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
        
        configureUI()
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadNutritionPosts), name: NSNotification.Name(rawValue: "createNutritionPost"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadAvaAfterUpload), name: NSNotification.Name(rawValue: "uploadImage"), object: nil)
        // add observers for notifications
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadNutritionPostsAfterDelete), name: NSNotification.Name(rawValue: "deleteNutritionPost"), object: nil)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        if accountType == "Player" {
            composeButton.isEnabled = false
        }
       
        loadNutritionPosts()
        
    }
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GIFHUD.shared.setGif(named: "loaderFinal.gif")
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        tableView.tableFooterView = UIView()
        //loadPosts()

    }
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
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
        loadNutritionPosts()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Load Posts
    @objc func loadNutritionPosts() {
        GIFHUD.shared.show(withOverlay: true)
        
        recentListener = reference(.Nutrition).order(by: kNUTRITIONPOSTDATE, descending: true).whereField(kNUTRITIONTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID as Any).limit(to: 100).addSnapshotListener({ (snapshot, error) in
                   
            self.allPosts = []
            self.postDatesArray = []
            self.avas = []
            self.pictures = []
            
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
                           
                           let post = Nutrition(_dictionary: userDictionary)
                           
                           self.allPosts.append(post)
                           self.helper.imageFromData(pictureData: post.nutritionPostUserAva) { (avatarImage) in

                                   if avatarImage != nil {
                                       self.avas.append(avatarImage!.circleMasked!)
                                   }
                               }
                               if post.nutritionPicture != "" {
                                   self.helper.imageFromData(pictureData: post.nutritionPicture) { (pictureImage) in

                                       if pictureImage != nil {
                                           self.pictures.append(pictureImage!)
                                       }
                                   }

                               } else if post.nutritionVideo != "" {
                                   
                                   self.helper.imageFromData(pictureData: post.nutritionPicture) { (pictureImage) in

                                       if pictureImage != nil {
                                           self.pictures.append(pictureImage!)
                                       }
                                   }
                                   
                               } else {
                                   self.pictures.append(UIImage())
                               }
                           let postDate = self.helper.dateFormatter().date(from: post.nutritionDate)
                           self.postDatesArray.append(self.currentDateFormater.string(from: postDate!))
                       }
                       self.tableView.reloadData()
                    
                   }
                GIFHUD.shared.dismiss()
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            var post: Nutrition
                    
            post = allPosts[indexPath.row]
        
            let cellPic = tableView.dequeueReusableCell(withIdentifier: "CoachPicCell", for: indexPath) as! CoachPicCell
            
            if allPosts.count > 0 {
                post = allPosts[indexPath.row]

                if post.nutritionPostType == "video" {
                    
                    cellPic.avaImageView.image = self.avas[indexPath.row]
                    cellPic.pictureImageView.image = self.pictures[indexPath.row]
                    cellPic.playImageView.isHidden = false
                    
                    cellPic.postTextLabel.numberOfLines = 0
                    cellPic.postTextLabel.text = post.nutritionText
                    //DispatchQueue.main.async {
                    cellPic.dateLabel.text = self.postDatesArray[indexPath.row]
                    
                    
                    cellPic.delegate = self
                    cellPic.indexPath = indexPath
                    cellPic.fullnameLabel.text = post.nutritionPostUserName
                    
                    cellPic.urlTextView.text = post.nutritionPostUrlLink
                //}
                    cellPic.optionsButton.tag = indexPath.row
                    
                    if accountType == "Player" {
                        cellPic.optionsButton.isHidden = true
                    }
                    
                     return cellPic
                    
                } else if post.nutritionPostType == "picture" {
                    
                    cellPic.avaImageView.image = self.avas[indexPath.row]
                    cellPic.pictureImageView.image = self.pictures[indexPath.row]
                    
                    cellPic.postTextLabel.numberOfLines = 0
                    cellPic.postTextLabel.text = post.nutritionText
                    
                    //DispatchQueue.main.async {
                        
                        
                    cellPic.playImageView.isHidden = true
                                
                    cellPic.dateLabel.text = self.postDatesArray[indexPath.row]
                    cellPic.delegate = self
                    cellPic.indexPath = indexPath
                    cellPic.fullnameLabel.text = post.nutritionPostUserName
                    
                    cellPic.urlTextView.text = post.nutritionPostUrlLink
                    //}
                    cellPic.optionsButton.tag = indexPath.row
                    
                    if accountType == "Player" {
                        cellPic.optionsButton.isHidden = true
                    }
                    
                    return cellPic
                    
                } else {
                    let cellNoPic = tableView.dequeueReusableCell(withIdentifier: "CoachNoPicCell", for: indexPath) as! CoachNoPicCell
                    
                    cellNoPic.postTextLabel.numberOfLines = 0
                    cellNoPic.postTextLabel.text = post.nutritionText
                    
                    //DispatchQueue.main.async {
                        
                    cellNoPic.avaImageView.image = self.avas[indexPath.row]
                    
                    cellNoPic.dateLabel.text = self.postDatesArray[indexPath.row]
                    
                    cellNoPic.fullnameLabel.text = post.nutritionPostUserName

                    cellNoPic.urlTextView.text = post.nutritionPostUrlLink
                //}
                    cellNoPic.optionsButton.tag = indexPath.row
                    
                    if accountType == "Player" {
                        cellNoPic.optionsButton.isHidden = true
                    }
                    
                     return cellNoPic
                }
            }
                 
            return cellPic
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
            self.helper.imageFromData(pictureData: post.nutritionPicture) { (pictureImage) in

                if pictureImage != nil {
                    let photos = IDMPhoto.photos(withImages: [pictureImage as Any])
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
