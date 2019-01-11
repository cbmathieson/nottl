//
//  Note.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-11-03.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import Foundation

import MapKit

class Note: NSObject {
    var caption: String
    var id: String
    var isAnonymous: Bool
    var noteImage: String
    var profileImage: String
    var userName: String
    var latitude: Double
    var longitude: Double
    //will be a list of uids so we can relate to their profile
    var seenBy: [String]
    
    init(caption: String, id: String, isAnonymous: Bool, noteImage: String, profileImage: String, userName: String, latitude: Double, longitude: Double, seenBy: [String]) {
        self.caption = caption
        self.id = id
        self.isAnonymous = isAnonymous
        self.noteImage = noteImage
        self.profileImage = profileImage
        self.userName = userName
        self.latitude = latitude
        self.longitude = longitude
        //should initialize with empty array but adding for testing
        self.seenBy = seenBy
        
        super.init()
    }
    
    func addUserToSeenBy(item: String) { seenBy.append(item) }
    
}
