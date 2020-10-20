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
import Floaty

class FeedVC_Coach: UITableViewController, CoachPicCellDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
        
    var allPosts: [Post] = []
    var generalPosts: [Post] = []
    var fitnessPosts: [Post] = []
    var postsToShow: [Post] = []
    
    var allUsers: [FUser] = []
    
    var recentListener: ListenerRegistration!
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var teamImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var teamFeedTextLabel: UILabel!
    @IBOutlet weak var membersTextLabel: UILabel!
    
    @IBOutlet weak var moreImageView: UIImageView!

    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    var avas = [UIImage]()
    var pictures = [UIImage]()
    var postDatesArray: [String] = []
    
    var generalAvas = [UIImage]()
    var generalPictures = [UIImage]()
    var generalPostDatesArray: [String] = []
    
    var fitnessAvas = [UIImage]()
    var fitnessPictures = [UIImage]()
    var fitnessPostDatesArray: [String] = []

    var isLoading = false
    var emptyLabelOne = UILabel()
    var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "", teamType: "", teamMemberCount: "", teamMemberAccountTypes: [""])
    let helper = Helper()
    let currentDateFormater = Helper().dateFormatter()
    
    let moreTapGestureRecognizer = UITapGestureRecognizer()
    let postTapGestureRecognizer = UITapGestureRecognizer()
    let teamImageTapGestureRecognizer = UITapGestureRecognizer()
    
    var filterString: String = ""
    
    @IBOutlet weak var feedHeader: UIView!
        
    var imageview = UIImageView()
    
    //var floaty = Floaty()
    var actionButton = JJFloatingActionButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMembers()
//        NotificationCenter.default.addObserver(self, selector: #selector(self.loadPosts(_:)), name: NSNotification.Name(rawValue: "createPost"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "createPost"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "changeProPic"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "uploadImage"), object: nil)
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadPosts), name: NSNotification.Name(rawValue: "deletePost"), object: nil)
        
        moreTapGestureRecognizer.addTarget(self, action: #selector(self.moreImageViewClicked))
        moreImageView.isUserInteractionEnabled = true
        moreImageView.addGestureRecognizer(moreTapGestureRecognizer)
        
        teamImageTapGestureRecognizer.addTarget(self, action: #selector(self.teamImageViewClicked))
        teamImageView.isUserInteractionEnabled = true
        teamImageView.addGestureRecognizer(teamImageTapGestureRecognizer)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)

        emptyLabelOne = UILabel(frame: CGRect(x: 0, y: -150, width: view.bounds.size.width, height: view.bounds.size.height))

        feedHeader.layer.cornerRadius = CGFloat(25.0)

        feedHeader.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
       
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
    
    func configureFAB() {
        //actionButton = JJFloatingActionButton(frame: CGRect(x: (self.tableView.bounds.size.width) * 0.78, y: (self.tabBarController?.tabBar.frame.origin.y)! * 0.83, width: 60, height: 60))
        actionButton = JJFloatingActionButton()
        actionButton.addItem(title: "General Post", image: UIImage(named: "create")?.withRenderingMode(.alwaysTemplate)) { item in
            
            self.actionButton.close()
            let postScreen = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostVC") as! PostVC
            postScreen.postFeedType = "General"
            let postNav = UINavigationController(rootViewController: postScreen)
            self.present(postNav, animated: true, completion: nil)
            self.actionButton.close()
           
        }
        actionButton.addItem(title: "Fitness Post", image: UIImage(named: "fitness24")?.withRenderingMode(.alwaysTemplate)) { item in
            
            self.actionButton.close()
            let postScreen = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PostVC") as! PostVC
            postScreen.postFeedType = "Fitness"
            let postNav = UINavigationController(rootViewController: postScreen)
            self.present(postNav, animated: true, completion: nil)
            self.actionButton.close()
        }
        actionButton.addItem(title: "Create Chat", image: UIImage(named: "chat3")?.withRenderingMode(.alwaysTemplate)) { item in
            
            let contactsVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "contactsView") as! ContactsVC_Coach
            let navigation = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addMembersNav") as! UINavigationController
            contactsVC.isGroup = true
         
            
            self.present(navigation, animated: true, completion: nil)
           self.actionButton.close()
        }
        actionButton.addItem(title: "Create Event", image: UIImage(named: "date")?.withRenderingMode(.alwaysTemplate)) { item in
            
            self.actionButton.close()
            if let eventCoach : Event_Coach = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Event_Coach") as? Event_Coach
            {
                eventCoach.accountType = "Coach"
                eventCoach.hidesBottomBarWhenPushed = true
                eventCoach.updateNeeded = false
                //self.navigationController?.setNavigationBarHidden(true, animated: true)
                eventCoach.modalPresentationStyle = .overCurrentContext
                self.present(eventCoach, animated: true, completion: nil)
                self.actionButton.close()
            }
        }
        
        for item in actionButton.items {
            item.buttonImageColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)!
        }

//        actionButton.overlayView.backgroundColor = UIColor(hue: 0.31, saturation: 0.37, brightness: 0.10, alpha: 0.30)
//        actionButton.overlayView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        actionButton.overlayView.backgroundColor = UIColor(white: 0, alpha: 0.65)
        actionButton.handleSingleActionDirectly = false
//        actionButton.itemAnimationConfiguration = .circularSlideIn(withRadius: 120)
//        actionButton.buttonAnimationConfiguration = .rotation(toAngle: .pi * 3 / 4)
        
        actionButton.buttonAnimationConfiguration.opening.duration = 0.8
        actionButton.buttonAnimationConfiguration.closing.duration = 0.6
        actionButton.layer.shadowColor = UIColor.black.cgColor
        actionButton.layer.shadowOffset = CGSize(width: 1, height: 2)
        actionButton.layer.shadowOpacity = Float(0.5)
        actionButton.layer.shadowRadius = CGFloat(3)

        actionButton.buttonColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)!
        
    }
    
    @objc func floatingActionButtonDidOpen(_ button: JJFloatingActionButton) {
        print(actionButton.overlayView.frame.origin.y)
        //actionButton.buttonState = .open
        
    }
    
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureFAB()
        actionButton.display(inViewController: self)
        //self.tableView.addSubview(actionButton)
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        if #available(iOS 11.0, *) {
            actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        } else {
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
            actionButton.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -16).isActive = true
        }
        
        do {
            let gif = try UIImage(gifName: "loaderFinal.gif")
            imageview = UIImageView(gifImage: gif, loopCount: -1) // Will loop 3 times
            imageview.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(imageview)
            let widthConstraint = NSLayoutConstraint(item: imageview, attribute: .width, relatedBy: .equal,
                                                     toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 150)

            let heightConstraint = NSLayoutConstraint(item: imageview, attribute: .height, relatedBy: .equal,
                                                      toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 150)

            let xConstraint = NSLayoutConstraint(item: imageview, attribute: .centerX, relatedBy: .equal, toItem: self.tableView, attribute: .centerX, multiplier: 1, constant: 0)

            let yConstraint = NSLayoutConstraint(item: imageview, attribute: .centerY, relatedBy: .equal, toItem: self.tableView, attribute: .centerY, multiplier: 1, constant: 0)

            NSLayoutConstraint.activate([widthConstraint, heightConstraint, xConstraint, yConstraint])
        } catch {
            print(error)
        }
        filterSegmentedControl.selectedSegmentIndex = 0
        self.imageview.startAnimatingGif()
        filterString = ""
        loadPosts()
        getMembers()
        
        configureUI()
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableView.tableFooterView = view
        
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        
        //filterSegmentedControl.borderColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
//        teamFeedTextLabel.text = "Team Feed"
//        teamFeedTextLabel.font = UIFont(name: "Spantaran", size: 27)!
//        teamNameLabel.font = UIFont(name: "PROGRESSPERSONALUSE", size: 18)!
        
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
//        self.navigationController?.view.addSubview(self.titleView)
//        self.navigationController?.navigationBar.layer.zPosition = 0;
        
        currentDateFormater.dateFormat = "MM/dd/YYYY"
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func getMembers() {
        
        let query = reference(.Team).whereField(kTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID)
        query.getDocuments { (snapshot, error) in
            
            if error != nil {
                print(error!.localizedDescription)
                self.imageview.removeFromSuperview()
             self.helper.showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                 
                return
            }
            
            guard let snapshot = snapshot else {
             self.helper.showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
             self.isLoading = false
                self.imageview.removeFromSuperview(); return
            }
            
            if !snapshot.isEmpty {
                
                for userDictionary in snapshot.documents {
                    
                    let userDictionary = userDictionary.data() as NSDictionary
                    let team = Team(_dictionary: userDictionary)
                    self.membersTextLabel.text = team.teamMemberCount + " Team Members"
                }
            }
            self.imageview.removeFromSuperview()
        }
        self.imageview.removeFromSuperview()
    }
    
    @objc func handleRefresh() {
//        if filterString == "" {
//            loadPosts(filter: "")
//        } else if filterString == "General" {
//            loadPosts(filter: "General")
//        } else if filterString == "Fitness" {
//            loadPosts(filter: "Fitness")
//        }
        loadPosts()
        self.refreshControl?.endRefreshing()
    }
    
    @IBAction func filterSegmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filterString = ""
            loadPosts()
            
        case 1:
            filterString = "General"
            loadPosts()
        case 2:
            filterString = "Fitness"
            loadPosts()
        default:
            return
        }
    }

    // MARK: - Load Posts
    @objc func loadPosts() {

        recentListener = reference(.Post).whereField(kPOSTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID as Any).order(by: kPOSTDATE, descending: true).limit(to: 100).addSnapshotListener({ (snapshot, error) in

            self.allPosts = []
            self.generalPosts = []
            self.postsToShow = []
            self.fitnessPosts = []
            
            self.avas = []
            self.pictures = []
            self.postDatesArray = []
            
            self.generalAvas = []
            self.generalPictures = []
            self.generalPostDatesArray = []
            
            self.fitnessAvas = []
            self.fitnessPictures = []
            self.fitnessPostDatesArray = []

            if error != nil {
                print(error!.localizedDescription)
                self.imageview.removeFromSuperview()
                self.tableView.reloadData()
                return
            }
                   guard let snapshot = snapshot else { self.imageview.removeFromSuperview(); return }

                   if !snapshot.isEmpty {
                       for userDictionary in snapshot.documents {
                           let userDictionary = userDictionary.data() as NSDictionary

                            let post = Post(_dictionary: userDictionary)
                            self.allPosts.append(post)
                        
                            if post.postFeedType == "General" {
                                self.generalPosts.append(post)
                                self.helper.imageFromData(pictureData: post.postUserAva) { (avatarImage) in
                                    if avatarImage != nil {
                                        self.generalAvas.append(avatarImage!.circleMasked!)
                                    }
                                }
                                if post.picture != "" {
                                    self.helper.imageFromData(pictureData: post.picture) { (pictureImage) in
                                        if pictureImage != nil {
                                            self.generalPictures.append(pictureImage!)
                                        }
                                    }
                                } else if post.video != "" {
                                    self.helper.imageFromData(pictureData: post.picture) { (pictureImage) in
                                        if pictureImage != nil {
                                            self.generalPictures.append(pictureImage!)
                                        }
                                    }
                                } else {
                                    self.generalPictures.append(UIImage())
                                }

                                let postDate = self.helper.dateFormatter().date(from: post.date)
                                self.generalPostDatesArray.append(self.currentDateFormater.string(from: postDate!))
                                
                            } else if post.postFeedType == "Fitness" {
                                self.fitnessPosts.append(post)
                                self.helper.imageFromData(pictureData: post.postUserAva) { (avatarImage) in
                                    if avatarImage != nil {
                                        self.fitnessAvas.append(avatarImage!.circleMasked!)
                                    }
                                }
                                if post.picture != "" {
                                    self.helper.imageFromData(pictureData: post.picture) { (pictureImage) in
                                        if pictureImage != nil {
                                            self.fitnessPictures.append(pictureImage!)
                                        }
                                    }
                                } else if post.video != "" {
                                    self.helper.imageFromData(pictureData: post.picture) { (pictureImage) in
                                        if pictureImage != nil {
                                            self.fitnessPictures.append(pictureImage!)
                                        }
                                    }
                                } else {
                                    self.fitnessPictures.append(UIImage())
                                }

                                let postDate = self.helper.dateFormatter().date(from: post.date)
                                self.fitnessPostDatesArray.append(self.currentDateFormater.string(from: postDate!))
                                
                            }
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

               })
    }
    
//    @objc func loadPosts(filter: String) {
//        var query: Query!
//
//       switch filter {
//        case "":
//            query = reference(.Post).whereField(kPOSTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID as Any).order(by: kPOSTDATE, descending: true).limit(to: 100)
//       case ("General"):
//           query = reference(.Post).whereField(kPOSTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID as Any).whereField(kPOSTFEEDTYPE, isEqualTo: "General").order(by: kPOSTDATE, descending: true).limit(to: 100)
//        case ("Fitness"):
//            query = reference(.Post).whereField(kPOSTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID as Any).whereField(kPOSTFEEDTYPE, isEqualTo: "Fitness").order(by: kPOSTDATE, descending: true).limit(to: 100)
//       default:
//           query = reference(.Post).whereField(kPOSTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID as Any).order(by: kPOSTDATE, descending: true).limit(to: 100)
//       }
//
//           query.getDocuments { (snapshot, error) in
//
//            self.allPosts = []
//            self.avas = []
//            self.pictures = []
//            self.postDatesArray = []
//            self.generalPosts = []
//            self.postsToShow = []
//            self.fitnessPosts = []
//
//            if error != nil {
//                print(error!.localizedDescription)
//                self.imageview.removeFromSuperview()
//                self.tableView.reloadData()
//                return
//            }
//
//            guard let snapshot = snapshot else { self.imageview.removeFromSuperview(); return }
//
//               if !snapshot.isEmpty {
//
//                   for postDictionary in snapshot.documents {
//
//                    let postDictionary = postDictionary.data() as NSDictionary
//
//                     let post = Post(_dictionary: postDictionary)
//                     self.allPosts.append(post)
//                }
//
//
//                   self.tableView.reloadData()
//               }
//
//               self.tableView.reloadData()
//
//           }
//    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return allPosts.count
        switch self.filterString {
           case "":
            if allPosts.count == 0 {
                emptyLabelOne.text = "No posts to show!"
                emptyLabelOne.textAlignment = NSTextAlignment.center
                emptyLabelOne.font = UIFont(name: "Helvetica Neue", size: 15)
                emptyLabelOne.textColor = UIColor.lightGray
                self.tableView.tableFooterView!.addSubview(emptyLabelOne)
                return 0
            } else {
                emptyLabelOne.text = ""
                emptyLabelOne.removeFromSuperview()
                
                return allPosts.count
            }

          case ("General"):
            if generalPosts.count == 0 {
                emptyLabelOne.text = "No posts to show!"
                emptyLabelOne.textAlignment = NSTextAlignment.center
                emptyLabelOne.font = UIFont(name: "Helvetica Neue", size: 15)
                emptyLabelOne.textColor = UIColor.lightGray
                self.tableView.tableFooterView!.addSubview(emptyLabelOne)
                return 0
            } else {
                emptyLabelOne.text = ""
                emptyLabelOne.removeFromSuperview()
                
                return generalPosts.count
            }

           case ("Fitness"):
            if fitnessPosts.count == 0 {
                emptyLabelOne.text = "No posts to show!"
                emptyLabelOne.textAlignment = NSTextAlignment.center
                emptyLabelOne.font = UIFont(name: "Helvetica Neue", size: 15)
                emptyLabelOne.textColor = UIColor.lightGray
                self.tableView.tableFooterView!.addSubview(emptyLabelOne)
                return 0
            } else {
                emptyLabelOne.text = ""
                emptyLabelOne.removeFromSuperview()
                
                return fitnessPosts.count
            }

          default:
            if allPosts.count == 0 {
                emptyLabelOne.text = "No posts to show!"
                emptyLabelOne.textAlignment = NSTextAlignment.center
                emptyLabelOne.font = UIFont(name: "Helvetica Neue", size: 15)
                emptyLabelOne.textColor = UIColor.lightGray
                self.tableView.tableFooterView!.addSubview(emptyLabelOne)
                return 0
            } else {
                emptyLabelOne.text = ""
                emptyLabelOne.removeFromSuperview()
                
                return allPosts.count
            }
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
        var postsToShow: [Post] = []
        var avasToShow = [UIImage]()
        var picturesToShow = [UIImage]()
        var datesToShow: [String] = []
        if(filterString == "") {
            postsToShow = allPosts
            avasToShow = avas
            picturesToShow = pictures
            datesToShow = postDatesArray
        } else if(filterString == "General") {
            postsToShow = generalPosts
            avasToShow = generalAvas
            picturesToShow = generalPictures
            datesToShow = generalPostDatesArray
        } else if(filterString == "Fitness") {
            postsToShow = fitnessPosts
            avasToShow = fitnessAvas
            picturesToShow = fitnessPictures
            datesToShow = fitnessPostDatesArray
        }
        
        let cellPic = tableView.dequeueReusableCell(withIdentifier: "CoachPicCell", for: indexPath) as! CoachPicCell

        
        if postsToShow.count > 0 {
            
            post = postsToShow[indexPath.row]

            if post.postType == "video" {
                
                cellPic.avaImageView.image = avasToShow[indexPath.row]
                cellPic.pictureImageView.image = picturesToShow[indexPath.row]
                cellPic.playImageView.isHidden = false
                
                cellPic.postTextLabel.numberOfLines = 0
                cellPic.postTextLabel.text = post.text
                //DispatchQueue.main.async {
                    cellPic.dateLabel.text = datesToShow[indexPath.row]
                    
                    
                    cellPic.delegate = self
                    cellPic.indexPath = indexPath
                    cellPic.fullnameLabel.text = post.postUserName
                    
                    cellPic.urlTextView.text = post.postUrlLink
                //}

                 return cellPic
                
            } else if post.postType == "picture" {
                let cellPic = tableView.dequeueReusableCell(withIdentifier: "CoachPicCell", for: indexPath) as! CoachPicCell
                
                cellPic.avaImageView.image = avasToShow[indexPath.row]
                cellPic.pictureImageView.image = picturesToShow[indexPath.row]
                
                cellPic.postTextLabel.numberOfLines = 0
                cellPic.postTextLabel.text = post.text
                
                //DispatchQueue.main.async {
                    
                    
                    cellPic.playImageView.isHidden = true
                                
                    cellPic.dateLabel.text = datesToShow[indexPath.row]
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
                    
                    cellNoPic.avaImageView.image = avasToShow[indexPath.row]
                    
                    cellNoPic.dateLabel.text = datesToShow[indexPath.row]
                    
                    cellNoPic.fullnameLabel.text = post.postUserName

                    cellNoPic.urlTextView.text = post.postUrlLink
                //}
                                 
                 return cellNoPic
            }
        }
                
        
        
        return cellPic
        
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

extension UIDevice {
    var hasNotch: Bool
    {
        if #available(iOS 11.0, *)
        {
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 0
        } else
        {
            // Fallback on earlier versions
            return false
        }
    }
}

extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        guard let window = UIApplication.shared.keyWindow else {
            return super.sizeThatFits(size)
        }
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = window.safeAreaInsets.bottom + 40
        return sizeThatFits
    }
}



//        if UIDevice.current.hasNotch
//        {
//            floaty = Floaty(frame: CGRect(x: (self.tableView.bounds.size.width) * 0.78, y: (self.tabBarController?.tabBar.frame.origin.y)! * 0.83, width: 60, height: 60))
//            //floaty.translatesAutoresizingMaskIntoConstraints = false
//        }
//        else
//        {
//            floaty = Floaty(frame: CGRect(x: (self.tableView.bounds.size.width) * 0.78, y: (self.tabBarController?.tabBar.frame.origin.y)! * 0.86, width: 60, height: 60))
//        }



//
