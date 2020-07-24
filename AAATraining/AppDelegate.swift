//
//  AppDelegate.swift
//  AAATraining
//
//  Created by Margaret Dwan on 6/14/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import CoreLocation
import PushKit
import FirebaseAuth
// global var - to store all logged / registered user infromation

//changed in Video 56
//var currentUser: NSMutableDictionary?
var currentUser1: Dictionary<String, Any>?
var currentUser_ava: UIImage?
//var currentUser_accountType = "0"
let DEFAULTS = UserDefaults.standard
let keyCURRENT_USER = "currentUser1"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, PKPushRegistryDelegate {
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
    }
    

    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?
    
    var locationManager: CLLocationManager?
    var coordinates: CLLocationCoordinate2D?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        

        
        


        
        
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
    
    func goToApp() {
        // loading current user
        currentUser1 = DEFAULTS.object(forKey: "currentUser1") as? Dictionary<String, Any>
           NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        
        // checking is the glob variable that stores current user's info is empty or not
        if currentUser1?["id"] != nil {
            let weight = currentUser1?["weight"] as! String

            if weight == "123456789" {
                let TabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CoachTabBar")
                window?.rootViewController = TabBar
            } else {
                // accessing TabBar controller via Main.storyboard
                let TabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBar")
                window?.rootViewController = TabBar
            }


        }
           
//           let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainApplication") as! UITabBarController
//
//           self.window?.rootViewController = mainView
       }


}



