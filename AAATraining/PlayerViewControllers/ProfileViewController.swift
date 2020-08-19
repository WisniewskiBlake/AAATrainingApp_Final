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

class ProfileViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, ImagePickerDelegate {
    
    

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var heightTextLabel: UILabel!
    @IBOutlet weak var positionTextLabel: UILabel!
    @IBOutlet weak var weightTextLabel: UILabel!
    @IBOutlet weak var numberTextLabel: UILabel!
    
    @IBOutlet weak var baseLineButton: UIButton!
    @IBOutlet weak var nutritionButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    
    
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
    var liked = [Int]()
    
    // color obj
    let likeColor = UIColor(red: 28/255, green: 165/255, blue: 252/255, alpha: 1)
    
    // friends obj
    var myFriends = [NSDictionary?]()
    var myFriends_avas = [UIImage]()
    
    var userBeingViewed = FUser()
    var user = FUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cornerRadius(for: baseLineButton)
        cornerRadius(for: nutritionButton)
        
       // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadUser), name: NSNotification.Name(rawValue: "updateStats"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadUserForGuest), name: NSNotification.Name(rawValue: "updateStatsAsGuest"), object: nil)

        configure_avaImageView()
        if FUser.currentUser()?.accountType == "player" {
            moreButton.isHidden = false
            loadUser()
        } else {
            moreButton.isHidden = true
            loadUserForGuest()
            
        }
        
    }
    
    // executed after aligning the objects
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //configure_nutritionButton(btn: nutritionButton)
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        
       let navigation = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "statsNav") as! UINavigationController
        let statsVC = navigation.viewControllers.first as! StatsVC
        //statsVC.modalPresentationStyle = .automatic
        statsVC.userBeingViewed = userBeingViewed
    
       self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
       
//       self.navigationController?.pushViewController(statsVC, animated: true)
       self.present(navigation, animated: true, completion: nil)
        
    }
    

    @IBAction func baseLineButtonClicked(_ sender: Any) {
        let navigation = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "baselineNav") as! UINavigationController
        let newBaselineVC = navigation.viewControllers.first as! PlayerBaselineVC
        newBaselineVC.userBeingViewed = userBeingViewed
        
        self.present(navigation, animated: true, completion: nil)
   //     self.navigationController?.pushViewController(newGroupVC, animated: true)
    }
    
    @IBAction func nutritionButtonClicked(_ sender: Any) {
        
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
        
         if coverPath != "" {
             helper.imageFromData(pictureData: coverPath) { (coverImage) in
                 
                 if coverImage != nil {
                     coverImageView.image = coverImage!
                     isCover = true
                 }
             }
         } else {
             coverImageView.image = UIImage(named: "aaaCoverLogo.png")
             isCover = false
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
        
        // assigning vars which we accessed from global var, to fullnameLabel
        fullnameLabel.text = "\((firstName).capitalized) \((lastName).capitalized)"
        heightTextLabel.text = "\((height).capitalized)" + "in."
        weightTextLabel.text = "\((weight).capitalized)" + "lbs."
        positionTextLabel.text = "\((position).capitalized)"
        numberTextLabel.text = "\((number).capitalized)"
        
    }
    
    // MARK: - Load User
    // loads all user related information to be shown in the header
   @objc func loadUser() {
        let helper = Helper()
        var query: Query!
    
        query = reference(.User).whereField(kOBJECTID, isEqualTo: FUser.currentId())
    
        query.getDocuments { (snapshot, error) in
            self.user = FUser()
            
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
                    
                    
                    helper.imageFromData(pictureData: userCurr.cover) { (coverImage) in
        
                        if coverImage != nil {
                            self.coverImageView.image = coverImage!
                            self.isCover = true
                        }
                    }
                    helper.imageFromData(pictureData: userCurr.ava) { (avatarImage) in
        
                       if avatarImage != nil {
                            self.avaImageView.image = avatarImage!
                            self.isAva = true
                       }
                   }
                    self.fullnameLabel.text = "\(String(describing: (userCurr.firstname).capitalized)) \((userCurr.lastname).capitalized)"
                    self.heightTextLabel.text = "\((userCurr.height).capitalized)" + "in."
                    self.weightTextLabel.text = "\((userCurr.weight).capitalized)" + "lbs."
                    self.positionTextLabel.text = "\((userCurr.position).capitalized)"
                    self.numberTextLabel.text = "\((userCurr.number).capitalized)"
                                    
                }
                
            
            }
        
    }
    
    
    
//        let user = FUser.currentUser()
//
//        guard let firstName = user?.firstname, let lastName = user?.lastname, let avaPath = user?.ava, let coverPath = user?.cover, let height = user?.height, let weight = user?.weight, let position = user?.position, let number = user?.number else {
//
//               return
//        }
//        if coverPath != "" {
//            helper.imageFromData(pictureData: coverPath) { (coverImage) in
//
//                if coverImage != nil {
//                    coverImageView.image = coverImage!
//                    isCover = true
//                }
//            }
//        } else {
//            coverImageView.image = UIImage(named: "aaaCoverLogo.png")
//            isCover = false
//        }
//
//       // check in the front end is there any picture in the ImageView laoded from the server (is there a real html path / link to the image)
//       if avaPath != "" {
//           helper.imageFromData(pictureData: avaPath) { (avatarImage) in
//
//               if avatarImage != nil {
//                   avaImageView.image = avatarImage!
//                   isAva = true
//               }
//           }
//       } else{
//           avaImageView.image = UIImage(named: "user.png")
//           isAva = false
//       }
//
//       // assigning vars which we accessed from global var, to fullnameLabel
//       fullnameLabel.text = "\((firstName).capitalized) \((lastName).capitalized)"
//       heightTextLabel.text = "\((height).capitalized)" + "in."
//       weightTextLabel.text = "\((weight).capitalized)" + "lbs."
//       positionTextLabel.text = "\((position).capitalized)"
//       numberTextLabel.text = "\((number).capitalized)"
       
   }
    
    
    @IBAction func avaImageView_tapped(_ sender: Any) {
        showIconOptions()
    }
    
    func configure_nutritionButton(btn: UIButton) {
        // creating constant named 'border' of type layer which acts as a border frame
        let border = CALayer()
        border.borderColor = #colorLiteral(red: 0.01220451668, green: 0.2841129601, blue: 0.7098029256, alpha: 1)
        border.borderWidth = 2
        border.frame = CGRect(x: 0, y: 0, width: btn.frame.width, height: btn.frame.height)
        
        // assign border to the obj (button)
        btn.layer.addSublayer(border)
        
        
        // rounded corner
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        
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

    
    func showIconOptions() {

       let optionMenu = UIAlertController(title: "Choose Profile Picture", message: nil, preferredStyle: .actionSheet)

       let takePhotoActio = UIAlertAction(title: "Choose Photo", style: .default) { (alert) in

           let imagePicker = ImagePickerController()
           imagePicker.delegate = self
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
    
    
   func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
       self.dismiss(animated: true, completion: nil)
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
                  
                  
              }
              
              self.dismiss(animated: true, completion: nil)
   }
   
   func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
       self.dismiss(animated: true, completion: nil)
   }
    
    
    
    @IBAction func moreButton_clicked(_ sender: Any) {
        // creating action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
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
        sheet.addAction(logout)
        sheet.addAction(cancel)
        
        // show action sheet
        present(sheet, animated: true, completion: nil)
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
