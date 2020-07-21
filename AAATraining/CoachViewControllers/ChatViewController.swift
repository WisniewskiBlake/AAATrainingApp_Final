//
//  ChatViewController.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/20/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore

class ChatViewController: JSQMessagesViewController {
    
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleRed())
    
    var incomingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())

    override func viewDidLoad() {
        super.viewDidLoad()

        self.senderId = FUser.currentId()
        
        self.senderDisplayName = FUser.currentUser()!.firstname
        
        //fix for Ipgone x
        let constraint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        
        constraint.priority = UILayoutPriority(rawValue: 1000)
        
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        //end of iphone x fix
    }
    
    //fix for Iphone x
    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
    //end of iphone x fix
    
    
    // pre-load func
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
    
            navigationController?.setNavigationBarHidden(true, animated: true)
            
        }
    

    

}
extension JSQMessagesInputToolbar {

override open func didMoveToWindow() {

super.didMoveToWindow()

guard let window = window else { return }

if #available(iOS 11.0, *) {

let anchor = window.safeAreaLayoutGuide.bottomAnchor

bottomAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: anchor, multiplier: 1.0).isActive = true

}

}

}
