//
//  CoachProfileViewController.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/8/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import MediaPlayer

class CoachProfileViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    
    
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
    //var numLiked = [Int]()
    
    // color obj
    let likeColor = UIColor(red: 28/255, green: 165/255, blue: 252/255, alpha: 1)
    
    // friends obj
    var myFriends = [NSDictionary?]()
    var myFriends_avas = [UIImage]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // dynamic cell height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadUser), name: NSNotification.Name(rawValue: "updateStats"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadUser), name: NSNotification.Name(rawValue: "updateUser"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadNewPosts), name: NSNotification.Name(rawValue: "uploadPost"), object: nil)

        configure_avaImageView()
        loadUser()
        loadPosts(offset: skip, limit: limit)
        
        
        
    }
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide navigation bar on Home Pagex
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    // exec-d when new post is published
    @objc func loadNewPosts() {
        
        // skipping 0 posts, as we want to load the entire feed. And we are extending Limit value based on the previous loaded posts.
        loadPosts(offset: 0, limit: skip + 1)
    }
    
    // MARK: - Load User
    // loads all user related information to be shown in the header
    @objc func loadUser() {
   
        guard let firstName = currentUser?["firstName"], let lastName = currentUser?["lastName"], let avaPath = currentUser?["ava"], let coverPath = currentUser?["cover"] else {
               
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
           
           // downloading the images and assigning to certain imageViews
           Helper().downloadImage(from: avaPath as! String, showIn: self.avaImageView, orShow: "user.png")
           Helper().downloadImage(from: coverPath as! String, showIn: self.coverImageView, orShow: "HomeCover.jpg")
           // if bio is empty in the server -> hide bio label, otherwise, show bio label
           
           // save in the background thread the user's profile picture
           DispatchQueue.main.async {
               currentUser_ava = self.avaImageView.image
               
           }
    }
    
    // MARK: - Load Posts
    // loading posts from the server via@objc  PHP protocol
    func loadPosts(offset: Int, limit: Int) {
        
        isLoading = true
        
        // accessing id of the user : safe mode
        guard let id = currentUser?["id"] else {
            return
        }
        
        // prepare request
        let url = URL(string: "http://localhost/fb/selectPosts.php")!
        let body = "id=\(id)&offset=\(offset)&limit=\(limit)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        // send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error occured
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    self.isLoading = false
                    return
                }
                
                do {
                    // access data - safe mode
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        self.isLoading = false
                        return
                    }
                    
                    // converting data to JSON
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // accessing json data - safe mode
                    guard let posts = json?["posts"] as? [NSDictionary] else {
                        self.isLoading = false
                        return
                    }
                    
                    // assigning all successfully loaded posts to our Class Var - posts (after it got loaded successfully)
                    self.posts = posts
                    
                    // we are skipping already loaded numb of posts for the next load - pagination
                    self.skip = posts.count
                    
                    
                    // clean up likes for the refetching
                    self.liked.removeAll(keepingCapacity: false)
                    // clean up likes for the refetching
                    //self.numLiked.removeAll(keepingCapacity: false)
                    
                    
                    // logic of tracking liked posts
                    for post in posts {
                        if post["liked"] is NSNull {
                            self.liked.append(Int())
                        } else {
                            self.liked.append(1)
                            
                        }
                    }
                    
                    
                    // reloading tableView to have an affect - show posts
                    self.tableView.reloadData()
                    
                    self.isLoading = false
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    self.isLoading = false
                    return
                }
                
            }
        }.resume()
        
    }
    
    // MARK: - Load More
    // loading more posts from the server via PHP protocol
    func loadMore(offset: Int, limit: Int) {
        
        isLoading = true
        
        // accessing id of the user : safe mode
        guard let id = currentUser?["id"] else {
            return
        }
        
        // prepare request
        let url = URL(string: "http://localhost/fb/selectPosts.php")!
        let body = "id=\(id)&offset=\(offset)&limit=\(limit)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        // send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error occured
                if error != nil {
                    self.isLoading = false
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                do {
                    // access data - safe mode
                    guard let data = data else {
                        self.isLoading = false
                        return
                    }
                    
                    // converting data to JSON
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // accessing json data - safe mode
                    guard let posts = json?["posts"] as? [NSDictionary] else {
                        self.isLoading = false
                        return
                    }
                    
                    // assigning all successfully loaded posts to our Class Var - posts (after it got loaded successfully)
                    self.posts.append(contentsOf: posts)
                    
                    // we are skipping already loaded numb of posts for the next load - pagination
                    self.skip += posts.count
                    
                    
                    // logic of tracking liked posts
                    for post in posts {
                        if post["liked"] is NSNull {
                            self.liked.append(Int())
                        } else {
                            self.liked.append(1)
                        }
                    }
                    
                    
                    // reloading tableView to have an affect - show posts
                    self.tableView.beginUpdates()
                    
                    for i in 0 ..< posts.count {
                        let lastSectionIndex = self.tableView.numberOfSections - 1
                        let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex)
                        let pathToLastRow = IndexPath(row: lastRowIndex + i, section: lastSectionIndex)
                        self.tableView.insertRows(at: [pathToLastRow], with: .fade)
                    }
                    
                    self.tableView.endUpdates()
                    
                    self.isLoading = false
                    
                } catch {
                    self.isLoading = false
                    return
                }
                
            }
        }.resume()
        
    }
    
    // MARK: - Upload Image
    // sends request to the server to upload the Image (ava/cover)
    func uploadImage(from imageView: UIImageView, action: String) {
        
        // save method of accessing ID of current user
        guard let id = currentUser?["id"] else {
            return
        }
        // STEP 1. Declare URL, Request and Params
        // url we gonna access (API)
        let url = URL(string: "http://localhost/fb/uploadImage.php")!
        //let url = URL(string: "http://192.168.1.17/fb/uploadImage.php")!
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
        
//        if imageView.image != UIImage(named: "HomeCover.jpg") && imageView.image != UIImage(named: "user.png") {
//            imageData = imageView.image!.jpegData(compressionQuality: 0.5)!
//        }
        
//        if imageView.image != UIImage(named: "HomeCover.jpg") && imageView.image != UIImage(named: "user.png") {
//            imageData = imageView.image!.jpegData(compressionQuality: 0.5)!
//        }
        imageData = imageView.image!.jpegData(compressionQuality: 0.5)!
        let xxx = imageView.image!
        print(xxx)
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
    
    // MARK: - Show Picker
    // takes us to the PickerController (Controller that allows us to select picture)
    func showPicker(with source: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - Image Picker Controller
    // executed once the picture is selected in PickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        // accessing selected image from its variable
        let image = info[UIImagePickerController.InfoKey(rawValue: convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage))] as? UIImage
        
        // based on the trigger we are assigning selected pictures to the appropriated imageView
        if imageViewTapped == "cover" {
            // assign selected image to CoverImageView
            self.coverImageView.image = image
            // upload image to the server
            self.uploadImage(from: self.coverImageView, action: "newPic")
        } else if imageViewTapped == "ava" {
            // assign selected image to AvaImageView
            self.avaImageView.image = image
            // refresh global variable storing the user's profile pic
            currentUser_ava = self.avaImageView.image
            
            // upload image to the server
            self.uploadImage(from: avaImageView, action: "newPic")
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
    
    
    
    // MARK: - Show Action Sheet
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
        let xxx = currentUser?["ava"] as! String
    
        
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            // deleting profile picture (ava), by returning placeholder.. here i added the "default pic" for ava, may need to change for home
            if self.imageViewTapped == "ava" {
                self.avaImageView.image = UIImage(named: "user.png")
                self.isAva = false
                self.uploadImage(from: self.avaImageView, action: "defaultPic")
            } else if self.imageViewTapped == "cover" {
                self.coverImageView.image = UIImage(named: "HomeCover.jpg")
                self.isCover = false
                self.uploadImage(from: self.coverImageView, action: "defaultPic")
            }
        }
        // manipulating appearance of delete button for each scenarios
        if imageViewTapped == "ava" && isAva == false && imageViewTapped != "cover" {
            delete.isEnabled = false
        }
        if imageViewTapped == "cover" && isCover == false && imageViewTapped != "ava" {
            delete.isEnabled = false
        }
        
        if(xxx == "http://localhost/fb/ava/user.png") {
            // adding buttons to the sheet
            sheet.addAction(camera)
            sheet.addAction(library)
            sheet.addAction(cancel)
            
        } else {
            // adding buttons to the sheet
            sheet.addAction(camera)
            sheet.addAction(library)
            sheet.addAction(cancel)
            sheet.addAction(delete)
        }
        
        // present action sheet to the user finally
        self.present(sheet, animated: true, completion: nil)
    }
    
    // MARK: - Images tapped
    @IBAction func avaImageView_tapped(_ sender: Any) {
        // switching trigger
        imageViewTapped = "ava"
        
        // launch action sheet calling function
        showActionSheet()
    }
    
    @IBAction func coverImageView_tapped(_ sender: Any) {
        // switching trigger
        imageViewTapped = "cover"
        
        // launch action sheet calling function
        showActionSheet()
    }
    
       
    
    
    
    
    
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }
    
    // heights of the cells
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
            return UITableView.automaticDimension
        
    }
    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //1,3,6,last
        
        
            // accessing the value (e.g. url) under the key 'picture' for every single element of the array (indexPath.row)
            let pictureURL = posts[indexPath.row]!["picture"] as! String
        
            let numOfLikes = posts[indexPath.row]!["quantity"] as! String
            
            // no picture in the post
            if pictureURL.isEmpty {
                
                // accessing the cell from main.storyboard
                let cell = tableView.dequeueReusableCell(withIdentifier: "CoachNoPicCell", for: indexPath) as! CoachNoPicCell
                
                
                // fullname logic
                let firstName = posts[indexPath.row]!["firstName"] as! String
                let lastName = posts[indexPath.row]!["lastName"] as! String
                cell.fullnameLabel.text = firstName.capitalized + " " + lastName.capitalized
                cell.numberCompleted.text = numOfLikes
                
                // date logic
                let dateString = posts[indexPath.row]!["date_created"] as! String
                
                // taking the date received from the server and putting it in the following format to be recognized as being Date()
                let formatterGet = DateFormatter()
                formatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = formatterGet.date(from: dateString)!
                
                // we are writing a new readable format and putting Date() into this format and converting it to the string to be shown to the user
                let formatterShow = DateFormatter()
                formatterShow.dateFormat = "MMMM dd yyyy - HH:mm"
                cell.dateLabel.text = formatterShow.string(from: date)
                
                
                // text logic
                let text = posts[indexPath.row]!["text"] as! String
                cell.postTextLabel.text = text
                
                
                // avas logic
                let avaString = posts[indexPath.row]!["ava"] as! String
                let avaURL = URL(string: avaString)!
                
                // if there are still avas to be loaded
                if posts.count != avas.count {
                    
                    URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                        
                        // failed downloading - assign placeholder
                        if error != nil {
                            if let image = UIImage(named: "user.png") {
                                
                                self.avas.append(image)
                                
                                DispatchQueue.main.async {
                                    cell.avaImageView.image = image
                                }
                            }
                        }
                        
                        // downloaded
                        if let image = UIImage(data: data!) {
                            
                            self.avas.append(image)
                            
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                        }
                    }.resume()
                    
                // cached ava
                } else {
                    
                    DispatchQueue.main.async {
                        cell.avaImageView.image = self.avas[indexPath.row]
                    }
                }
                
                // picture logic
                pictures.append(UIImage())
                
                // get the index of the cell in order to get the certain post's id
                cell.numberCompleted.tag = indexPath.row
                cell.optionsButton.tag = indexPath.row
                
                
//                // manipulating the appearance of the button based is the post has been liken or not
//                DispatchQueue.main.async {
//                    if self.liked[indexPath.row] == 1 {
//                        cell.numberCompleted.text =
//                        //cell.numberCompleted.tintColor = self.likeColor
//                    }
////                        else {
////                        cell.numberCompleted.setImage(UIImage(named: "unlike.png"), for: .normal)
////                        cell.numberCompleted.tintColor = UIColor.darkGray
////                    }
//                }
                
                return cell
                
            // picture in the post
            } else {
                
                // accessing the cell from main.storyboard
                let cell = tableView.dequeueReusableCell(withIdentifier: "CoachPicCell", for: indexPath) as! CoachPicCell
                
                // fullname logic
                let firstName = posts[indexPath.row]!["firstName"] as! String
                let lastName = posts[indexPath.row]!["lastName"] as! String
                cell.fullnameLabel.text = firstName.capitalized + " " + lastName.capitalized
                cell.numberComplete.text = numOfLikes
                
                // date logic
                let dateString = posts[indexPath.row]!["date_created"] as! String
                
                // taking the date received from the server and putting it in the following format to be recognized as being Date()
                let formatterGet = DateFormatter()
                formatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = formatterGet.date(from: dateString)!
                
                // we are writing a new readable format and putting Date() into this format and converting it to the string to be shown to the user
                let formatterShow = DateFormatter()
                formatterShow.dateFormat = "MMMM dd yyyy - HH:mm"
                cell.dateLabel.text = formatterShow.string(from: date)
                
                
                // text logic
                let text = posts[indexPath.row]!["text"] as! String
                cell.postTextLabel.text = text
                
                
                // avas logic
                let avaString = posts[indexPath.row]!["ava"] as! String
                let avaURL = URL(string: avaString)!
                
                // if there are still avas to be loaded
                if posts.count != avas.count {
                    
                    URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                        
                        // failed downloading - assign placeholder
                        if error != nil {
                            if let image = UIImage(named: "user.png") {
                                
                                self.avas.append(image)
                                
                                DispatchQueue.main.async {
                                    cell.avaImageView.image = image
                                }
                                
                            }

                        }
                        
                        // downloaded
                        if let image = UIImage(data: data!) {
                            
                            self.avas.append(image)
                            
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                        }
                        
                        }.resume()
                    
                    // cached ava
                } else {
                    
                    DispatchQueue.main.async {
                        cell.avaImageView.image = self.avas[indexPath.row]
                    }
                }
                
                
                // pictures logic
                let pictureString = posts[indexPath.row]!["picture"] as! String
                let pictureURL = URL(string: pictureString)!
                
                // if there are still pictures to be loaded
                if posts.count != pictures.count {
                    
                    URLSession(configuration: .default).dataTask(with: pictureURL) { (data, response, error) in
                        
                        // failed downloading - assign placeholder
                        if error != nil {
                            if let image = UIImage(named: "user.png") {
                                
                                self.pictures.append(image)
                                
                                DispatchQueue.main.async {
                                    cell.pictureImageView.image = image
                                }
                                
                            }
                            
                        }
                        
                        // downloaded
                        if let image = UIImage(data: data!) {
                            
                            self.pictures.append(image)
                            
                            DispatchQueue.main.async {
                                cell.pictureImageView.image = image
                            }
                        }
                        
                        }.resume()
                    
                // cached picture
                } else {
                    
                    DispatchQueue.main.async {
                        cell.pictureImageView.image = self.pictures[indexPath.row]
                    }
                }
                
                
                // get the index of the cell in order to get the certain post's id
                cell.numberComplete.tag = indexPath.row
                cell.optionsButton.tag = indexPath.row
                
                
//                // manipulating the appearance of the button based is the post has been liken or not
//                DispatchQueue.main.async {
//                    if self.liked[indexPath.row] == 1 {
//                        cell.likeButton.setImage(UIImage(named: "like.png"), for: .normal)
//                        cell.likeButton.tintColor = self.likeColor
//                    } else {
//                        cell.likeButton.setImage(UIImage(named: "unlike.png"), for: .normal)
//                        cell.likeButton.tintColor = UIColor.darkGray
//                    }
//                }
                
                
                return cell
                
            }
        
        }
    
    
    
    
    
    // MARK: - Scroll Did Scroll
    // executed always whenever tableView is scrolling
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // load more posts when the scroll is about to reach the bottom AND currently is not loading (posts)
        let a = tableView.contentOffset.y - tableView.contentSize.height + 60
        let b = -tableView.frame.height
        
        if a > b && isLoading == false {
            loadMore(offset: skip, limit: limit)
        }
        
    }
    
    // MARK: - More Clicked
    @IBAction func moreButton_clicked(_ sender: Any) {
        // creating action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // creating buttons for action sheet
        let logout = UIAlertAction(title: "Log Out", style: .destructive, handler: { (action) in
            
            // access/instantiate loginViewController
            let loginvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            
            // show loginViewController
            self.present(loginvc, animated: false, completion: {
                
                // clear currentUser global var, after showing loginViewController - save as an empty user (blank NSMutableDictionary)
                currentUser = NSMutableDictionary() as? Dictionary<String, Any>
                UserDefaults.standard.set(currentUser, forKey: "currentUser")
                UserDefaults.standard.synchronize()
                
            })
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // add buttons to action sheet
        sheet.addAction(logout)
        sheet.addAction(cancel)
        
        // show action sheet
        present(sheet, animated: true, completion: nil)
    }
    
    // MARK: - Option Button Click
    @IBAction func optionsButton_clicked(_ optionButton: UIButton) {
        // accessing indexPath of the button / cell
        let indexPathRow = optionButton.tag
        
        
        // creating actionSheet
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // creating Delete button
        let delete = UIAlertAction(title: "Delete Post", style: .destructive) { (delete) in
            self.deletePost(_: indexPathRow)
        }
        
        // creating Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // assigning buttons to the sheet
        alert.addAction(delete)
        alert.addAction(cancel)
        
        // showing actionSheet
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Delete Posts
    // sends request to the server to delete the post
    func deletePost(_ row: Int) {
        
        // accessing id of the post which is stored in the tapped cell
        guard let id = posts[row]?["id"] as? Int else {
            return
        }
        
        // prepare request
        let url = URL(string: "http://localhost/fb/deletePost.php")!
        let body = "id=\(id)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        
        // clean up of the data stored in the background of our logic in order to keep everything synchronized
        posts.remove(at: row)
        avas.remove(at: row)
        pictures.remove(at: row)
        liked.remove(at: row)
        
        
        // remove the cell itself from the tableView
        let indexPath = IndexPath(row: row, section: 0)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        tableView.reloadData()
        
        
        // execute request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error occured
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                // receive data from the server
                do {
                    
                    // safe mode of casting data
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    
                    // accessing json via data received
                    let _ = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    
                // json error
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    return
                }
                
            }
        }.resume()
        
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
