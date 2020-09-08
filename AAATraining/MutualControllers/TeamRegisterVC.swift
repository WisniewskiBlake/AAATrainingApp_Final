//
//  TeamRegisterVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/23/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class TeamTypeSelectionCellClass: UITableViewCell {
    
}

class TeamRegisterVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var teamNameText: UITextField!
    @IBOutlet weak var teamNameContinueButton: UIButton!
    
//    @IBOutlet weak var cityText: UITextField!
//    @IBOutlet weak var stateText: UITextField!
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
    
    let helper = Helper()
    
    //var sceneDelegate = UIApplication.shared.delegate as! SceneDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView_width.constant = self.view.frame.width * 4
        coachPassword_width.constant = self.view.frame.width
        nameView_width.constant = self.view.frame.width
        emailView_width.constant = self.view.frame.width
        passwordView_width.constant = self.view.frame.width
        
        cornerRadius(for: teamNameText)
//        cornerRadius(for: cityText)
//        cornerRadius(for: stateText)
        
        cornerRadius(for: teamNameContinueButton)
        cornerRadius(for: locationContinueButton)
        cornerRadius(for: logoContinueButton)
        cornerRadius(for: finishButton)
        cornerRadius(for: copyToClipButton)
        
        padding(for: teamNameText)
//        padding(for: cityText)
//        padding(for: stateText)
        
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
        
        
        
        //tableView.register(TeamTypeSelectionCellClass.self, forCellReuseIdentifier: "TypeCell")
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
    
    @IBAction func finishContinueClicked(_ sender: Any) {
//        let avatar = getAvatar()
//        let coverIMG = cover?.jpegData(compressionQuality: 0.7)
//        let coverData = coverIMG!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        let team = Team(teamID: teamLoginCode, teamName: teamNameText.text!, teamLogo: self.pictureToUpload!, teamMemberIDs: [""], teamCity: "", teamState: "", teamColorOne: teamColorOne!, teamColorTwo: teamColorTwo!, teamColorThree: teamColorThree!, teamType: self.teamType)
        
        team.saveTeam()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createTeam"), object: nil)
        //sceneDelegate.tintColor = UIColor(hexString: team.teamColorOne)
        self.goToApp(teamToLoad: team)
        //self.goToLogin()

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
    
    
    func goToApp(teamToLoad: Team) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
        {
            vc.team = teamToLoad
            vc.teamID = teamToLoad.teamID
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                
        picturePath = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        
        picturePath.getColors(quality: UIImageColorsQuality(rawValue: CGFloat(100))!) { colors in
            self.uiColorOne = colors?.background
            self.uiColorTwo = colors?.primary
            self.uiColorThree = colors?.detail
            
            
            
          //detailLabel.textColor = colors.detail
            self.teamColorOne = self.uiColorOne?.htmlRGBaColor
            self.teamColorTwo = self.uiColorTwo?.htmlRGBaColor
            self.teamColorThree = self.uiColorThree?.htmlRGBaColor
            

        }
        
        let pictureData = picturePath.jpegData(compressionQuality: 0.4)!
        pictureToUpload = pictureData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        logoContinueButton.isHidden = false
        displayMedia(picture: picturePath)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func displayMedia(picture: UIImage?) {
        if let pic = picture {
            logoImageView.image = pic
            isVideoSelected = false
            isPictureSelected = true
            return
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
//        else if textField == cityText || textField == stateText {
//
//            // check fullname validation
//            if helper.isValid(name: cityText.text!) && helper.isValid(name: stateText.text!) {
//                locationContinueButton.isHidden = false
//            }
//
//        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // end editing - hide keyboards
        self.view.endEditing(false)
    }
    
    @IBAction func haveTeamClicked(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamLoginVC") as? TeamLoginVC
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
        
        if teamType != "" {
            
        }
        
        if oneSelected != true {
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
            
            locationContinueButton.isEnabled = cellTagArray.count == 1
            oneSelected == true
        } else {
            
        }
        
        

    }
    

    
    
    
}

