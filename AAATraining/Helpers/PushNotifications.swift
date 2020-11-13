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
    var allUserPushIDs: [String] = []
    var indices: [Int] = []
    
    //isNotificationsShowingArray = []
    
    var updatedMembers = removeCurrentUserFromMembersArray(members: memberToPush)
    var index: [String] = []

    getUsersFromFirestore(withIds: updatedMembers) { (withUsers) in
        allUsers = []
        indices = []
        allUserPushIDs = []
//        allUsers = withUsers
        for user in withUsers {
            if user.userTeamIDs.contains(FUser.currentUser()!.userCurrentTeamID) && user.pushId != "" {
                if !user.userTeamNotifications.isEmpty {
                    allUsers.append(user)
                    allUserPushIDs.append(user.pushId!)
                    let index = user.userTeamIDs.firstIndex(of: FUser.currentUser()!.userCurrentTeamID)!
                    indices.append(index)
                }
                
            } else if updatedMembers.contains(user.objectId) {
                var indexToRemove = updatedMembers.firstIndex(of: user.objectId)
                updatedMembers.remove(at: indexToRemove!)
            } else if updatedMembers.contains("") {
                var indexToRemove = updatedMembers.firstIndex(of: "")
                updatedMembers.remove(at: indexToRemove!)
            }
            
        }
        let currentUser = FUser.currentUser()!

//        OneSignal.postNotification(["contents" : ["en" : "\(currentUser.firstname) \n \(message)"], "ios_badgeType" : "Increase", "ios_badgeCount" : 1, "include_player_ids" : pushIDs])
        OneSignal.postNotification(["contents" : ["en" : "\(currentUser.firstname) \n \(message)"], "ios_badgeType" : "Increase", "ios_badgeCount" : 1, "include_player_ids" : allUserPushIDs])

    }
    
    
//    getMembersToPush(members: updatedMembers) { (userPushIds) in
//        var pushIDs = userPushIds
//        var index = 0
//        for pushID in pushIDs {
//            print(allUsers.count)
//            if pushID == "" ||  !allUsers[index].userTeamIDs.contains(FUser.currentUser()!.userCurrentTeamID) || allUsers[index].userTeamNotifications[indices[index]] == "No" {
//                
//                
//                    
//                     
//                        
//                        if pushIDs.count == 1 {
//                            pushIDs = []
//                        } else {
//                            pushIDs.remove(at: index)
//                        }
//                        
//                    
//                    
//                
//                
//                
//                
//            }
//
//            index += 1
//        }
//        let currentUser = FUser.currentUser()!
//
////        OneSignal.postNotification(["contents" : ["en" : "\(currentUser.firstname) \n \(message)"], "ios_badgeType" : "Increase", "ios_badgeCount" : 1, "include_player_ids" : pushIDs])
//        //OneSignal.postNotification(["contents" : ["en" : "\(currentUser.firstname) \n \(message)"], "ios_badgeType" : "Increase", "ios_badgeCount" : 1, "include_player_ids" : allUsers[k]])
//    }

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


