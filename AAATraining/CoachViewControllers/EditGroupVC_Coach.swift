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



class EditGroupVC_Coach: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, EditGroupCell_CoachDelegate, ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        <#code#>
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        <#code#>
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        <#code#>
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var groupSubjectTextField: UITextField!
    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    

}
