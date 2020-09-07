//
//  EditBaselineVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/11/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class EditBaselineVC: UIViewController {
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var heightText: UITextField!
    @IBOutlet weak var weightText: UITextField!
    @IBOutlet weak var wingspanText: UITextField!
    @IBOutlet weak var verticalText: UITextField!
    @IBOutlet weak var dashText: UITextField!
    @IBOutlet weak var agilityText: UITextField!
    @IBOutlet weak var pushUptext: UITextField!
    @IBOutlet weak var chinUpText: UITextField!
    @IBOutlet weak var mileText: UITextField!
    @IBOutlet weak var dateText: UILabel!
    
    
    var baselineToEdit = Baseline()
    var userBeingViewed = FUser()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        
        populateTextFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
            navigationController?.navigationBar.backgroundColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
            navigationController?.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
        }
    
    func editBaseline() {
        if heightText.text != "" && weightText.text != "" && wingspanText.text != "" && verticalText.text != "" && dashText.text != "" && agilityText.text != "" && pushUptext.text != "" && chinUpText.text != "" && mileText.text != "" {
            
            
            baselineToEdit.updateBaseline(baselineID: baselineToEdit.baselineID, baseline: baselineToEdit.baselineDictionary, height: heightText.text!, weight: weightText.text!, wingspan: wingspanText.text!, vertical: verticalText.text!, yardDash: dashText.text!, agility: agilityText.text!, pushUp: pushUptext.text!, chinUp: chinUpText.text!, mileRun: mileText.text!)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateBaseline"), object: nil)
            dismiss(animated: true, completion: nil)
            
        } else {
            Helper().showAlert(title: "Data Error", message: "Please fill in info.", in: self)
        }
    }
    
    func populateTextFields() {
        var date: String?
        
        let currentDateFormater = helper.dateFormatter()
        currentDateFormater.dateFormat = "MM/dd/YYYY"
        
        let baselineDate = helper.dateFormatter().date(from: baselineToEdit.baselineDate)
        date = currentDateFormater.string(from: baselineDate!)
        dateText.text = date
        heightText.text = baselineToEdit.height
        weightText.text = baselineToEdit.weight
        wingspanText.text = baselineToEdit.wingspan
        verticalText.text = baselineToEdit.vertical
        dashText.text = baselineToEdit.yardDash
        agilityText.text = baselineToEdit.agility
        pushUptext.text = baselineToEdit.pushUp
        chinUpText.text = baselineToEdit.chinUp
        mileText.text = baselineToEdit.mileRun
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        editBaseline()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
        
    
    // executed always when the Screen's White Space (anywhere excluding objects) tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // end editing - hide keyboards
        self.view.endEditing(false)
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

}
