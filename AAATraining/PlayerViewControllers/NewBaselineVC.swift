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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
