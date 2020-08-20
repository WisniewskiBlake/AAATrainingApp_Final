//
//  StatsVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 6/25/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class CellClass: UITableViewCell {
    
}

class StatsVC: UIViewController {

    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var statButton: UIButton!
    @IBOutlet weak var statTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var changesLabel: UILabel!
    
    let transparentView = UIView()
    let tableView = UITableView()
    var selectedButton = UIButton()
    var dataSource = [String]()
    var cellText = "Select Stat"
    
    var userBeingViewed = FUser()
    
    
    override func viewDidLoad() {
       super.viewDidLoad()
       tableView.delegate = self
       tableView.dataSource = self
       tableView.register(CellClass.self, forCellReuseIdentifier: "Cell")
        
        padding(for: statTextField)
        cornerRadius(for: statButton)
        
        
        configure_avaImageView()
        if FUser.currentUser()?.accountType == "player" {
            changesLabel.isHidden = false
            loadUser()
        } else {
            changesLabel.isHidden = true
            loadUserForGuest()
        }
        
    }
    
    @IBAction func textFieldDidChange(_ sender: Any) {
        if statTextField.text!.isEmpty == false && cellText != "Select Stat"  {
            saveButton.isEnabled = true
        }
    }
    
    // configures appearance of avaImageView
    func configure_avaImageView() {
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
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
    
    // loads all user related information to be shown in the header
    func loadUser() {
        let helper = Helper()
        let user = FUser.currentUser()
        // safe method of accessing user related information in glob var
        guard let firstName = user?.firstname, let lastName = user?.lastname, let avaPath = user?.ava else {
            return
        }
        // check in the front end is there any picture in the ImageView laoded from the server (is there a real html path / link to the image)
        if avaPath != "" {
            helper.imageFromData(pictureData: avaPath) { (avatarImage) in
                
                if avatarImage != nil {
                    avaImageView.image = avatarImage!
                    
                }
            }
        } else{
            avaImageView.image = UIImage(named: "user.png")
            
        }
        
        fullnameLabel.text = "\((firstName).capitalized) \((lastName).capitalized)"
                
    }
    
    // loads all user related information to be shown in the header
    func loadUserForGuest() {
        let helper = Helper()
        
        // safe method of accessing user related information in glob var
        let firstName = userBeingViewed.firstname
        let lastName = userBeingViewed.lastname
        let avaPath = userBeingViewed.ava
        // check in the front end is there any picture in the ImageView laoded from the server (is there a real html path / link to the image)
        if avaPath != "" {
            helper.imageFromData(pictureData: avaPath) { (avatarImage) in
                
                if avatarImage != nil {
                    avaImageView.image = avatarImage!
                    
                }
            }
        } else{
            avaImageView.image = UIImage(named: "user.png")
            
        }
        
        fullnameLabel.text = "\((firstName).capitalized) \((lastName).capitalized)"
                
    }
    
    @IBAction func saveButton_clicked(_ sender: Any) {
        if statTextField.text!.isEmpty == false  {
            if cellText == "Select Stat" {
                Helper().showAlert(title: "Error", message: "Please select a stat", in: self)
            } else if cellText == "Height" {
                if Helper().isValid(height: statTextField.text!) {
                    self.updateStats(stat: cellText.lowercased(), value: statTextField.text!)
                }
            } else if cellText == "Weight" {
                if Helper().isValid(weight: statTextField.text!) {
                    self.updateStats(stat: cellText.lowercased(), value: statTextField.text!)
                }
            } else if cellText == "Position" {
                if Helper().isValid(position: statTextField.text!) {
                    self.updateStats(stat: cellText.lowercased(), value: statTextField.text!)
                }
            } else if cellText == "Number" {
                if Helper().isValid(number: statTextField.text!) {
                    self.updateStats(stat: cellText.lowercased(), value: statTextField.text!)
                }
            }
        } else {
            Helper().showAlert(title: "Error", message: "Please fill out form", in: self)
        }
    }
    
    // updating bio by sending request to the server
    @objc func updateStats(stat: String, value: String) {
        if FUser.currentUser()?.accountType == "player" {
            updateCurrentUserInFirestore(withValues: [stat : value]) { (success) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateStats"), object: nil)
            }
        } else {
            updateUserInFirestore(objectID: userBeingViewed.objectId, withValues: [stat : value]) { (success) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateStatsAsGuest"), object: nil)
            }
        }
        
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    func addTransparentView(frames: CGRect) {
        let keyWindow = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
        
        transparentView.frame = keyWindow?.frame ?? self.view.frame
        self.view.addSubview(transparentView)
        
        tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(tableView)
        tableView.layer.cornerRadius = 5
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        transparentView.addGestureRecognizer(tapgesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.dataSource.count * 50))
        }, completion: nil)
    }
    
    @objc func removeTransparentView() {
        let frames = selectedButton.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0
            self.tableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        }, completion: nil)
    }
    
    
    @IBAction func statButton_clicked(_ sender: Any) {
        dataSource = ["Height", "Weight", "Position", "Number"]
        selectedButton = statButton
        addTransparentView(frames: statButton.frame)
    }
    
    
    @IBAction func cancelButton_clicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // executed always when the Screen's White Space (anywhere excluding objects) tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {        
        // end editing - hide keyboards
        self.view.endEditing(false)
    }
    
    
    
}

extension StatsVC: UITableViewDelegate, UITableViewDataSource {
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedButton.setTitle(dataSource[indexPath.row], for: .normal)
        removeTransparentView()
        cellText = dataSource[indexPath.row]
    }
    
    
}




