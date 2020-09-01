//
//  NewGroupVC_Coach.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/24/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import ProgressHUD
import ImagePicker


class NewGroupVC_Coach: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GroupMemberCell_CoachDelegate, ImagePickerDelegate {
    //MARK: ImagePickerControllerDelegate
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        if images.count > 0 {
            self.groupIcon = images.first!
            self.groupIconImageView.image = self.groupIcon!.circleMasked
            self.editAvatarButtonOutlet.isHidden = false
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var editAvatarButtonOutlet: UIButton!
    @IBOutlet weak var groupIconImageView: UIImageView!
    @IBOutlet weak var groupSubjectTextField: UITextField!
    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var memberIds: [String] = []
    var allMembers: [FUser] = []
    var groupIcon: UIImage?

    @IBOutlet var iconTapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: FUser.currentUser()!.userTeamColorOne)
        groupIconImageView.isUserInteractionEnabled = true
        groupIconImageView.addGestureRecognizer(iconTapGesture)
        
        updateParticipantsLabel()
    }
    
    //MARK: IBActions
    
    @objc func createButtonPressed(_ sender: Any) {
        
        
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        showIconOptions()
    }
    
    @IBAction func groupIconTapped(_ sender: Any) {
        showIconOptions()
    }
    
    //MARK: CollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allMembers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! GroupMemberCell_Coach
        
        cell.delegate = self
        cell.generateCell(user: allMembers[indexPath.row], indexPath: indexPath)
        
        return cell
    }
    
    func didClickDeleteButton(indexPath: IndexPath) {
        allMembers.remove(at: indexPath.row)
        memberIds.remove(at: indexPath.row)
        
        collectionView.reloadData()
        updateParticipantsLabel()
    }
    
    //MARK: HelperFunctions
    
    func showIconOptions() {

        let optionMenu = UIAlertController(title: "Choose Group Icon", message: nil, preferredStyle: .actionSheet)

        let takePhotoActio = UIAlertAction(title: "Choose Photo", style: .default) { (alert) in

            let imagePicker = ImagePickerController()
            imagePicker.delegate = self
            imagePicker.imageLimit = 1

            self.present(imagePicker, animated: true, completion: nil)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in

        }

        if groupIcon != nil {

            let resetAction = UIAlertAction(title: "Reset", style: .default) { (alert) in

                self.groupIcon = nil
                self.groupIconImageView.image = UIImage(named: "cameraIcon")
                self.editAvatarButtonOutlet.isHidden = true
            }
            optionMenu.addAction(resetAction)
        }

        optionMenu.addAction(takePhotoActio)
        optionMenu.addAction(cancelAction)

        if ( UI_USER_INTERFACE_IDIOM() == .pad )
        {
            if let currentPopoverpresentioncontroller = optionMenu.popoverPresentationController{

                currentPopoverpresentioncontroller.sourceView = editAvatarButtonOutlet
                currentPopoverpresentioncontroller.sourceRect = editAvatarButtonOutlet.bounds


                currentPopoverpresentioncontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            self.present(optionMenu, animated: true, completion: nil)
        }

    }
    @IBAction func createButtonClicked(_ sender: Any) {
        if groupSubjectTextField.text != "" {
            
            memberIds.append(FUser.currentId())
            
            let avatarData = UIImage(named: "groupIcon")!.jpegData(compressionQuality: 0.7)!
            var avatar = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            if groupIcon != nil {
                
                let avatarData = groupIcon!.jpegData(compressionQuality: 0.4)!
                avatar = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            }
            
            let groupId = UUID().uuidString
            
            let group = Group_Coach(groupId: groupId, subject: groupSubjectTextField.text!, ownerId: FUser.currentId(), members: memberIds, avatar: avatar)
            
            group.saveGroup()
            
            startGroupChat(group: group)
            
            let chatVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatVC_Coach
            
            chatVC.title = group.groupDictionary[kNAME] as? String
            chatVC.memberIds = group.groupDictionary[kMEMBERS] as? [String]
            chatVC.membersToPush = group.groupDictionary[kMEMBERS] as? [String]
            chatVC.allMembers = self.allMembers
            chatVC.chatRoomId = groupId
            
            chatVC.isGroup = true
            chatVC.hidesBottomBarWhenPushed = true
            
            
            self.navigationController?.pushViewController(chatVC, animated: true)
            
        } else {
            ProgressHUD.showError("Subject is required!")
        }
    }
    
    func updateParticipantsLabel() {
        
        participantsLabel.text = "PARTICIPANTS: \(allMembers.count)"
        
//        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(self.createButtonPressed))]
        
        self.navigationItem.rightBarButtonItem?.isEnabled = allMembers.count > 0
    }
    


    

}
