//
//  StatsVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 6/25/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class StatsVC: UIViewController {

    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var heightText: UITextField!
    @IBOutlet weak var positionText: UITextField!
    @IBOutlet weak var weightText: UITextField!
    @IBOutlet weak var numberText: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // configures appearance of avaImageView
    func configure_avaImageView() {
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
    }
    
    @IBAction func cancelButton_clicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveButton_clicked(_ sender: Any) {
        
    }
    

}
