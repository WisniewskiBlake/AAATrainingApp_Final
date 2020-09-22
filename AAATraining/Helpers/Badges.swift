//
//  Badges.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/24/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import Foundation
import FirebaseFirestore

func recentBadgeCount(withBlock: @escaping(_ badgeNumber: Int) -> Void) {
    
    recentBadgeHandler = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).whereField(kRECENTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID).addSnapshotListener({ (snapshot, error) in
        
        var badge = 0
        var counter = 0
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            
            let recents = snapshot.documents
            
            for recent in recents {
                
                let currentRecent = recent.data() as NSDictionary
                
                badge += currentRecent[kCOUNTER] as! Int
                counter += 1
                
                if counter == recents.count {
                    withBlock(badge)
                }
            }
        } else {
            withBlock(badge)
        }
    })
}

func calendarBadgeCount(withBlock: @escaping(_ badgeNumber: Int) -> Void) {
    
    
    calendarBadgeHandler = reference(.Event).whereField(kEVENTUSERID, isEqualTo: FUser.currentId()).whereField(kEVENTTEAMID, isEqualTo: FUser.currentUser()?.userCurrentTeamID).addSnapshotListener({ (snapshot, error) in
        
        var badge = 0
        var counter = 0
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            
            let events = snapshot.documents
            
            for event in events {
                
                let currentEvent = event.data() as NSDictionary
                
                badge += currentEvent[kEVENTCOUNTER] as! Int
                counter += 1
                
                if counter == events.count {
                    withBlock(badge)
                }
            }
        } else {
            withBlock(badge)
        }
    })
}

func setBadges(controller: UITabBarController, accountType: String) {
    if accountType == "coach" || accountType == "player" {
        recentBadgeCount { (badge) in
            
            if badge != 0 {
                controller.tabBar.items![1].badgeValue = "\(badge)"
            } else {
                controller.tabBar.items![1].badgeValue = nil
            }
        }
    } else {
        recentBadgeCount { (badge) in
            
            if badge != 0 {
                controller.tabBar.items![0].badgeValue = "\(badge)"
            } else {
                controller.tabBar.items![0].badgeValue = nil
            }
        }
    }
    
    
}

func setCalendarBadges(controller: UITabBarController, accountType: String) {
    if accountType == "coach" || accountType == "player" {
        calendarBadgeCount { (badge) in
            
            if badge != 0 {
                controller.tabBar.items![2].badgeValue = "\(badge)"
            } else {
                controller.tabBar.items![2].badgeValue = nil
            }
        }
    } else if accountType == "parent"{
        calendarBadgeCount { (badge) in
            
            if badge != 0 {
                controller.tabBar.items![0].badgeValue = "\(badge)"
            } else {
                controller.tabBar.items![0].badgeValue = nil
            }
        }
    }
    
    
}
