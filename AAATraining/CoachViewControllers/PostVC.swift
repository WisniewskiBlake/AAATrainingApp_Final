//
//  PostVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/9/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

class PostVC: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var pictureButton: UIButton!
    @IBOutlet weak var urlLinkTextField: UITextField!
    
    var videoPath: NSURL? = NSURL()
    var picturePath: UIImage? = UIImage()
    // code obj
    var isPictureSelected = false
    var isVideoSelected = false
    
    var pictureToUpload: String? = ""
    
    let postID = UUID().uuidString
    
    func createPost() {
        if postTextView.text != "" {
            if isVideoSelected {
                let videoData = NSData(contentsOfFile: (videoPath?.path!)!)
                            
                uploadPostVideo(video: videoData!, view: self.navigationController!.view) { (videoLink) in

                    if videoLink != nil {
                        let fullName = FUser.currentUser()!.firstname + " " + FUser.currentUser()!.lastname
                        let post = Post(postID: self.postID, ownerID: FUser.currentId(), text: self.postTextView.text, picture: "", date: "", postUserAva: FUser.currentUser()!.ava, postUserName: fullName, video: videoLink!, postType: "video", postUrlLink: self.urlLinkTextField.text!)
                        
                        post.savePost()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createPost"), object: nil)

                    }
                }
                return
                
            } else if isPictureSelected {
                
                uploadPostImage(image: pictureImageView.image!, view: self.navigationController!.view) { (pictureLink) in

                    let fullName = FUser.currentUser()!.firstname + " " + FUser.currentUser()!.lastname
                    let post = Post(postID: self.postID, ownerID: FUser.currentId(), text: self.postTextView.text, picture: pictureLink!, date: "", postUserAva: FUser.currentUser()!.ava, postUserName: fullName, video: "", postType: "picture", postUrlLink: self.urlLinkTextField.text!)
                    
                    post.savePost()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createPost"), object: nil)
                }
                           
                

                    
                return
            } else {
                
                let fullName = FUser.currentUser()!.firstname + " " + FUser.currentUser()!.lastname
                let post = Post(postID: postID, ownerID: FUser.currentId(), text: postTextView.text, picture: "", date: "", postUserAva: FUser.currentUser()!.ava, postUserName: fullName, video: "", postType: "text", postUrlLink: urlLinkTextField.text!)
                
                post.savePost()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "createPost"), object: nil)
                return
            }
            
        }
        else {
            Helper().showAlert(title: "Data Error", message: "Please fill in info.", in: self)
        }
    }
    
    @IBAction func shareButton_clicked(_ sender: Any) {
            createPost()
            dismiss(animated: true, completion: nil)
        }
        
    func displayMedia(picture: UIImage?, video: NSURL?) {
        if let pic = picture {
            pictureImageView.image = pic
            isVideoSelected = false
            isPictureSelected = true
            return
        }
        
        //send video
        if let video = video {
            
            let thumbImage = createThumbnailOfVideoFromRemoteUrl(url: video)
            
            pictureImageView.image = thumbImage
            isPictureSelected = false
            isVideoSelected = true
            
            return
        }
    }
    

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
        let helper = Helper()
        let user = FUser.currentUser()
        // safely accessing user related detailes ["key">"value"]
        guard let firstName = user?.firstname, let lastName = user?.lastname, let avaPath = user?.ava else {
            
            return
        }
        
        if avaPath != "" {
            
            helper.imageFromData(pictureData: avaPath) { (avatarImage) in
                
                if avatarImage != nil {
                    avaImageView.image = avatarImage!
                }
            }
        } else{
            avaImageView.image = UIImage(named: "user.png")
        }
        fullnameLabel.text = "\((firstName).capitalized) \((lastName).capitalized)"
    }
    
    
    @IBAction func pictureButtonClicked(_ sender: Any) {
        print("tapped")
        let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            camera.PresentMultyCamera(target: self, canEdit: false)
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            
            camera.PresentPhotoLibrary(target: self, canEdit: false)
        }
        
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (action) in
            
            camera.PresentVideoLibrary(target: self, canEdit: false)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        takePhotoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
        sharePhoto.setValue(UIImage(named: "picture"), forKey: "image")
        shareVideo.setValue(UIImage(named: "video"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareVideo)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        videoPath = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        //picturePath = info[UIImagePickerController.InfoKey(rawValue: convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage))] as? UIImage
        picturePath = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        let pictureData = picturePath?.jpegData(compressionQuality: 0.4)!
        pictureToUpload = pictureData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        displayMedia(picture: picturePath, video: videoPath)
        
        picker.dismiss(animated: true, completion: nil)
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
    
    
    
    
    
    
    
    @IBAction func addPicture_clicked(_ sender: Any) {
        //showActionSheet()
    }
    
    
    
    // exec whenever the screen has been tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        postTextView.resignFirstResponder()
    }
    
    @IBAction func cancelButton_clicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func createThumbnailOfVideoFromRemoteUrl(url: NSURL) -> UIImage? {
        let asset = AVAsset(url: url as URL)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        //Can set this to improve performance if target size is known before hand
        //assetImgGenerate.maximumSize = CGSize(width,height)
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
          print(error.localizedDescription)
          return nil
        }
    }
    
    
    

}


extension UIImage {
    func toString() -> String? {
        let data: Data? = self.pngData()
        return data?.base64EncodedString(options: .endLineWithLineFeed)
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
