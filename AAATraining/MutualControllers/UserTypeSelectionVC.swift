//
//  UserTypeSelectionVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/29/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class UserSelectionCellClass: UITableViewCell {
    
}

class UserTypeSelectionVC: UIViewController {
    
    
    
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var accountTypeButton: UIButton!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    
    
    let transparentView = UIView()
    let tableView = UITableView()
    var selectedButton = UIButton()
    var dataSource = [String]()
    var cellText = "Select Here"
    var viewToGoTo = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cornerRadius(for: accountTypeButton)
               
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserSelectionCellClass.self, forCellReuseIdentifier: "Cell")
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if viewToGoTo == "PlayerRegister" {
            let pRegisterVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayerRegister") as! RegisterVC
            
            
            self.navigationController?.pushViewController(pRegisterVC, animated: true)
        } else if viewToGoTo == "ParentRegister" {
            let newGroupVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParentRegister") as! ParentRegisterVC
            
            
            self.navigationController?.pushViewController(newGroupVC, animated: true)
        } else if viewToGoTo == "CoachRegister" {
            let cRegisterVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CoachRegister") as! CoachRegisterVC
            
            
            self.navigationController?.pushViewController(cRegisterVC, animated: true)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func checkButtonText() {
        if cellText == "Select Here" {
            Helper().showAlert(title: "Error", message: "Please select a stat", in: self)
        } else if cellText == "Player" {
            nextButton.isEnabled = true
            viewToGoTo = "PlayerRegister"
        } else if cellText == "Parent" {
            nextButton.isEnabled = true
            viewToGoTo = "ParentRegister"
        } else if cellText == "Coach" {
            nextButton.isEnabled = true
            viewToGoTo = "CoachRegister"
        }
    }
    
    @IBAction func userTypeButtonPressed(_ sender: Any) {
        dataSource = ["Player", "Parent", "Coach"]
        selectedButton = accountTypeButton
        addTransparentView(frames: accountTypeButton.frame)
        
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

}
extension UserTypeSelectionVC: UITableViewDelegate, UITableViewDataSource {
    
    
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
        checkButtonText()
    }
    
    
}
