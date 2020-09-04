//
//  ColorPickerVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 9/1/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import Colorful

class ColorPickerVC: UIViewController {
    
    @IBOutlet weak var colorPicker: ColorPicker!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var uiSwitch: UISwitch!
    @IBOutlet weak var colorSpaceLabel: UILabel!
    
    var colorSpace: HRColorSpace = .sRGB
    
    var colorToUpload: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)

        colorPicker.addTarget(self, action: #selector(self.handleColorChanged(picker:)), for: .valueChanged)
        colorPicker.set(color: UIColor(displayP3Red: 1.0, green: 1.0, blue: 0, alpha: 1), colorSpace: colorSpace)
        updateColorSpaceText()
        handleColorChanged(picker: colorPicker)
        
        label.text = "Please close/re-open the app for changes to take affect!"
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        updateCurrentUserInFirestore(withValues: [kUSERTEAMCOLORONE : colorToUpload]) { (success) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateColor"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    @objc func handleColorChanged(picker: ColorPicker) {
//        label.text = picker.color.description
        
        
        colorToUpload = picker.color.htmlRGBaColor
    }

    @IBAction func handleRedButtonAction(_ sender: UIButton) {
        colorPicker.set(color: .red, colorSpace: colorSpace)
        handleColorChanged(picker: colorPicker)
    }

    @IBAction func handlePurpleButtonAction(_ sender: UIButton) {
        colorPicker.set(color: .purple, colorSpace: colorSpace)
        handleColorChanged(picker: colorPicker)
    }

    @IBAction func handleYellowButtonAction(_ sender: UIButton) {
        colorPicker.set(color: .yellow, colorSpace: colorSpace)
        handleColorChanged(picker: colorPicker)
    }

    @IBAction func handleSwitchAction(_ sender: UISwitch) {
        colorSpace = sender.isOn ? .extendedSRGB : .sRGB
        colorPicker.set(color: colorPicker.color, colorSpace: colorSpace)
        updateColorSpaceText()
        handleColorChanged(picker: colorPicker)
    }

    func updateColorSpaceText() {
        switch colorSpace {
        case .extendedSRGB:
            colorSpaceLabel.text = "Extended sRGB"
        case .sRGB:
            colorSpaceLabel.text = "sRGB"
        }
    }

}
