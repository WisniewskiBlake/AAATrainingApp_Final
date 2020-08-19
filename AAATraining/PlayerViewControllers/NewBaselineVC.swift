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
    
    let baselineID = UUID().uuidString
    var userBeingViewed = FUser()
    var editBaseline = false
        
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cornerRadius(for: heightText)
        cornerRadius(for: weightText)
        cornerRadius(for: wingspanText)
        cornerRadius(for: verticalText)
        cornerRadius(for: dashText)
        cornerRadius(for: agilityText)
        cornerRadius(for: pushUptext)
        cornerRadius(for: chinUpText)
        cornerRadius(for: mileText)
                
        padding(for: heightText)
        padding(for: weightText)
        padding(for: wingspanText)
        padding(for: verticalText)
        padding(for: dashText)
        padding(for: agilityText)
        padding(for: pushUptext)
        padding(for: chinUpText)
        padding(for: mileText)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        createBaseline()
    }
    
    
    func createBaseline() {
        if heightText.text != "" && weightText.text != "" && wingspanText.text != "" && verticalText.text != "" && dashText.text != "" && agilityText.text != "" && pushUptext.text != "" && chinUpText.text != "" && mileText.text != "" {
            
            let fullName = userBeingViewed.firstname + " " + userBeingViewed.lastname
            
            let baseline = Baseline(baselineID: baselineID, baselineOwnerID: userBeingViewed.objectId, height: heightText.text!, weight: weightText.text!, wingspan: wingspanText.text!, vertical: verticalText.text!, yardDash: dashText.text!, agility: agilityText.text!, pushUp: pushUptext.text!, chinUp: chinUpText.text!, mileRun: mileText.text!, baselineDate: "", userName: fullName)
            
            baseline.saveBaseline()
            
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
        let blankView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        textField.leftView = blankView
        textField.leftViewMode = .always
    }
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
