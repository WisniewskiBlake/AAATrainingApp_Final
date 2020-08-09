//
//  SceneDelegate.swift
//  AAATraining
//
//  Created by Margaret Dwan on 6/14/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import UIKit
import UIKit
import Firebase
import FirebaseCore
import CoreLocation
import PushKit
import FirebaseAuth
import Sinch
import OneSignal

class SceneDelegate: UIResponder, UIWindowSceneDelegate, CLLocationManagerDelegate, PKPushRegistryDelegate, SINClientDelegate, SINCallClientDelegate, SINManagedPushDelegate {
    func clientDidStart(_ client: SINClient!) {
        
    }
    
    func clientDidFail(_ client: SINClient!, error: Error!) {
        
    }
    
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
        
    }
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?
    var locationManager: CLLocationManager?
    var coordinates: CLLocationCoordinate2D?
    
    var _client: SINClient!
    var push: SINManagedPush!
    
//    var ref = Database.database().reference()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).      
        
        
        //AutoLogin
        authListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
            
            Auth.auth().removeStateDidChangeListener(self.authListener!)
            
            if user != nil {
                
                if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
                    
                    DispatchQueue.main.async {
                        self.goToApp()

                    }
                }
            }
        })
        
//        self.voioRegistration()
//
//        self.push = Sinch.managedPush(with: .development)
//        self.push.delegate = self
//        self.push.setDesiredPushTypeAutomatically()
//
//        func userDidLogin(userId: String) {
//            self.push.registerUserNotificationSettings()
//            self.initSinchWithUserId(userId: userId)
//            self.startOneSignal()
//        }
//
//        NotificationCenter.default.addObserver(forName: NSNotification.Name(USER_DID_LOGIN_NOTIFICATION), object: nil, queue: nil) { (note) in
//
//            let userId = note.userInfo![kUSERID] as! String
//            UserDefaults.standard.set(userId, forKey: kUSERID)
//            UserDefaults.standard.synchronize()
//
//            userDidLogin(userId: userId)
//        }

        

        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func goToApp() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
        //var accountType = ""
        let user = FUser.currentUser()!
        let accountType = user.accountType
        
        if accountType == "coach" {
            print(FUser.currentId())
            let TabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CoachTabBar")
          self.window?.rootViewController = TabBar
        } else if accountType == "parent" {
            print(FUser.currentId())
            let TabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParentTabBar")
          self.window?.rootViewController = TabBar
        } else {
            // accessing TabBar controller via Main.storyboard
            let TabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBar")
          self.window?.rootViewController = TabBar
        }
        


        
        
    }
   

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        var top = self.window?.rootViewController
                
        appDelegate.locationManagerStart()
        
        while top?.presentedViewController != nil {
            top = top?.presentedViewController
        }
        
        if top! is UITabBarController {
            setBadges(controller: top as! UITabBarController)
            setCalendarBadges(controller: top as! UITabBarController)
        }
        
        
        if FUser.currentUser() != nil {
            updateCurrentUserInFirestore(withValues: [kISONLINE : true]) { (success) in
                
            }
        }
        
        locationManagerStart()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        
        appDelegate.locationManagerStop()
        
        recentBadgeHandler?.remove()
        
        calendarBadgeHandler?.remove()
        if FUser.currentUser() != nil {
            updateCurrentUserInFirestore(withValues: [kISONLINE : false]) { (success) in
                
            }
        }

        locationMangerStop()
    }
    

    
    //MARK: Location manger
    
    func locationManagerStart() {
        
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
        }
        
        locationManager!.startUpdatingLocation()
    }

    func locationMangerStop() {
        
        if locationManager != nil {
            locationManager!.stopUpdatingLocation()
        }
    }
    
    //MARK: Location Manager delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("faild to get location")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted:
            print("restricted")
        case .denied:
            locationManager = nil
            print("denied location access")
            break
        @unknown default:
            print("Error")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        coordinates = locations.last!.coordinate
    }
    
    //MARK: PKPushDelegate
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
    }
    
//    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
//
//        print("did get incoming push")
//        self.handleRemoteNotification(userInfo: payload.dictionaryPayload as NSDictionary)
//
//    }
//
//    func handleRemoteNotification(userInfo: NSDictionary) {
//
//        if _client == nil {
//            let userId = UserDefaults.standard.object(forKey: kUSERID)
//
//            if userId != nil {
//                self.initSinchWithUserId(userId: userId as! String)
//            }
//        }
//
//
//        let result = self._client.relayRemotePushNotification(userInfo as! [AnyHashable : Any])
//
//        if result!.isCall() {
//            print("handle call notification")
//        }
//
//        if result!.isCall() && result!.call()!.isCallCanceled {
//            self.presentMissedCallNotificationWithRemoteUserId(userId: result!.call()!.callId)
//        }
//
//    }


}

