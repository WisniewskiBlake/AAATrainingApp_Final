//
//  PostVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/9/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class PostVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    
    // code obj
    var isPictureSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()

        loadUser()
    }
    
    // loaded after adjusting the layouts
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // rounded corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
    }
    
    // loading user
    func loadUser() {
        
        // safely accessing user related detailes ["key">"value"]
        guard let firstName = currentUser?["firstName"], let lastName = currentUser?["lastName"], let avaPath = currentUser?["ava"] else {
            return
        }
        
        // assigning accessed details to the functions which loads the user
        Helper().loadFullname(firstName: firstName as! String, lastName: lastName as! String, showIn: fullnameLabel)
        Helper().downloadImage(from: avaPath as! String, showIn: avaImageView, orShow: "user.png")
    }
    
    // tracks whenver textView gets changed
    func textViewDidChange(_ textView: UITextView) {
        
        // if textview isn't empty -> there's some text in textView, show the label, otherwise -> hide
        if textView.text.isEmpty {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }
        
    }
    
    // this function launches Action Sheet for the photos
    func showActionSheet() {
        
        // declaring action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // declaring camera button
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            
            // if camera available on device, than show
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.showPicker(with: .camera)
            }
            
        }
        
        // declaring library button
        let library = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            
            // checking availability of photo library
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.showPicker(with: .photoLibrary)
            }
            
        }
        
        // declaring cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // adding buttons to the sheet
        sheet.addAction(camera)
        sheet.addAction(library)
        sheet.addAction(cancel)
        
        // present action sheet to the user finally
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    // takes us to the PickerController (Controller that allows us to select picture)
    func showPicker(with source: UIImagePickerController.SourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true, completion: nil)
        
    }
    
    // executed whenever the image has been picked via pickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        // accessing selected image from its variable
        let image = info[UIImagePickerController.InfoKey(rawValue: convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage))] as? UIImage
        
        // assigning selected image to pictureImageView
        pictureImageView.image = image
        
        // cast boolean as TRUE -> Picture Is Selected
        isPictureSelected = true
        
        // remove pickerController
        dismiss(animated: true, completion: nil)
    }
    
    // exec whenever the screen has been tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        postTextView.resignFirstResponder()
    }
    

    

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
