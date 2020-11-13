//
//  TeamRegisterVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/23/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase
import FirebaseFirestore
import ProgressHUD

class TeamTypeSelectionCellClass: UITableViewCell {
    
}

class TeamRegisterVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var teamNameText: UITextField!
    @IBOutlet weak var teamNameContinueButton: UIButton!

    @IBOutlet weak var locationContinueButton: UIButton!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var logoContinueButton: UIButton!
    
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var copyToClipButton: UIButton!
    
    @IBOutlet weak var haveAccountButton: UIButton!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emailView_width: NSLayoutConstraint!
    @IBOutlet weak var nameView_width: NSLayoutConstraint!
    @IBOutlet weak var passwordView_width: NSLayoutConstraint!
    @IBOutlet weak var coachPassword_width: NSLayoutConstraint!
    @IBOutlet weak var contentView_width: NSLayoutConstraint!

    @IBOutlet weak var teamCodeView: UIView!
    
    @IBOutlet weak var teamNameImage: UIImageView!
    @IBOutlet weak var teamSportImage: UIImageView!
    @IBOutlet weak var teamLogoImage: UIImageView!
    @IBOutlet weak var teamCodeImage: UIImageView!
    
    
    var dataSource = ["Archery", "Basketball", "Baseball", "Bowling", "Curling", "Cricket", "Cycling", "Diving", "Football", "Golf", "Gymnastics", "Hockey", "Kayaking", "Lacrosse", "MMA", "Martial Arts", "Rowing", "Rugby", "Running", "Skateboarding", "Skiing", "Snowboarding", "Soccer", "Softball", "Surfing", "Swimming", "Table Tennis", "Tennis", "Track", "Triathlon", "Volleyball", "Wakeboarding", "Weight Loss", "Wrestling", "Yoga", "Other"]
    var cellText = "Select Type..."
    var teamType = ""
    var oneSelected = false
    var cellTagArray: [[Int]] = []
        
    var isPictureSelected = false
    var isVideoSelected = true
    
    var picturePath: UIImage = UIImage()
    var pictureToUpload: String? = ""
    
    var teamLoginCode = ""
    var loginString = ""
    var randomInt = 0
    
    var teamColorOne: String?
    var teamColorTwo: String?
    var teamColorThree: String?
    
    var uiColorOne: UIColor?
    var uiColorTwo: UIColor?
    var uiColorThree: UIColor?
    
    var userAccountType = ""
    
    let helper = Helper()
    
    let logoImageTapGestureRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        configure_footerView()
        
        randomInt = Int.random(in: 1..<9)
        loginString = randomString(length: 2)
        
        teamLoginCode.append(contentsOf: loginString)
        teamLoginCode.append(contentsOf: String(randomInt))
        
        randomInt = Int.random(in: 1..<9)
        loginString = randomString(length: 2)
        
        teamLoginCode.append(contentsOf: loginString)
        teamLoginCode.append(contentsOf: String(randomInt))
        
        codeLabel.text = teamLoginCode
        
        bannerView.adUnitID = "ca-app-pub-8479238648739219/5317514555"
        //ca-app-pub-8479238648739219/5317514555
        //c8b13a0958c55302a0092a8fdabd1f7e
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
        
        logoImageTapGestureRecognizer.addTarget(self, action: #selector(self.logoImageViewClicked))
        logoImageView.isUserInteractionEnabled = true
        logoImageView.addGestureRecognizer(logoImageTapGestureRecognizer)
        
        teamNameImage.layer.cornerRadius = teamNameImage.frame.width / 2
        teamNameImage.clipsToBounds = true
        teamSportImage.layer.cornerRadius = teamSportImage.frame.width / 2
        teamSportImage.clipsToBounds = true
        teamLogoImage.layer.cornerRadius = teamLogoImage.frame.width / 2
        teamLogoImage.clipsToBounds = true
        teamCodeImage.layer.cornerRadius = teamCodeImage.frame.width / 2
        teamCodeImage.clipsToBounds = true
  
    }
    
    func configureUI() {
        contentView_width.constant = self.view.frame.width * 4
        coachPassword_width.constant = self.view.frame.width
        nameView_width.constant = self.view.frame.width
        emailView_width.constant = self.view.frame.width
        passwordView_width.constant = self.view.frame.width
        
        cornerRadius(for: teamNameText)
        cornerRadius(for: teamNameContinueButton)
        cornerRadius(for: locationContinueButton)
        cornerRadius(for: logoContinueButton)
        cornerRadius(for: finishButton)
        cornerRadius(for: copyToClipButton)
        
        padding(for: teamNameText)
        
        logoImageView.layer.cornerRadius = logoImageView.frame.width / 2
        logoImageView.clipsToBounds = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func logoImageViewClicked() {
        showActionSheet()
    }
   
    
    @IBAction func teamNameContinueClicked(_ sender: Any) {
        let position = CGPoint(x: self.view.frame.width, y: 0)
        scrollView.setContentOffset(position, animated: true)
        
        // show keyboard of next TextField
        if teamNameText.text!.isEmpty {
            teamNameText.becomeFirstResponder()
        } else if teamNameText.text!.isEmpty == false {
            teamNameText.resignFirstResponder()
        }
    }
    
    
    
    
    @IBAction func locationContinueClicked(_ sender: Any) {
        let position = CGPoint(x: self.view.frame.width * 2, y: 0)
        scrollView.setContentOffset(position, animated: true)
    }
    
    
    @IBAction func logoContinueClicked(_ sender: Any) {
        let position = CGPoint(x: self.view.frame.width * 3, y: 0)
        scrollView.setContentOffset(position, animated: true)
    }
    
    func getUserTeamAccTypes() {
        
    }
    
    @IBAction func finishContinueClicked(_ sender: Any) {
        
        let team = Team(teamID: teamLoginCode, teamName: teamNameText.text!, teamLogo: self.pictureToUpload!, teamMemberIDs: [FUser.currentId()], teamCity: "", teamState: "", teamColorOne: teamColorOne!, teamColorTwo: teamColorTwo!, teamColorThree: teamColorThree!, teamType: self.teamType, teamMemberCount: "1", teamMemberAccountTypes: [userAccountType.capitalizingFirstLetter()])
        
        team.saveTeam()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createdTeam"), object: nil)
        
        //potentially could use save user locally here, could also fix userTeamMemberCount bc thats just straight wrong
        var userTeamAccTypeArray: [String]? = []
        var userIsNewObserverArray: [String]? = []
        var userTeamNotificationsArray: [String]? = []
        
        fetchCurrentUserFromFirestore(userId: FUser.currentId(), completion: { (user) in

           if user != nil && user!.firstname != "" {
            //we have user, login
            userTeamAccTypeArray = user?.userTeamAccountTypes
            userTeamAccTypeArray!.append("Coach")
            
            userIsNewObserverArray = user?.userIsNewObserverArray
            
            userIsNewObserverArray!.append("No")
            
            userTeamNotificationsArray = user?.userTeamNotifications
            userTeamNotificationsArray!.append("Yes")
            
            updateUserInFirestore(objectID: FUser.currentId(), withValues: [kUSERTEAMIDS : FieldValue.arrayUnion([self.teamLoginCode]), kUSERTEAMACCOUNTTYPES : userTeamAccTypeArray, kUSERTEAMNAMES : FieldValue.arrayUnion([self.teamNameText.text!]), kUSERTEAMMEMBERS : FieldValue.arrayUnion([FUser.currentId()]), kUSERTEAMNOTIFICATIONS : userTeamNotificationsArray, kUSERISNEWOBSERVERARRAY : userIsNewObserverArray]) { (success) in
                self.goToApp()

            }
            
           } else {
            let helper = Helper()
                helper.showAlert(title: "Data Error", message: "Couldn't register, try again later.", in: self)
           }

        })
        
        

    }
    
    func goToLogin() {
        let helper = Helper()
        
        // go to TabBar
        helper.instantiateViewController(identifier: "LoginVC", animated: true, by: self, completion: nil)
    }
    
    @IBAction func copyToClipClicked(_ sender: Any) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = codeLabel.text
        self.helper.showAlert(title: "Copied!", message: "Team code copied to clipboard.", in: self)
    }
    
    
    func goToApp() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamSelectionVC") as? TeamSelectionVC
        {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
   
    
    
    
    // configuring the appearance of the footerView
    func configure_footerView() {
        // adding the line at the top of the footerView
        let topLine = CALayer()
        topLine.borderWidth = 1
        topLine.borderColor = UIColor.lightGray.cgColor
        topLine.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1)
        
        footerView.layer.addSublayer(topLine)
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
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        let helper = Helper()
        
        // logic for Email TextField
        if textField == teamNameText {

            if helper.isValid(name: teamNameText.text!) {
                teamNameContinueButton.isHidden = false
            }
            
        // logic for First Name or Last Name TextFields
        }

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // end editing - hide keyboards
        self.view.endEditing(false)
    }
    
    @IBAction func haveTeamClicked(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamSelectionVC") as? TeamSelectionVC
        {
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func randomString(length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    

    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        
        if cellTagArray.contains([indexPath.section, indexPath.row]) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if teamType == "" {
            tableView.deselectRow(at: indexPath, animated: true)
            
            teamType = dataSource[indexPath.row]
            
            let cell = tableView.cellForRow(at: indexPath)
            
            var locationArray: [Int] = []
            locationArray.append(indexPath.section)
            locationArray.append(indexPath.row)
            if cellTagArray.contains(locationArray) {
                let index = cellTagArray.firstIndex(of: locationArray)!
                cellTagArray.remove(at: index)
                
            } else {
                cellTagArray.append(locationArray)
                
            }
            
            if cell!.accessoryType == .checkmark {
                cell!.accessoryType = .none
                } else {
                cell!.accessoryType = .checkmark
            }
            
            
            locationContinueButton.isHidden = false
        } else if teamType == dataSource[indexPath.row] {
            tableView.deselectRow(at: indexPath, animated: true)
            
            teamType = dataSource[indexPath.row]
            
            let cell = tableView.cellForRow(at: indexPath)
            
            var locationArray: [Int] = []
            locationArray.append(indexPath.section)
            locationArray.append(indexPath.row)
            if cellTagArray.contains(locationArray) {
                let index = cellTagArray.firstIndex(of: locationArray)!
                cellTagArray.remove(at: index)
                
            } else {
                cellTagArray.append(locationArray)
                
            }
            
            if cell!.accessoryType == .checkmark {
                cell!.accessoryType = .none
                } else {
                cell!.accessoryType = .checkmark
            }
            
            teamType = ""
            locationContinueButton.isHidden = true
            
        } else {
            oneSelected = false
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
        
        image?.getColors(quality: UIImageColorsQuality(rawValue: CGFloat(100))!) { colors in
                     self.uiColorOne = colors?.background
                     self.uiColorTwo = colors?.primary
                     self.uiColorThree = colors?.detail
        
        
        
                   //detailLabel.textColor = colors.detail
                     self.teamColorOne = self.uiColorOne?.htmlRGBaColor
                     self.teamColorTwo = self.uiColorTwo?.htmlRGBaColor
                     self.teamColorThree = self.uiColorThree?.htmlRGBaColor
        
        
                 }
               
                // assign selected image to CoverImageView
                self.logoImageView.image = image
                
                let pictureData = image?.jpegData(compressionQuality: 0.4)!
        pictureToUpload = pictureData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                logoContinueButton.isHidden = false
            
            // completion handler, to communicate to the project that images has been selected (enable delete button)
            dismiss(animated: true) {
                
            }

    
        }

     
     func displayMedia(picture: UIImage?) {
         if let pic = picture {
             logoImageView.image = pic
             isVideoSelected = false
             isPictureSelected = true
             return
         }
     }
    
    @IBAction func selectImageButtonClicked(_ sender: Any) {
        print("tapped")
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            camera.PresentMultyCamera(target: self, canEdit: false)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            
            camera.PresentPhotoLibrary(target: self, canEdit: false)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        takePhotoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
        sharePhoto.setValue(UIImage(named: "picture"), forKey: "image")
        
        //optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    

    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
        didFailToReceiveAdWithError error: GADRequestError) {
      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
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
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
