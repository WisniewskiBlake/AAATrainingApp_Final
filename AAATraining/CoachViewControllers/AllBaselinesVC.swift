//
//  AllBaselinesVC.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/21/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

class AllBaselinesVC: UIViewController {
        
    @IBOutlet weak var gridCollectionView: UICollectionView! {
        didSet {
            gridCollectionView.bounces = false
        }
    }
    
    @IBOutlet weak var gridLayout: StickyGridCollectionViewLayout! {
        didSet {
            gridLayout.stickyRowsCount = 1
            gridLayout.stickyColumnsCount = 1
        }
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

extension AllBaselinesVC: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 100
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AllBaselinesCell", for: indexPath) as? AllBaselinesCell else {
            return UICollectionViewCell()
        }

        cell.dataLabel.text = "\(indexPath)"
        cell.backgroundColor = gridLayout.isItemSticky(at: indexPath) ? .groupTableViewBackground : .white
        return cell
    }
}

extension AllBaselinesVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    
}
