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
           print("Sinch did start")
   }
   
   func clientDidStop(_ client: SINClient!) {
       print("Sinch did stop")
   }
   
   func clientDidFail(_ client: SINClient!, error: Error!) {
       print("Sinch did fail \(error.localizedDescription)")
   }
    func voioRegistration() {
        
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    
    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
        
    }
    
    
    var tintColor = UINavigationBar.appearance().barTintColor
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
        
        
        //UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.1006183103, green: 0.2956552207, blue: 0.71825701, alpha: 1)
        //UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
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
//            //self.push.registerUserNotificationSettings()
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
        
        let selectionVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TeamSelectionVC") as! TeamSelectionVC

        selectionVC.modalPresentationStyle = .fullScreen

        self.window?.rootViewController = selectionVC
        
//        if accountType == "coach" {
//            print(FUser.currentId())
//            let TabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CoachTabBar") as! UITabBarController
//          self.window?.rootViewController = TabBar
//        } else if accountType == "parent" {
//            print(FUser.currentId())
//            let TabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ParentTabBar") as! UITabBarController
//          self.window?.rootViewController = TabBar
//        } else {
//            // accessing TabBar controller via Main.storyboard
//            let TabBar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
//          self.window?.rootViewController = TabBar
//        }
        


        
        
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
                
        if #available(iOS 13.0, *) {
            window?.rootViewController?.overrideUserInterfaceStyle = .light
            window?.overrideUserInterfaceStyle = .light
        }
        
        while top?.presentedViewController != nil {
            top = top?.presentedViewController
        }
        
        if top! is UITabBarController && top?.restorationIdentifier == "coach" {
            setBadges(controller: top as! UITabBarController, accountType: "coach")
            setCalendarBadges(controller: top as! UITabBarController, accountType: "coach")
        } else if top! is UITabBarController && top?.restorationIdentifier == "player" {
            setBadges(controller: top as! UITabBarController, accountType: "player")
            setCalendarBadges(controller: top as! UITabBarController, accountType: "player")
        } else if top! is UITabBarController && top?.restorationIdentifier == "parent" {
            setBadges(controller: top as! UITabBarController, accountType: "parent")
            //setCalendarBadges(controller: top as! UITabBarController, accountType: "parent")
        }
        
        
        if FUser.currentUser() != nil {
            updateCurrentUserInFirestore(withValues: [kISONLINE : true]) { (success) in
                
            }
        }
        appDelegate.locationManagerStart()
        locationManagerStart()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        if FUser.currentUser() != nil {
            updateCurrentUserInFirestore(withValues: [kISONLINE : true]) { (success) in
                
            }
        }
        appDelegate.locationManagerStart()
        locationManagerStart()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        
        recentBadgeHandler?.remove()
        calendarBadgeHandler?.remove()
        
        if FUser.currentUser() != nil {
            updateCurrentUserInFirestore(withValues: [kISONLINE : false]) { (success) in
                
            }
        }
        appDelegate.locationManagerStop()
        locationMangerStop()
        print("Entered background - SD...............................")
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
    
//    //MARK: PushNotification functions
//
//    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//
//        self.push.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
//
//
//    }
//
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//
//        let firebaseAuth = Auth.auth()
//        if firebaseAuth.canHandleNotification(userInfo) {
//            return
//        } else {
//            self.push.application(application, didReceiveRemoteNotification: userInfo)
//        }
//    }
//
//    //MARK: OneSignal
//
//    func startOneSignal() {
//
//        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
//
//        let userID = status.subscriptionStatus.userId
//        let pushToken = status.subscriptionStatus.pushToken
//
//        if pushToken != nil {
//            if let playerID = userID {
//                UserDefaults.standard.set(playerID, forKey: kPUSHID)
//            } else {
//                UserDefaults.standard.removeObject(forKey: kPUSHID)
//            }
//            UserDefaults.standard.synchronize()
//        }
//
//        //updateOneSignalId
//        updateOneSignalId()
//    }
//
//
//    //MARK: Sinch
//
//    func initSinchWithUserId(userId: String) {
//
//        if _client == nil {
//
//            _client = Sinch.client(withApplicationKey: kSINCHKEY, applicationSecret: kSINCHSECRET, environmentHost: "sandbox.sinch.com", userId: userId)
//
//            _client.delegate = self
//            _client.call()?.delegate = self
//
//            _client.setSupportCalling(true)
//            _client.enableManagedPushNotifications()
//            _client.start()
//            _client.startListeningOnActiveConnection()
//
//
//        }
//    }
//
//    //MARK: SinchManagedPushDelegate
//
//    func managedPush(_ managedPush: SINManagedPush!, didReceiveIncomingPushWithPayload payload: [AnyHashable : Any]!, forType pushType: String!) {
//
//        let result = SINPushHelper.queryPushNotificationPayload(payload)
//
//        if result!.isCall() {
//            print("incoming push payload")
//            self.handleRemoteNotification(userInfo: payload as NSDictionary)
//        }
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
////        if result!.isCall() && result!.call()!. {
////            self.presentMissedCallNotificationWithRemoteUserId(userId: result!.call()!.callId)
////        }
//
//    }
//
//    func presentMissedCallNotificationWithRemoteUserId(userId: String) {
//
//        if UIApplication.shared.applicationState == .background {
//
//            let center = UNUserNotificationCenter.current()
//
//            let content = UNMutableNotificationContent()
//            content.title = "Missed Call"
//            content.body = "From \(userId)"
//            content.sound = UNNotificationSound.default
//
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//
//            let request = UNNotificationRequest(identifier: "ContentIdentifier", content: content, trigger: trigger)
//
//            center.add(request) { (error) in
//
//                if error != nil {
//                    print("error on notification", error!.localizedDescription)
//                }
//            }
//        }
//    }
    
    //MARK: PKPushDelegate
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        
    }
    
//    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
//
//        print("did get incoming push")
//        self.handleRemoteNotification(userInfo: payload.dictionaryPayload as NSDictionary)
//
//    }
    
    //MARK: PKPushDelegate
    
//    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
//
//    }
    
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

