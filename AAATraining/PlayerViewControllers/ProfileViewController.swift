//
//  ProfileViewController.swift
//  AAATraining
//
//  Created by Margaret Dwan on 6/23/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import MediaPlayer
import ImagePicker
import Firebase
import FirebaseFirestore
import ProgressHUD

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        
    }
    
    
    

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var heightTextLabel: UILabel!
    @IBOutlet weak var positionTextLabel: UILabel!
    @IBOutlet weak var weightTextLabel: UILabel!
    @IBOutlet weak var numberTextLabel: UILabel!
    
    @IBOutlet weak var baselineView: UIView!
    //@IBOutlet weak var nutritionView: UIView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var logoutView: UIView!
    
    let baselineTapGestureRecognizer = UITapGestureRecognizer()
    let nutritionTapGestureRecognizer = UITapGestureRecognizer()
    let editTapGestureRecognizer = UITapGestureRecognizer()
    let logoutTapGestureRecognizer = UITapGestureRecognizer()
    let avaTapGestureRecognizer = UITapGestureRecognizer()
    
    var profileIcon: UIImage?
    var coverIcon: UIImage?
    
    // code obj (to build logic of distinguishing tapped / shown Cover / Ava)
    var isCover = false
    var isAva = false
    var imageViewTapped = ""
    
    // posts obj
    var posts = [NSDictionary?]()
    var avas = [UIImage]()
    var pictures = [UIImage]()
    var skip = 0
    var limit = 10
    var isLoading = false

    var userBeingViewed = FUser()
    var user = FUser()
    let helper = Helper()
    var playerStatID: String = ""
    var isViewedFromRoster = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // add observers for notifications
//        NotificationCenter.default.addObserver(self, selector: #selector(loadUser), name: NSNotification.Name(rawValue: "updateStats"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(loadUserForGuest), name: NSNotification.Name(rawValue: "updateStatsAsGuest"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadStats), name: NSNotification.Name(rawValue: "updateStats"), object: nil)
        baselineTapGestureRecognizer.addTarget(self, action: #selector(self.baselineViewClicked))
        baselineView.isUserInteractionEnabled = true
        baselineView.addGestureRecognizer(baselineTapGestureRecognizer)
        
        nutritionTapGestureRecognizer.addTarget(self, action: #selector(self.nutritionViewClicked))
//        nutritionView.isUserInteractionEnabled = true
//        nutritionView.addGestureRecognizer(nutritionTapGestureRecognizer)
        
        editTapGestureRecognizer.addTarget(self, action: #selector(self.editViewClicked))
        editView.isUserInteractionEnabled = true
        editView.addGestureRecognizer(editTapGestureRecognizer)
        
        logoutTapGestureRecognizer.addTarget(self, action: #selector(self.logoutViewClicked))
        logoutView.isUserInteractionEnabled = true
        logoutView.addGestureRecognizer(logoutTapGestureRecognizer)
        
        avaTapGestureRecognizer.addTarget(self, action: #selector(self.avaViewClicked))
        avaImageView.isUserInteractionEnabled = true
        avaImageView.addGestureRecognizer(avaTapGestureRecognizer)
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configure_avaImageView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hidesBottomBarWhenPushed = true
        if FUser.currentUser()?.accountType == "Player" {
            logoutView.isHidden = false
            loadStats()
            loadUser()
        } else {
            logoutView.isHidden = true
            loadStats()
            loadUserForGuest()
        }
    }
    

    
    
    
    @objc func loadUserForGuest() {
        let helper = Helper()
     
        let firstName = userBeingViewed.firstname
        let lastName = userBeingViewed.lastname
        let avaPath = userBeingViewed.ava
        let coverPath = userBeingViewed.cover
        let height = userBeingViewed.height
        let weight = userBeingViewed.weight
        let position = userBeingViewed.position
        let number = userBeingViewed.number
        //self.playerStatID = userBeingViewed.objectId
        
        var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "", teamType: "", teamMemberCount: "", teamMemberAccountTypes: [])
         
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
     
        // check in the front end is there any picture in the ImageView laoded from the server (is there a real html path / link to the image)
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
//
        // assigning vars which we accessed from global var, to fullnameLabel
        fullnameLabel.text = "\((firstName).capitalized) \((lastName).capitalized)"
        
        
    }
    
    @objc func loadStats() {
        var query = reference(.PlayerStat).whereField(kPLAYERSTATUSERID, isEqualTo: FUser.currentId()).whereField(kPLAYERSTATTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID)
        if FUser.currentUser()?.accountType != "Player" {
            query = reference(.PlayerStat).whereField(kPLAYERSTATUSERID, isEqualTo: userBeingViewed.objectId).whereField(kPLAYERSTATTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID)
        }
        
        query.getDocuments { (snapshot, error) in

            if error != nil {
                print(error!.localizedDescription)
                self.helper.showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                return
            }

            guard let snapshot = snapshot else {
                self.helper.showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                return
            }

            if !snapshot.isEmpty {
                for statDictionary in snapshot.documents {

                    let statDictionary = statDictionary.data() as NSDictionary
                    let stats = PlayerStat(_dictionary: statDictionary)
                    
                    self.playerStatID = stats.playerStatID
                    self.positionTextLabel.text = stats.playerStatPosition
                    self.numberTextLabel.text = stats.playerStatNumber
                    if stats.playerStatHeight == "" {
                        self.heightTextLabel.text = ""
                    } else {
                        self.heightTextLabel.text = stats.playerStatHeight + "in."
                    }
                    if stats.playerStatWeight == "" {
                        self.weightTextLabel.text = ""
                    } else {
                        self.weightTextLabel.text = stats.playerStatWeight + "lb."
                    }
                }
            }
        }   
    }
    
    // MARK: - Load User
    // loads all user related information to be shown in the header
   @objc func loadUser() {
        let helper = Helper()
        var query: Query!
    var team = Team(teamID: "", teamName: "", teamLogo: "", teamMemberIDs: [], teamCity: "", teamState: "", teamColorOne: "", teamColorTwo: "", teamColorThree: "", teamType: "", teamMemberCount: "", teamMemberAccountTypes: [])
        
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
    
        query = reference(.User).whereField(kOBJECTID, isEqualTo: FUser.currentId())
    
        query.getDocuments { (snapshot, error) in
            self.user = FUser()
            self.userBeingViewed = FUser()
            
            if error != nil {
                print(error!.localizedDescription)
                
                return
            }
            
            guard let snapshot = snapshot else {
                return
            }
            
            if !snapshot.isEmpty {
                for userDoc in snapshot.documents {
                    let userDoc = userDoc.data() as NSDictionary
                    let userCurr = FUser(_dictionary: userDoc)
                    self.user = userCurr
                    self.userBeingViewed = userCurr
 
                    helper.imageFromData(pictureData: userCurr.ava) { (avatarImage) in
        
                       if avatarImage != nil {
                            self.avaImageView.image = avatarImage!
                            self.isAva = true
                       }
                   }
                    self.fullnameLabel.text = "\(String(describing: (userCurr.firstname).capitalized)) \((userCurr.lastname).capitalized)"
                    //self.playerStatID = userCurr.objectId
                }
            }
        }
    }
    
    @objc func baselineViewClicked() {
        let navigation = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "baselineNav") as! UINavigationController
        let newBaselineVC = navigation.viewControllers.first as! PlayerBaselineVC
        newBaselineVC.userBeingViewed = userBeingViewed
        
        self.present(navigation, animated: true, completion: nil)
    }
    
    @objc func nutritionViewClicked() {
        let navigationNutrition = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "nutritionNav") as! UINavigationController
         let nutritionVC = navigationNutrition.viewControllers.first as! NutritionFeedVC
        nutritionVC.accountType = FUser.currentUser()?.accountType
        
        self.present(navigationNutrition, animated: true, completion: nil)
    }
    
    @objc func editViewClicked() {
        let navigation = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "statsNav") as! UINavigationController
        let statsVC = navigation.viewControllers.first as! StatsVC
        
        statsVC.userBeingViewed = userBeingViewed
        statsVC.playerStatID = playerStatID
        
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

        self.present(navigation, animated: true, completion: nil)
    }
    
    @objc func logoutViewClicked() {
        
        if let vc =  UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingsNav") as? UINavigationController
        {
            vc.modalPresentationStyle = .fullScreen
            vc.navigationController?.navigationBar.tintColor = UIColor.black
            vc.navigationBar.tintColor = UIColor.black
            
            self.present(vc, animated: true, completion: nil)
        }
        

    }
    
    // make corners rounded for any views (objects)
    func cornerRadius(for view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
    }
    
    // add blank view to the left side of the TextField (it'll act as a blank gap)
    func padding(for textField: UITextField) {
        let blankView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        textField.leftView = blankView
        textField.leftViewMode = .always
    }

    
    @objc func avaViewClicked() {

        imageViewTapped = "cover"
        
        showActionSheet()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    // configuring the appearance of AvaImageView
    func configure_avaImageView() {
        
//        // creating layer that will be applied to avaImageView (layer - broders of ava)
        let border = CALayer()
        border.borderColor = UIColor.white.cgColor
        border.borderWidth = 5
        border.frame = CGRect(x: 0, y: 0, width: avaImageView.frame.width, height: avaImageView.frame.height)
        avaImageView.layer.addSublayer(border)
        
        // rounded corners
//        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
//        //avaImageView.layer.masksToBounds = true
//        avaImageView.clipsToBounds = true
        
        avaImageView.layer.cornerRadius = 10
        avaImageView.layer.masksToBounds = true
        avaImageView.clipsToBounds = true
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
            let picturePath = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            
                // assign selected image to AvaImageView
                self.avaImageView.image = picturePath
                
                // refresh global variable storing the user's profile pic
                let pictureData = image?.jpegData(compressionQuality: 0.4)!
                let avatar = pictureData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                
                //FUser.currentUser().ava = self.avaImageView.image
                
                updateCurrentUserInFirestore(withValues: [kAVATAR : avatar!]) { (success) in
                    //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changeProPic"), object: nil)
                }

            
            // completion handler, to communicate to the project that images has been selected (enable delete button)
            dismiss(animated: true) {
                if self.imageViewTapped == "cover" {
                    self.isCover = true
                } else if self.imageViewTapped == "ava" {
                    self.isAva = true
                }
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
