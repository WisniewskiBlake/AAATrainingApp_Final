//
//  Constants.swift
//  AAATraining
//
//  Created by Margaret Dwan on 7/19/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseCore
import CoreLocation
import PushKit
import FirebaseFirestore


public var recentBadgeHandler: ListenerRegistration?
public var calendarBadgeHandler: ListenerRegistration?
let userDefaults = UserDefaults.standard

//NOTIFICATIONS
public let USER_DID_LOGIN_NOTIFICATION = "UserDidLoginNotification"
public let APP_STARTED_NOTIFICATION = "AppStartedNotification"


//IDS and Keys
public let kFILEREFERENCE = "gs://aaatrainingapp-be3e5.appspot.com"
public let kONESIGNALAPPID = ""
public let kSINCHKEY = ""
public let kSINCHSECRET = ""
public let kAPPURL = ""

//Firebase Headers
public let kUSER_PATH = "User"
public let kTYPINGPATH_PATH = "Typing"
public let kRECENT_PATH = "Recent"
public let kMESSAGE_PATH = "Message"
public let kGROUP_PATH = "Group"
public let kCALL_PATH = "Call"

//FUser
public let kOBJECTID = "objectId"
public let kUSERCURRENTTEAMID = "userCurrentTeamID"
public let kUSERTEAMIDS = "userTeamIDs"
public let kUSERTEAMACCOUNTTYPES = "userTeamAccountTypes"
public let kUSERTEAMNAMES = "userTeamNames"
public let kUSERTEAMMEMBERS = "userTeamMembers"
public let kUSERTEAMMEMBERCOUNT = "userTeamMemberCount"
public let kUSERTEAMCOLORONE = "userTeamColorOne"
public let kUSERTEAMCOLORTWO = "userTeamColorTwo"
public let kUSERTEAMCOLORTHREE = "userTeamColorThree"
public let kUSERISNEWOBSERVERARRAY = "userIsNewObserverArray"
public let kCREATEDAT = "createdAt"
public let kUPDATEDAT = "updatedAt"
public let kEMAIL = "email"
public let kHEIGHT = "height"
public let kWEIGHT = "weight"
public let kFIRSTNAME = "firstname"
public let kLASTNAME = "lastname"
public let kPOSITION = "position"
public let kAVATAR = "ava"
public let kCURRENTUSER = "currentUser"
public let kNUMBER = "number"
public let kID = "id"
public let kACCOUNTTYPE = "accountType"
public let kBIRTHDAY = "birthday"
public let kCOVER = "cover"
public let kCOACH = "coach"
public let kPLAYER = "player"

public let kRECENTTEAMID = "recentTeamID"


public let kPHONE = "phone"

public let kLOGINMETHOD = "loginMethod"
public let kPUSHID = "pushId"

public let kISONLINE = "isOnline"
public let kVERIFICATIONCODE = "firebase_verification"

//public let kCOUNTRY = "country"
public let kBLOCKEDUSERID = "blockedUserId"


public let kBACKGROUBNDIMAGE = "backgroundImage"
public let kSHOWAVATAR = "showAvatar"
public let kPASSWORDPROTECT = "passwordProtect"
public let kFIRSTRUN = "firstRun"
public let kNUMBEROFMESSAGES = 10
public let kMAXDURATION = 120.0
public let kAUDIOMAXDURATION = 120.0
public let kSUCCESS = 2

//Posts
public let kPOSTS = "posts"
public let kPOSTID = "postID"
public let kPOSTOWNERID = "ownerID"
public let kPOSTTEAMID = "postTeamID"
public let kPOSTTEXT = "postText"
public let kPOSTPICTURE = "postPicture"
public let kPOSTDATE = "postDate"
public let kPOSTUSERAVA = "postUserAva"
public let kPOSTUSERNAME = "postUserName"
public let kPOSTVIDEO = "postVideo"
public let kPOSTTHUMBNAIL = "postThumbnail"
public let kPOSTTYPE = "postType"
public let kPOSTURLLINK = "postUrlLink"
public let kPOSTFEEDTYPE = "postFeedType"

//Nutrition
public let kNUTRITIONPOSTS = "nutritionPosts"
public let kNUTRITIONPOSTID = "nutritionPostID"
public let kNUTRITIONTEAMID = "nutritionPostTeamID"
public let kNUTRITIONPOSTOWNERID = "nutritionOwnerID"
public let kNUTRITIONPOSTTEXT = "nutritionPostText"
public let kNUTRITIONPOSTPICTURE = "nutritionPostPicture"
public let kNUTRITIONPOSTDATE = "nutritionPostDate"
public let kNUTRITIONPOSTUSERAVA = "nutritionPostUserAva"
public let kNUTRITIONPOSTUSERNAME = "nutritionPostUserName"
public let kNUTRITIONPOSTVIDEO = "nutritionPostVideo"
public let kNUTRITIONPOSTTHUMBNAIL = "nutritionPostThumbnail"
public let kNUTRITIONPOSTTYPE = "nutritionPostType"
public let kNUTRITIONPOSTURLLINK = "nutritionPostUrlLink"


//Baseline
public let kBASELINES = "baselines"
public let kBASELINEID = "baselineID"
public let kBASELINETEAMID = "baselineTeamID"
public let kBASELINEOWNERID = "baselineOwnerID"
public let kBASELINEHEIGHT = "height"
public let kBASELINEWEIGHT = "weight"
public let kWINGSPAN = "wingspan"
public let kVERTICAL = "vertical"
public let kYARDDASH = "yardDash"
public let kAGILITY = "agility"
public let kPUSHUP = "pushUp"
public let kCHINUP = "chinUp"
public let kMILERUN = "mileRun"
public let kBASELINEDATE = "baselineDate"
public let kBASELINEUSERNAME = "baselineUserName"

//Events
public let kEVENTS = "events"
public let kEVENTID = "eventID"
public let kEVENTTEAMID = "eventTeamID"
public let kEVENTOWNERID = "eventOwnerID"
public let kEVENTTEXT = "eventText"
public let kEVENTACCOUNTTYPE = "eventAccountType"
public let kEVENTDATE = "eventDate"
public let kEVENTCOUNTER = "eventCounter"
public let kEVENTUSERID = "eventUserID"
public let kEVENTGROUPID = "eventGroupID"
public let kEVENTTITLE = "eventTitle"
public let kEVENTSTART = "eventStart"
public let kEVENTEND = "eventEnd"
public let kEVENTDATEFORUPCOMINGCOMPARISON = "dateForUpcomingComparison"
public let kEVENTLOCATION = "eventLocation"
public let kEVENTIMAGE = "eventImage"
public let kEVENTURL = "eventURL"

public let kTEAMS = "teams"
public let kTEAMID = "teamID"
public let kTEAMNAME = "teamName"
public let kTEAMTYPE = "teamType"
public let kTEAMCITY = "teamCity"
public let kTEAMSTATE = "teamState"
public let kTEAMLOGO = "teamLogo"
public let kTEAMMEMBERIDS = "teamMemberIDs"
public let kTEAMCOLORONE = "teamColorOne"
public let kTEAMCOLORTWO = "teamColorTwo"
public let kTEAMCOLORTHREE = "teamColorThree"
public let kTEAMMEMBERCOUNT = "teamMemberCount"
public let kTEAMMEMBERACCOUNTTYPES = "teamMemberAccountTypes"

//recent
public let kCHATROOMID = "chatRoomID"
public let kUSERID = "userId"
public let kDATE = "date"
public let kPRIVATE = "private"
public let kGROUP = "group"
public let kGROUPID = "groupId"
public let kRECENTID = "recentId"
public let kMEMBERS = "members"
public let kMESSAGE = "message"
public let kMEMBERSTOPUSH = "membersToPush"
public let kDISCRIPTION = "discription"
public let kLASTMESSAGE = "lastMessage"
public let kCOUNTER = "counter"
public let kTYPE = "type"
public let kWITHUSERUSERNAME = "withUserUserName"
public let kWITHUSERUSERID = "withUserUserID"
public let kOWNERID = "ownerID"
public let kSTATUS = "status"
public let kMESSAGEID = "messageId"
public let kNAME = "name"
public let kSENDERID = "senderId"
public let kSENDERNAME = "senderName"
public let kTHUMBNAIL = "thumbnail"
public let kISDELETED = "isDeleted"

//Contacts
public let kCONTACT = "contact"
public let kCONTACTID = "contactId"

//message types
public let kPICTURE = "picture"
public let kTEXT = "text"
public let kVIDEO = "video"
public let kAUDIO = "audio"
public let kLOCATION = "location"

//coordinates
public let kLATITUDE = "latitude"
public let kLONGITUDE = "longitude"


//message status
public let kDELIVERED = "Delivered"
public let kREAD = "read"
public let kREADDATE = "readDate"
public let kDELETED = "deleted"



//push
public let kDEVICEID = "deviceId"

//Call

public let kISINCOMING = "isIncoming"
public let kCALLERID = "callerId"
public let kCALLERFULLNAME = "callerFullName"
public let kCALLSTATUS = "callStatus"
public let kWITHUSERFULLNAME = "withUserFullName"
public let kCALLERAVATAR = "callerAvatar"
public let kWITHUSERAVATAR = "withUserAvatar"
