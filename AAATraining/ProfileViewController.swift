//
//  ProfileViewController.swift
//  AAATraining
//
//  Created by Margaret Dwan on 6/23/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var heightTextLabel: UILabel!
    @IBOutlet weak var positionTextLabel: UILabel!
    @IBOutlet weak var weightTextLabel: UILabel!
    @IBOutlet weak var numberTextLabel: UILabel!
    
    
    
    
    // code obj (to build logic of distinguishing tapped / shown Cover / Ava)
    var isCover = false
    var isAva = false
    var imageViewTapped = ""
    
    // posts obj
    var posts = [NSDictionary?]()
    var avas = [UIImage]()
    var pictures = [UIImage]()
    var skip = 0
    var limit = 10
    var isLoading = false
    var liked = [Int]()
    
    // color obj
    let likeColor = UIColor(red: 28/255, green: 165/255, blue: 252/255, alpha: 1)
    
    // friends obj
    var myFriends = [NSDictionary?]()
    var myFriends_avas = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(currentUser)

        configure_avaImageView()
        loadUser()
    }
    
    @IBAction func coverImageView_tapped(_ sender: Any) {
        // switching trigger
        imageViewTapped = "cover"
        
        // launch action sheet calling function
        showActionSheet()
    }
    
    @IBAction func avaImageView_tapped(_ sender: Any) {
        // switching trigger
        imageViewTapped = "ava"
        
        // launch action sheet calling function
        showActionSheet()
    }
    
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    // configuring the appearance of AvaImageView
    func configure_avaImageView() {
        
        // creating layer that will be applied to avaImageView (layer - broders of ava)
        let border = CALayer()
        border.borderColor = UIColor.white.cgColor
        border.borderWidth = 5
        border.frame = CGRect(x: 0, y: 0, width: avaImageView.frame.width, height: avaImageView.frame.height)
        avaImageView.layer.addSublayer(border)
        
        // rounded corners
        avaImageView.layer.cornerRadius = 10
        avaImageView.layer.masksToBounds = true
        avaImageView.clipsToBounds = true
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
        // declaring delete button
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            // deleting profile picture (ava), by returning placeholder
            if self.imageViewTapped == "ava" {
                self.avaImageView.image = UIImage(named: "user.png")
                self.isAva = false
                self.uploadImage(from: self.avaImageView)
            } else if self.imageViewTapped == "cover" {
                self.coverImageView.image = UIImage(named: "HomeCover.jpg")
                self.isCover = false
                self.uploadImage(from: self.coverImageView)
            }
        }
        // manipulating appearance of delete button for each scenarios
        if imageViewTapped == "ava" && isAva == false && imageViewTapped != "cover" {
            delete.isEnabled = false
        }
        if imageViewTapped == "cover" && isCover == false && imageViewTapped != "ava" {
            delete.isEnabled = false
        }
        // adding buttons to the sheet
        sheet.addAction(camera)
        sheet.addAction(library)
        sheet.addAction(cancel)
        sheet.addAction(delete)
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
    
    // executed once the picture is selected in PickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        // accessing selected image from its variable
        let image = info[UIImagePickerController.InfoKey(rawValue: convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage))] as? UIImage
        
        // based on the trigger we are assigning selected pictures to the appropriated imageView
        if imageViewTapped == "cover" {
            // assign selected image to CoverImageView
            self.coverImageView.image = image
            // upload image to the server
            self.uploadImage(from: self.coverImageView)
        } else if imageViewTapped == "ava" {
            // assign selected image to AvaImageView
            self.avaImageView.image = image
            // refresh global variable storing the user's profile pic
            currentUser_ava = self.avaImageView.image
            
            // upload image to the server
            self.uploadImage(from: avaImageView)
        }
        // completion handler, to communicate to the project that images has been selected (enable delete button)
        dismiss(animated: true) {
            if self.imageViewTapped == "cover" {
                self.isCover = true
            } else if self.imageViewTapped == "ava" {
                self.isAva = true
            }
        }
        
    }
    
    // sends request to the server to upload the Image (ava/cover)
    func uploadImage(from imageView: UIImageView) {
        
        // save method of accessing ID of current user
        guard let id = currentUser?["id"] else {
            return
        }
        // STEP 1. Declare URL, Request and Params
        // url we gonna access (API)
        let url = URL(string: "http://localhost/fb/uploadImage.php")!
        // declaring reqeust with further configs
        var request = URLRequest(url: url)
        // POST - safest method of passing data to the server
        request.httpMethod = "POST"
        // values to be sent to the server under keys (e.g. ID, TYPE)
        let params = ["id": id, "type": imageViewTapped]
        // MIME Boundary, Header
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        // if in the imageView is placeholder - send no picture to the server
        // Compressing image and converting image to 'Data' type
        var imageData = Data()
        if imageView.image != UIImage(named: "HomeCover.jpg") && imageView.image != UIImage(named: "user.png") {
            imageData = imageView.image!.jpegData(compressionQuality: 0.5)!
        }
        // assigning full body to the request to be sent to the server
        request.httpBody = Helper().body(with: params, filename: "\(imageViewTapped).jpg", filePathKey: "file", imageDataKey: imageData, boundary: boundary) as Data
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                // error occured
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                do {
                    // save mode of casting any data
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    // fetching JSON generated by the server - php file
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // save method of accessing json constant
                    guard let parsedJSON = json else {
                        return
                    }
                    // uploaded successfully
                    if parsedJSON["status"] as! String == "200" {
                        
                        // saving upaded user related information (e.g. ava's path, cover's path)
                        currentUser = parsedJSON.mutableCopy()  as? Dictionary<String, Any>
                        DEFAULTS.set(currentUser, forKey: "currentUser")
                        DEFAULTS.synchronize()
                    // error while uploading
                    } else {
                        // show the error message in AlertView
                        if parsedJSON["message"] != nil {
                            let message = parsedJSON["message"] as! String
                            Helper().showAlert(title: "Error", message: message, in: self)
                        }
                    }
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                }
            }
        }.resume()
    }
    
    // loads all user related information to be shown in the header
    @objc func loadUser() {
        // safe method of accessing user related information in glob var
        guard let firstName = currentUser?["firstName"], let lastName = currentUser?["lastName"], let avaPath = currentUser?["ava"], let coverPath = currentUser?["cover"], let height = currentUser?["height"], let weight = currentUser?["weight"], let position = currentUser?["position"], let number = currentUser?["number"] else {
            print(currentUser?.isEmpty)
            print(currentUser)
            return
        }
        // check in the front end is there any picture in the ImageView laoded from the server (is there a real html path / link to the image)
        if (avaPath as! String).count > 10 {
            isAva = true
        } else {
            avaImageView.image = UIImage(named: "user.png")
            isAva = false
        }
        
        if (coverPath as! String).count > 10 {
            isCover = true
        } else {
            coverImageView.image = UIImage(named: "HomeCover.jpg")
            isCover = false
        }
        // assigning vars which we accessed from global var, to fullnameLabel
        fullnameLabel.text = "\((firstName as! String).capitalized) \((lastName as! String).capitalized)"
        heightTextLabel.text = "\((height as! String).capitalized)"
        weightTextLabel.text = "\((weight as! String).capitalized)"
        positionTextLabel.text = "\((position as! String).capitalized)"
        numberTextLabel.text = "\((number as! String).capitalized)"
        // downloading the images and assigning to certain imageViews        
        Helper().downloadImage(from: avaPath as! String, showIn: self.avaImageView, orShow: "user.png")
        Helper().downloadImage(from: coverPath as! String, showIn: self.coverImageView, orShow: "HomeCover.jpg")
        // if bio is empty in the server -> hide bio label, otherwise, show bio label
        
        // save in the background thread the user's profile picture
        DispatchQueue.main.async {
            currentUser_ava = self.avaImageView.image
        }
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
