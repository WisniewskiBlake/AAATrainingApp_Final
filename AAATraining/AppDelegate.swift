//
//  AppDelegate.swift
//  AAATraining
//
//  Created by Margaret Dwan on 6/14/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import Firebase

// global var - to store all logged / registered user infromation

//changed in Video 56
//var currentUser: NSMutableDictionary?
var currentUser: Dictionary<String, Any>?
var currentUser_ava: UIImage?
//var currentUser_accountType = "0"
let DEFAULTS = UserDefaults.standard
let keyCURRENT_USER = "currentUser"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        // loading current user
        currentUser = DEFAULTS.object(forKey: "currentUser") as? Dictionary<String, Any>
        
        
        // checking is the glob variable that stores current user's info is empty or not
        if currentUser?["id"] != nil {
            let weight = currentUser?["weight"] as! String
            
            if weight == "123456789" {
                let TabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CoachTabBar")
                window?.rootViewController = TabBar
            } else {
                // accessing TabBar controller via Main.storyboard
                let TabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBar")
                window?.rootViewController = TabBar
            }
            
            
            // assigning TabBar as RootViewController of the project
            
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

