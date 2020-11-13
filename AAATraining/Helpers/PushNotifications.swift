//
//  PushNotifications.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/24/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import Foundation
import OneSignal


var isNotificationsShowingArray: [String] = []

func sendPushNotification(memberToPush: [String], message: String) {
    
    var allUsers: [FUser] = []
    var indices: [Int] = []
    //isNotificationsShowingArray = []
    
    let updatedMembers = removeCurrentUserFromMembersArray(members: memberToPush)
    var index: [String] = []

    getUsersFromFirestore(withIds: updatedMembers) { (withUsers) in
        allUsers = []
        indices = []
        allUsers = withUsers
        for user in withUsers {
            let index = user.userTeamIDs.firstIndex(of: FUser.currentUser()!.userCurrentTeamID)!
            indices.append(index)
        }
        

    }
    
    
    getMembersToPush(members: updatedMembers) { (userPushIds) in
        var pushIDs = userPushIds
        var index = 0
        for pushID in userPushIds {
            print(allUsers.count)
            if pushID == "" || allUsers[index].userTeamNotifications[indices[index]] == "No" {
                if pushIDs.count == 1 {
                    pushIDs = []
                } else {
                    pushIDs.remove(at: index)
                }
                
            }

            index = index + 1
        }
        let currentUser = FUser.currentUser()!

        OneSignal.postNotification(["contents" : ["en" : "\(currentUser.firstname) \n \(message)"], "ios_badgeType" : "Increase", "ios_badgeCount" : 1, "include_player_ids" : pushIDs])
    }

}


func removeCurrentUserFromMembersArray(members: [String]) -> [String] {

    var updatedMembers : [String] = []

    for memberId in members {
        if memberId != FUser.currentId() {
            updatedMembers.append(memberId)
        }
    }

    return updatedMembers
}


func getMembersToPush(members: [String], completion: @escaping (_ usersArray: [String]) -> Void) {

    var pushIds: [String] = []
    var count = 0

    for memberId in members {

        reference(.User).document(memberId).getDocument { (snapshot, error) in

            guard let snapshot = snapshot else { completion(pushIds); return }

            if snapshot.exists {

                let userDictionary = snapshot.data()! as NSDictionary

                let fUser = FUser.init(_dictionary: userDictionary)
                
                pushIds.append(fUser.pushId!)
                count += 1
                

                if members.count == count {
                    completion(pushIds)
                }

            } else {
                completion(pushIds)
            }
        }
    }

}

//func getUsers(memberID : String) {
//    var query = reference(.User).whereField(kOBJECTID, isEqualTo: memberID)
//         query.getDocuments { (snapshot, error) in
//
//             if error != nil {
//                 print(error!.localizedDescription)
//                 return
//             }
//             guard let snapshot = snapshot else {
//                 return
//             }
//             if !snapshot.isEmpty {
//
//                 for userDictionary in snapshot.documents {
//
//                     let userDictionary = userDictionary.data() as NSDictionary
//                     let fUser = FUser(_dictionary: userDictionary)
//
//                     allUsers.append(fUser)
//                     let index = fUser.userTeamIDs.firstIndex(of: FUser.currentUser()!.userCurrentTeamID)!
//                     indices.append(index)
//                     isNotificationsShowingArray.append(fUser.userTeamNotifications[index])
//
//                 }
//             }
//     }
//}


