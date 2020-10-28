//
//  CollectionReference.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/19/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import Foundation
import FirebaseFirestore


enum FCollectionReference: String {
    case User
    case Typing
    case Recent
    case Message
    case Group
    case Call
    case Post
    case Event
    case Baseline
    case Nutrition
    case Team
    case TeamEventCache
    case PlayerStat
}


func reference(_ collectionReference: FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}
