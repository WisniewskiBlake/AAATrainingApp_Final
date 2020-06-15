//
//  LoginVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 6/15/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    //ui objects
    @IBOutlet weak var textFieldsView: UIView!
    
    //executed when scene is loaded
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    // this func stores code which configures appearance of the textFields' View
    func configure_textFieldsView() {
        
        // declaring constants to store information which later on will be assigned to certain 'object'
        let width = CGFloat(2)
        let color = UIColor.groupTableViewBackground.cgColor
        
        // creating layer to be a border of the view added test
        let border = CALayer()
        border.borderWidth = width
        border.borderColor = color
        border.frame = CGRect(x: 0, y: 0, width: textFieldsView.frame.width, height: textFieldsView.frame.height)
        
        // creating layer to be a line in the center of the view
        let line = CALayer()
        line.borderWidth = width
        line.borderColor = color
        line.frame = CGRect(x: 0, y: textFieldsView.frame.height / 2 - width, width: textFieldsView.frame.width, height: width)
        
        // assigning created layers to the view
        textFieldsView.layer.addSublayer(border)
        textFieldsView.layer.addSublayer(line)
        
        // rounded corners
        textFieldsView.layer.cornerRadius = 5
        textFieldsView.layer.masksToBounds = true
        
    }

    

    

}
