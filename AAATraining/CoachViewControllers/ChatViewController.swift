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
    }
    // pre-load func
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
    
            navigationController?.setNavigationBarHidden(true, animated: true)
            
        }
    

    

}
