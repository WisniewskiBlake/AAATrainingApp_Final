//
//  GridCollectionViewLayout.swift
//  StickyGridCollectionView-Starter
//
//  Created by Vadim Bulavin on 10/1/18.
//  Copyright © 2018 Vadim Bulavin. All rights reserved.
//

import UIKit

class StickyGridCollectionViewLayout: UICollectionViewFlowLayout {
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: 10_000, height: 10_000)
    }

}
