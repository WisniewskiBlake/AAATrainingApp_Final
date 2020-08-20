//
//  NutritionPostVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/19/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit

class NutritionPostVC: UIViewController {
    
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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
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
    
    // executed always when the Screen's White Space (anywhere excluding objects) tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // end editing - hide keyboards
        self.view.endEditing(false)
    }
    

}
