//
//  EditGroupVC_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/26/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import ProgressHUD
import ImagePicker



class EditGroupVC_Coach: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
//    @IBAction func iconTapGesturePressed(_ sender: Any) {
//        showIconOptions()
//    }
//
//    @IBAction func editButtonPressed(_ sender: Any) {
//        showIconOptions()
//    }
    
//    @IBOutlet weak var groupImageView: UIImageView!
//    @IBOutlet weak var editButton: UIButton!
//    @IBOutlet weak var groupSubjectTextField: UITextField!
//    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    //@IBOutlet var iconTapGesture: UITapGestureRecognizer!
    @IBOutlet weak var participantsLabel: UILabel!
    
    let helper = Helper()
    
    var memberIds: [String] = []
    var allMembers: [FUser] = []
    //var groupIcon: UIImage?
    
    //var group: NSDictionary!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        groupImageView.isUserInteractionEnabled = true
//        groupImageView.addGestureRecognizer(iconTapGesture)
        
//        setupUI()
        
        updateParticipantsLabel()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
    }
    
    //MARK: Helpers
     
//
    
//    func didClickDeleteButton(indexPath: IndexPath) {
//        allMembers.remove(at: indexPath.row)
//        memberIds.remove(at: indexPath.row)
//
//        collectionView.reloadData()
//        updateParticipantsLabel()
//    }
    
//    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
//        self.dismiss(animated: true, completion: nil)
//    }
    
//    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
//        <#code#>
//    }
    
//    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
//        <#code#>
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! EditGroupCell_Coach
        
        //cell.delegate = self
        cell.generateCell(user: allMembers[indexPath.row], indexPath: indexPath)
        
        return cell
    }
    
    func updateParticipantsLabel() {
            
            participantsLabel.text = "PARTICIPANTS: \(allMembers.count)"
            
    //        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(self.createButtonPressed))]
            
            //self.navigationItem.rightBarButtonItem?.isEnabled = allMembers.count > 0
        }
    
//    func showIconOptions() {
//
//           let optionMenu = UIAlertController(title: "Choose group Icon", message: nil, preferredStyle: .actionSheet)
//
//           let takePhotoActio = UIAlertAction(title: "Take/Choose Photo", style: .default) { (alert) in
//
//               let imagePicker = ImagePickerController()
//               imagePicker.delegate = self
//               imagePicker.imageLimit = 1
//
//               self.present(imagePicker, animated: true, completion: nil)
//           }
//
//           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
//
//           }
//
//           if groupIcon != nil {
//
//               let resetAction = UIAlertAction(title: "Reset", style: .default) { (alert) in
//
//                   self.groupIcon = nil
//                   self.groupIconImageView.image = UIImage(named: "cameraIcon")
//                   self.editAvatarButtonOutlet.isHidden = true
//               }
//               optionMenu.addAction(resetAction)
//           }
//
//           optionMenu.addAction(takePhotoActio)
//           optionMenu.addAction(cancelAction)
//
//           if ( UI_USER_INTERFACE_IDIOM() == .pad )
//           {
//               if let currentPopoverpresentioncontroller = optionMenu.popoverPresentationController{
//
//                   currentPopoverpresentioncontroller.sourceView = editAvatarButtonOutlet
//                   currentPopoverpresentioncontroller.sourceRect = editAvatarButtonOutlet.bounds
//
//
//                   currentPopoverpresentioncontroller.permittedArrowDirections = .up
//                   self.present(optionMenu, animated: true, completion: nil)
//               }
//           } else {
//               self.present(optionMenu, animated: true, completion: nil)
//           }
//
//       }
    

}
