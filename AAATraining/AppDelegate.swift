//
//  AppDelegate.swift
//  AAATraining
//
//  Created by Margaret Dwan on 6/14/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit

// global var - to store all logged / registered user infromation

//changed in Video 56
//var currentUser: NSMutableDictionary?
var currentUser: Dictionary<String, Any>?
let DEFAULTS = UserDefaults.standard
let keyCURRENT_USER = "currentUser"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // loading current user
        currentUser = UserDefaults.standard.object(forKey: "currentUser") as? Dictionary<String, Any>
        
        print(currentUser as Any)
        
        // checking is the glob variable that stores current user's info is empty or not
        if currentUser?["id"] != nil {
            
            // accessing TabBar controller via Main.storyboard
            let TabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBar")
            
            // assigning TabBar as RootViewController of the project
            window?.rootViewController = TabBar
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

