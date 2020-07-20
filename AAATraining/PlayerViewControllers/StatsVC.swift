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
    
    let transparentView = UIView()
    let tableView = UITableView()
    var selectedButton = UIButton()
    var dataSource = [String]()
    var cellText = "Select Stat"
    
    override func viewDidLoad() {
       super.viewDidLoad()
       tableView.delegate = self
       tableView.dataSource = self
       tableView.register(CellClass.self, forCellReuseIdentifier: "Cell")
        
        padding(for: statTextField)
        cornerRadius(for: statButton)
        
        
        configure_avaImageView()
        loadUser()
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
        
        // safe method of accessing user related information in glob var
        guard let firstName = currentUser1?["firstName"], let lastName = currentUser1?["lastName"], let avaPath = currentUser1?["ava"] else {
            return
        }
        
        fullnameLabel.text = "\((firstName as! String).capitalized) \((lastName as! String).capitalized)"
        
         Helper().downloadImage(from: avaPath as! String, showIn: self.avaImageView, orShow: "user.png")
        
        
    }
    
    @IBAction func saveButton_clicked(_ sender: Any) {
        if statTextField.text!.isEmpty == false  {
            if cellText == "Select Stat" {
                Helper().showAlert(title: "Error", message: "Please select a stat", in: self)
            } else if cellText == "Height" {
                if Helper().isValid(height: statTextField.text!) {
                    self.updateStats()
                }
            } else if cellText == "Weight" {
                if Helper().isValid(weight: statTextField.text!) {
                    self.updateStats()
                }
            } else if cellText == "Position" {
                if Helper().isValid(position: statTextField.text!) {
                    self.updateStats()
                }
            } else if cellText == "Number" {
                if Helper().isValid(number: statTextField.text!) {
                    self.updateStats()
                }
            }
        } else {
            Helper().showAlert(title: "Error", message: "Please fill out form", in: self)
        }
    }
    
    // updating bio by sending request to the server
    func updateStats() {
        let stat = cellText.lowercased()
        // STEP 1. Access var / params to be sent to the server
        guard let id = currentUser1?["id"] else {
            return
        }
        
        
//        // send notification to the server
//        let notification_url = "http://localhost/fb/notification.php"
//        let notification_body = "byUser_id=\(id)&user_id=\(id)&type=bio&action=insert"
//        _ = Helper().sendHTTPRequest(url: notification_url, body: notification_body, success: {}, failure: {})

        
        
        // STEP 2. Declare URL, Request, Method, etc
        //let url = URL(string: "http://localhost/fb/updateStats.php")!
        let url = URL(string: "http://192.168.1.17/fb/updateStats.php")!
        let body = "id=\(id)&stat=\(stat)&statValue=\(statTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines))"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        // STEP 3. Execute and Launch Request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                // go to data and jsoning
                do {
                    
                    // save method of casting data received from the server
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    
                    // STEP 4. Parse JSON
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    print(json!)
                    
                    // save method of casting json
                    guard let parsedJSON = json else {
                        return
                    }
                    
                    // updated successfully
                    if parsedJSON["status"] as! String == "200" {
                        
                        // save updated user information in the app
                        currentUser1 = parsedJSON.mutableCopy() as?  Dictionary<String, Any>
                        UserDefaults.standard.set(currentUser1, forKey: "currentUser")
                        UserDefaults.standard.synchronize()
                        
                        // post notification -> update Bio on Home Page
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateStats"), object: nil)
                        self.dismiss(animated: true, completion: nil)
                    
                    // error while updating (e.g. Status = 400)
                    } else {
                        Helper().showAlert(title: "400", message: "Error while updating stats", in: self)
                    }
                    
                // error while processing/accessing json
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                }
                
            }
            
        }.resume()
        
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




