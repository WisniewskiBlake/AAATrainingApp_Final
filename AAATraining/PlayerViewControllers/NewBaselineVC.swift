//
//  NewBaselineVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/11/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class NewBaselineVC: UIViewController {
    
    @IBOutlet weak var heightText: UITextField!
    @IBOutlet weak var weightText: UITextField!
    @IBOutlet weak var wingspanText: UITextField!
    @IBOutlet weak var verticalText: UITextField!
    @IBOutlet weak var dashText: UITextField!
    @IBOutlet weak var agilityText: UITextField!
    @IBOutlet weak var pushUptext: UITextField!
    @IBOutlet weak var chinUpText: UITextField!
    @IBOutlet weak var mileText: UITextField!
    
    //let baselineID = UUID().uuidString
    var userBeingViewed = FUser()
    var editBaseline = false
        
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        cornerRadius(for: heightText)
//        cornerRadius(for: weightText)
//        cornerRadius(for: wingspanText)
//        cornerRadius(for: verticalText)
//        cornerRadius(for: dashText)
//        cornerRadius(for: agilityText)
//        cornerRadius(for: pushUptext)
//        cornerRadius(for: chinUpText)
//        cornerRadius(for: mileText)
                
        padding(for: heightText)
        padding(for: weightText)
        padding(for: wingspanText)
        padding(for: verticalText)
        padding(for: dashText)
        padding(for: agilityText)
        padding(for: pushUptext)
        padding(for: chinUpText)
        padding(for: mileText)

        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        createBaseline()
    }
    
    
    func createBaseline() {
        if heightText.text != "" && weightText.text != "" && wingspanText.text != "" && verticalText.text != "" && dashText.text != "" && agilityText.text != "" && pushUptext.text != "" && chinUpText.text != "" && mileText.text != "" {
            
            let fullName = userBeingViewed.lastname + ", " + userBeingViewed.firstname
            
            let localReference = reference(.Baseline).document()
            let baselineID = localReference.documentID
            var baseline: [String : Any]!
            let date = helper.dateFormatter().string(from: Date())
            
            baseline = [kBASELINEID : baselineID, kBASELINEOWNERID : userBeingViewed.objectId, kBASELINEHEIGHT : heightText.text!, kBASELINEWEIGHT : weightText.text!, kWINGSPAN : wingspanText.text!, kVERTICAL : verticalText.text!, kAGILITY : agilityText.text!, kYARDDASH : dashText.text!, kPUSHUP : pushUptext.text!, kCHINUP : chinUpText.text!, kMILERUN : mileText.text!, kBASELINEDATE : date, kBASELINEUSERNAME : fullName]

            localReference.setData(baseline)

            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createBaseline"), object: nil)
            dismiss(animated: true, completion: nil)
            
        } else {
            Helper().showAlert(title: "Data Error", message: "Please fill in info.", in: self)
        }
    }

    
   

    // make corners rounded for any views (objects)
    func cornerRadius(for view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
    }
    
    // add blank view to the left side of the TextField (it'll act as a blank gap)
    func padding(for textField: UITextField) {
        let blankView = UIView.init(frame: CGRect(x: 0, y: 0, width: 2, height: 25))
        textField.leftView = blankView
        textField.leftViewMode = .always
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // executed always when the Screen's White Space (anywhere excluding objects) tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // end editing - hide keyboards
        self.view.endEditing(false)
    }
    
}
