//
//  Team.swift
//  AAATraining
//
//  Created by Margaret Dwan on 8/24/20.
//  Copyright © 2020 Margaret Dwan. All rights reserved.
//

import Foundation
import Firebase

public class Team {
    //if ever i need to make a "team owner" all I have to do is when team register is clicked, say "enter user credentials or create account" then
    
    //set up FUser to have a team and then set his team default when finish is clicked in register like FUser.teamID = "team loaded in after team code is typed"  and set FUser.cover to be the same as Team.logo, and add that user to "teamMemberIDs" in Team
    
    //user types in Team code > LoginVC has a function that takes that team code, queries database, grabs the logo and all
    
    // get 3 colors from the uploaded logo and when loading every screen on the app, get the team info and set elements of the screen to the colors
    //
    var teamID: String
    var teamName: String
    var teamLogo: String
    var teamMemberIDs: [String]
    var teamCity: String
    var teamState: String
    var teamColorOne: String
    var teamColorTwo: String
    var teamColorThree: String

    let teamDictionary: NSMutableDictionary
    
    init(teamID: String, teamName: String, teamLogo: String, teamMemberIDs: [String], teamCity: String, teamState: String, teamColorOne: String, teamColorTwo: String, teamColorThree: String) {
        
        teamDictionary = NSMutableDictionary(objects: [teamID, teamName, teamLogo, teamMemberIDs, teamCity, teamState, teamColorOne, teamColorTwo, teamColorThree], forKeys: [kTEAMID as NSCopying, kTEAMNAME as NSCopying, kTEAMLOGO as NSCopying, kTEAMMEMBERIDS as NSCopying, kTEAMCITY as NSCopying, kTEAMSTATE as NSCopying, kTEAMCOLORONE as NSCopying, kTEAMCOLORTWO as NSCopying, kTEAMCOLORTHREE as NSCopying])
        
        self.teamID = teamID
        self.teamName = teamName
        self.teamLogo = teamLogo
        self.teamMemberIDs = teamMemberIDs
        self.teamCity = teamCity
        self.teamState = teamState
        self.teamColorOne = teamColorOne
        self.teamColorTwo = teamColorTwo
        self.teamColorThree = teamColorThree
        
    }
    
    
}
