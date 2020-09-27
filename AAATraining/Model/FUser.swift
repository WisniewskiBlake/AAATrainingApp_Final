//
//  FUser.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/19/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

public class FUser {
    
    let objectId: String
    var pushId: String?
    
    let createdAt: Date
    var updatedAt: Date
    
    var email: String
    var firstname: String
    var lastname: String
    var fullname: String
    var ava: String
    var isOnline: Bool
    var phoneNumber: String
    
    var height: String
    var weight: String
    var position: String
    var number: String
    
    var accountType: String
    var birthday: String
    var cover: String
    
    var userCurrentTeamID: String
    var userTeamColorOne: String
    var userTeamColorTwo: String
    var userTeamColorThree: String
    
    var userTeamIDs: [String]
    var userTeamAccountTypes: [String]
    var userTeamNames: [String]
    var userTeamMembers: [String]
    var userTeamMemberCount: [String]
    var userIsNewObserverArray: [String]
    
    var contacts: [String]
    var blockedUsers: [String]
    let loginMethod: String
    
    //MARK: Initializers
    
    init(_objectId: String, _pushId: String?, _createdAt: Date, _updatedAt: Date, _email: String, _firstname: String, _lastname: String, _avatar: String = "", _loginMethod: String, _phoneNumber: String, _height: String, _weight: String, _position: String, _number: String, _accountType: String, _birthday: String, _cover: String, _userCurrentTeamID: String, _userTeamColorOne: String, _userTeamColorTwo: String, _userTeamColorThree: String, _userTeamIDs: [String], _userTeamAccountTypes: [String], _userTeamNames: [String], _userTeamMembers: [String], _userTeamMemberCount: [String], _userIsNewObserverArray: [String]) {
        
        objectId = _objectId
        pushId = _pushId
        createdAt = _createdAt
        updatedAt = _updatedAt
        email = _email
        firstname = _firstname
        lastname = _lastname
        fullname = _firstname + " " + _lastname
        ava = _avatar
        isOnline = true
        height = _height
        weight = _weight
        position = _position
        number = _number
        accountType = _accountType
        birthday = _birthday
        cover = _cover
        userCurrentTeamID = _userCurrentTeamID
        userTeamColorOne = _userTeamColorOne
        userTeamColorTwo = _userTeamColorTwo
        userTeamColorThree = _userTeamColorThree
        loginMethod = _loginMethod
        phoneNumber = _phoneNumber
        blockedUsers = []
        contacts = []
        userTeamIDs = _userTeamIDs
        userTeamAccountTypes = _userTeamAccountTypes
        userTeamNames = _userTeamNames
        userTeamMembers = _userTeamMembers
        userTeamMemberCount = _userTeamMemberCount
        userIsNewObserverArray = _userIsNewObserverArray
    }
    
    init() {
        objectId = ""
        pushId = ""
        createdAt = Date()
        updatedAt = Date()
        email = ""
        firstname = ""
        lastname = ""
        fullname = ""
        ava = ""
        isOnline = true
        height = ""
        weight = ""
        position = ""
        number = ""
        accountType = ""
        birthday = ""
        cover = ""
        userCurrentTeamID = ""
        userTeamColorOne = ""
        userTeamColorTwo = ""
        userTeamColorThree = ""
        loginMethod = ""
        phoneNumber = ""
        blockedUsers = []
        contacts = []
        userTeamIDs = []
        userTeamAccountTypes = []
        userTeamNames = []
        userTeamMembers = []
        userTeamMemberCount = []
        userIsNewObserverArray = []
    }
    
    
    
    init(_dictionary: NSDictionary) {
        let helper = Helper()
        objectId = _dictionary[kOBJECTID] as! String
        pushId = _dictionary[kPUSHID] as? String
        
        if let created = _dictionary[kCREATEDAT] {
            if (created as! String).count != 14 {
                createdAt = Date()
            } else {               
                createdAt = helper.dateFormatter().date(from: created as! String)!
            }
        } else {
            createdAt = Date()
        }
        if let updateded = _dictionary[kUPDATEDAT] {
            if (updateded as! String).count != 14 {
                updatedAt = Date()
            } else {
                updatedAt = helper.dateFormatter().date(from: updateded as! String)!
            }
        } else {
            updatedAt = Date()
        }
        
        if let mail = _dictionary[kEMAIL] {
            email = mail as! String
        } else {
            email = ""
        }
        if let fname = _dictionary[kFIRSTNAME] {
            firstname = fname as! String
        } else {
            firstname = ""
        }
        if let lname = _dictionary[kLASTNAME] {
            lastname = lname as! String
        } else {
            lastname = ""
        }
        fullname = firstname + " " + lastname
        if let avat = _dictionary[kAVATAR] {
            ava = avat as! String
        } else {
            ava = ""
        }
        if let onl = _dictionary[kISONLINE] {
            isOnline = onl as! Bool
        } else {
            isOnline = false
        }
        if let phone = _dictionary[kPHONE] {
            phoneNumber = phone as! String
        } else {
            phoneNumber = ""
        }
        
        if let cont = _dictionary[kCONTACT] {
            contacts = cont as! [String]
        } else {
            contacts = []
        }
        if let block = _dictionary[kBLOCKEDUSERID] {
            blockedUsers = block as! [String]
        } else {
            blockedUsers = []
        }
        if let lgm = _dictionary[kLOGINMETHOD] {
            loginMethod = lgm as! String
        } else {
            loginMethod = ""
        }
        if let hgt = _dictionary[kHEIGHT] {
            height = hgt as! String
        } else {
            height = ""
        }
        if let wgt = _dictionary[kWEIGHT] {
            weight = wgt as! String
        } else {
            weight = ""
        }
        if let pos = _dictionary[kPOSITION] {
            position = pos as! String
        } else {
            position = ""
        }
        if let nmbr = _dictionary[kNUMBER] {
            number = nmbr as! String
        } else {
            number = ""
        }
        if let accT = _dictionary[kACCOUNTTYPE] {
            accountType = accT as! String
        } else {
            accountType = ""
        }
        if let bDay = _dictionary[kBIRTHDAY] {
            birthday = bDay as! String
        } else {
            birthday = ""
        }
        if let cvr = _dictionary[kCOVER] {
            cover = cvr as! String
        } else {
            cover = ""
        }
        if let tmID = _dictionary[kUSERCURRENTTEAMID] {
            userCurrentTeamID = tmID as! String
        } else {
            userCurrentTeamID = ""
        }
        if let tCO = _dictionary[kUSERTEAMCOLORONE] {
            userTeamColorOne = tCO as! String
        } else {
            userTeamColorOne = ""
        }
        if let tCT = _dictionary[kUSERTEAMCOLORTWO] {
            userTeamColorTwo = tCT as! String
        } else {
            userTeamColorTwo = ""
        }
        if let tCTH = _dictionary[kUSERTEAMCOLORTHREE] {
            userTeamColorThree = tCTH as! String
        } else {
            userTeamColorThree = ""
        }
        if let tIDs = _dictionary[kUSERTEAMIDS] {
            userTeamIDs = tIDs as! [String]
        } else {
            userTeamIDs = []
        }
        if let tACs = _dictionary[kUSERTEAMACCOUNTTYPES] {
            userTeamAccountTypes = tACs as! [String]
        } else {
            userTeamAccountTypes = []
        }
        if let tNs = _dictionary[kUSERTEAMNAMES] {
            userTeamNames = tNs as! [String]
        } else {
            userTeamNames = []
        }
        if let tMs = _dictionary[kUSERTEAMMEMBERS] {
            userTeamMembers = tMs as! [String]
        } else {
            userTeamMembers = []
        }
        if let tMC = _dictionary[kUSERTEAMMEMBERCOUNT] {
            userTeamMemberCount = tMC as! [String]
        } else {
            userTeamMemberCount = []
        }
        if let isO = _dictionary[kUSERISNEWOBSERVERARRAY] {
            userIsNewObserverArray = isO as! [String]
        } else {
            userIsNewObserverArray = []
        }
        
        
     }
    
    
    //MARK: Returning current user funcs
    
    class func currentId() -> String {
        
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser () -> FUser? {
        
        if Auth.auth().currentUser != nil {
            
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
                
                return FUser.init(_dictionary: dictionary as! NSDictionary)
            }
        }
        
        return nil
        
    }
    
    
    
    //MARK: Login function
    
    class func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (firUser, error) in
            
            if error != nil {
                
                completion(error)
                return
                
            } else {
                
                //get user from firebase and save locally
//                fetchCurrentUserFromFirestore(userId: firUser!.user.uid)
//                completion(error)
                //check if user exist - login else register
                           fetchCurrentUserFromFirestore(userId: firUser!.user.uid, completion: { (user) in

                               if user != nil && user!.firstname != "" {
                                   //we have user, login

                                   saveUserLocally(fUser: user!)
                                   saveUserToFirestore(fUser: user!)

                                   completion(error)

                               } else {

//                                   //    we have no user, register
//                                   let fUser = FUser(_objectId: firUser!.user.uid, _pushId: "", _createdAt: Date(), _updatedAt: Date(), _email: "", _firstname: "", _lastname: "", _avatar: "", _loginMethod: kPHONE, _phoneNumber: firUser!.user.phoneNumber!, _height: "", _weight: "", _position: "", _number: "", _accountType: "", _birthday: "", _cover: "")
//
//                                   saveUserLocally(fUser: fUser)
//                                   saveUserToFirestore(fUser: fUser)
//                                   completion(error)

                               }

                           })
                
            }
            
        })
        
    }
    
    //MARK: Register functions
    
    class func registerUserWith(email: String, password: String, firstName: String, lastName: String, avatar: String, height: String, weight: String, position: String, number: String, accountType: String, birthday: String, cover: String, phoneNumber: String, userCurrentTeamID: String, userTeamColorOne: String, userTeamColorTwo: String, userTeamColorThree: String, userTeamIDs: [String], userTeamAccountTypes: [String], userTeamNames: [String], userTeamMembers: [String], userTeamMemberCount: [String], userIsNewObserverArray: [String], completion: @escaping (_ error: Error?) -> Void ) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (firuser, error) in
            
            if error != nil {
                
                completion(error)
                return
            }
                    
            let fUser = FUser(_objectId: firuser!.user.uid, _pushId: "", _createdAt: Date(), _updatedAt: Date(), _email: firuser!.user.email!, _firstname: firstName, _lastname: lastName, _avatar: avatar, _loginMethod: kEMAIL, _phoneNumber: phoneNumber, _height: height, _weight: weight, _position: position, _number: number,  _accountType: accountType, _birthday: birthday, _cover: cover, _userCurrentTeamID: userCurrentTeamID, _userTeamColorOne: userTeamColorOne, _userTeamColorTwo: userTeamColorTwo, _userTeamColorThree: userTeamColorThree, _userTeamIDs: userTeamIDs, _userTeamAccountTypes: userTeamAccountTypes, _userTeamNames: userTeamNames, _userTeamMembers: userTeamMembers, _userTeamMemberCount: userTeamMemberCount, _userIsNewObserverArray: userIsNewObserverArray)
            
            
            saveUserLocally(fUser: fUser)
            saveUserToFirestore(fUser: fUser)
            completion(error)
            
        })
        
    }
    
    //phoneNumberRegistration
    
    class func registerUserWith(phoneNumber: String, verificationCode: String, verificationId: String!, completion: @escaping (_ error: Error?, _ shouldLogin: Bool) -> Void) {


        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: verificationCode)
//        Auth.auth().signInAndRetrieveData(with: credential) { (firuser, error) in
        Auth.auth().signIn(with: credential) { (firuser, error) in

            if error != nil {

                completion(error!, false)
                return
            }

            //check if user exist - login else register
            fetchCurrentUserFromFirestore(userId: firuser!.user.uid, completion: { (user) in

                if user != nil && user!.firstname != "" {
                    //we have user, login

                    saveUserLocally(fUser: user!)
                    saveUserToFirestore(fUser: user!)

                    completion(error, true)

                } else {

                    //    we have no user, register
                    let fUser = FUser(_objectId: firuser!.user.uid, _pushId: "", _createdAt: Date(), _updatedAt: Date(), _email: "", _firstname: "", _lastname: "", _avatar: "", _loginMethod: kPHONE, _phoneNumber: firuser!.user.phoneNumber!, _height: "", _weight: "", _position: "", _number: "", _accountType: "", _birthday: "", _cover: "", _userCurrentTeamID: "", _userTeamColorOne: "", _userTeamColorTwo: "", _userTeamColorThree: "", _userTeamIDs: [""], _userTeamAccountTypes: [""], _userTeamNames: [""], _userTeamMembers: [""], _userTeamMemberCount: [], _userIsNewObserverArray: [])

                    saveUserLocally(fUser: fUser)
                    saveUserToFirestore(fUser: fUser)
                    completion(error, false)

                }

            })

        }

    }
    
    
    //MARK: LogOut func
    
    class func logOutCurrentUser(completion: @escaping (_ success: Bool) -> Void) {
        
        userDefaults.removeObject(forKey: kPUSHID)
        removeOneSignalId()
        
        userDefaults.removeObject(forKey: kCURRENTUSER)
        userDefaults.synchronize()
        
        do {
            try Auth.auth().signOut()
            
            completion(true)
            
        } catch let error as NSError {
            completion(false)
            print(error.localizedDescription)
            
        }
        
        
    }
    
    //MARK: Delete user
    
    class func deleteUser(completion: @escaping (_ error: Error?) -> Void) {
        
        let user = Auth.auth().currentUser
        
        user?.delete(completion: { (error) in
            
            completion(error)
        })
        
    }
    
} //end of class funcs




//MARK: Save user funcs

func saveUserToFirestore(fUser: FUser) {
    reference(.User).document(fUser.objectId).setData(userDictionaryFrom(user: fUser) as! [String : Any]) { (error) in
        
        print("error is \(String(describing: error?.localizedDescription))")
    }
}


func saveUserLocally(fUser: FUser) {
    
    UserDefaults.standard.set(userDictionaryFrom(user: fUser), forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
}


//MARK: Fetch User funcs

//New firestore
func fetchCurrentUserFromFirestore(userId: String) {
    
    reference(.User).document(userId).getDocument { (snapshot, error) in
        
        guard let snapshot = snapshot else {  return }
        
        if snapshot.exists {
            print("updated current users param")
            print(snapshot)
            
            UserDefaults.standard.setValue(snapshot.data()! as NSDictionary, forKeyPath: kCURRENTUSER)
            //UserDefaults.standard.setValue(snapshot.data()! as NSDictionary, forKeyPath: kACCOUNTTYPE)
            UserDefaults.standard.synchronize()
            
        }
        
    }
    
}


func fetchCurrentUserFromFirestore(userId: String, completion: @escaping (_ user: FUser?)->Void) {
    
    reference(.User).document(userId).getDocument { (snapshot, error) in
        
        guard let snapshot = snapshot else {  return }
        
        if snapshot.exists {
            
            let user = FUser(_dictionary: snapshot.data()! as NSDictionary)
            completion(user)
        } else {
            completion(nil)
        }
        
    }
}

func fetchUserFromFirestore(userId: String, completion: @escaping (_ user: FUser?)->Void) {
    
    reference(.User).document(userId).getDocument { (snapshot, error) in
        
        guard let snapshot = snapshot else {  return }
        
        if snapshot.exists {
            
            let user = FUser(_dictionary: snapshot.data()! as NSDictionary)
            completion(user)
        } else {
            completion(nil)
        }
        
    }
}


//MARK: Helper funcs

func userDictionaryFrom(user: FUser) -> NSDictionary {
    
    let helper = Helper()
    
    let createdAt = helper.dateFormatter().string(from: user.createdAt)
    let updatedAt = helper.dateFormatter().string(from: user.updatedAt)
    
    return NSDictionary(objects: [user.objectId,  createdAt, updatedAt, user.email, user.loginMethod, user.pushId!, user.firstname, user.lastname, user.ava, user.contacts, user.blockedUsers, user.isOnline, user.phoneNumber, user.height, user.weight, user.position, user.number, user.birthday, user.cover, user.accountType, user.userCurrentTeamID, user.userTeamColorOne, user.userTeamColorTwo, user.userTeamColorThree, user.userTeamIDs, user.userTeamAccountTypes, user.userTeamNames, user.userTeamMembers, user.userTeamMemberCount, user.userIsNewObserverArray], forKeys: [kOBJECTID as NSCopying, kCREATEDAT as NSCopying, kUPDATEDAT as NSCopying, kEMAIL as NSCopying, kLOGINMETHOD as NSCopying, kPUSHID as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kAVATAR as NSCopying, kCONTACT as NSCopying, kBLOCKEDUSERID as NSCopying, kISONLINE as NSCopying, kPHONE as NSCopying, kHEIGHT as NSCopying, kWEIGHT as NSCopying, kPOSITION as NSCopying, kNUMBER as NSCopying, kBIRTHDAY as NSCopying, kCOVER as NSCopying, kACCOUNTTYPE as NSCopying, kUSERCURRENTTEAMID as NSCopying, kUSERTEAMCOLORONE as NSCopying, kUSERTEAMCOLORTWO as NSCopying, kUSERTEAMCOLORTHREE as NSCopying, kUSERTEAMIDS as NSCopying, kUSERTEAMACCOUNTTYPES as NSCopying, kUSERTEAMNAMES as NSCopying, kUSERTEAMMEMBERS as NSCopying, kUSERTEAMMEMBERCOUNT as NSCopying, kUSERISNEWOBSERVERARRAY as NSCopying])
    
    
    
}

func getUsersFromFirestore(withIds: [String], completion: @escaping (_ usersArray: [FUser]) -> Void) {
    
    var count = 0
    var usersArray: [FUser] = []
    
    //go through each user and download it from firestore
    for userId in withIds {
        
        reference(.User).document(userId).getDocument { (snapshot, error) in
            
            guard let snapshot = snapshot else {  return }
            
            if snapshot.exists {
                
                let user = FUser(_dictionary: snapshot.data()! as NSDictionary)
                count += 1
                
                //dont add if its current user
                if user.objectId != FUser.currentId() {
                    usersArray.append(user)
                }
                
            } else {
                completion(usersArray)
            }
            
            if count == withIds.count {
                //we have finished, return the array
                completion(usersArray)
            }
            
        }
        
    }
}

func updateUser(userID: String, withValues: [String:Any]) {
    reference(.User).document(userID).updateData(withValues)
    
}

func updateCurrentUserInFirestore(withValues : [String : Any], completion: @escaping (_ error: Error?) -> Void) {
    
    let helper = Helper()
    
    if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
        
        var tempWithValues = withValues
        
        let currentUserId = FUser.currentId()
        
        let updatedAt = helper.dateFormatter().string(from: Date())
        
        tempWithValues[kUPDATEDAT] = updatedAt
        
        let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
        
        userObject.setValuesForKeys(tempWithValues)
        
        reference(.User).document(currentUserId).updateData(withValues) { (error) in
            
            if error != nil {
                
                completion(error)
                return
            }
            
            //update current user
            UserDefaults.standard.setValue(userObject, forKeyPath: kCURRENTUSER)
            UserDefaults.standard.synchronize()
            
            completion(error)
        }
        
    }
}

func updateUserInFirestore(objectID: String, withValues : [String : Any], completion: @escaping (_ error: Error?) -> Void) {
    
    let helper = Helper()
    
        
    var tempWithValues = withValues
    
    let currentUserId = objectID
    
    let updatedAt = helper.dateFormatter().string(from: Date())
    
    tempWithValues[kUPDATEDAT] = updatedAt
        
    reference(.User).document(currentUserId).updateData(withValues) { (error) in
        
        if error != nil {
            
            completion(error)
            return
        }
        
        completion(error)
    }
        
    
}

//func updateUsersCoverInFirestore(teamID: String, withValues : [String : Any], completion: @escaping (_ error: Error?) -> Void) {
//    
//    let currentTeamId = teamID
//    
//    reference(.User).document().updateData(<#T##fields: [AnyHashable : Any]##[AnyHashable : Any]#>).
//    
//    reference(.User).document(currentTeamId).updateData(withValues) { (error) in
//        
//        if error != nil {
//            
//            completion(error)
//            return
//        }
//        
//        completion(error)
//    }
//        
//    
//}


//MARK: OneSignal

func updateOneSignalId() {
    
    if FUser.currentUser() != nil {
        
        if let pushId = UserDefaults.standard.string(forKey: kPUSHID) {
            setOneSignalId(pushId: pushId)
        } else {
            removeOneSignalId()
        }
    }
}


func setOneSignalId(pushId: String) {
    updateCurrentUserOneSignalId(newId: pushId)
}


func removeOneSignalId() {
    updateCurrentUserOneSignalId(newId: "")
}

//MARK: Updating Current user funcs

func updateCurrentUserOneSignalId(newId: String) {
    
    updateCurrentUserInFirestore(withValues: [kPUSHID : newId]) { (error) in
        if error != nil {
            print("error updating push id \(error!.localizedDescription)")
        }
    }
}

//MARK: Chaeck User block status

func checkBlockedStatus(withUser: FUser) -> Bool {
    return withUser.blockedUsers.contains(FUser.currentId())
}
