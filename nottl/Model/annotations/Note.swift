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
    var id: Int
    var userName: String        //will set userName to '?' if anon chosen in new note screen
    var avatar: UIImage
    var noteImage: UIImage?
    var caption: String
    var coordinate: CLLocationCoordinate2D
    var seenBy = [String]()
    var hasImage: Bool
    var isAnonymous: Bool
    
    init(id: Int, userName: String, avatar: UIImage, noteImage: UIImage?, caption: String, coordinate: CLLocationCoordinate2D, seenBy: [String], isAnonymous: Bool) {
        self.id = id
        self.userName = userName
        self.avatar = avatar
        if let temp = noteImage {
            self.noteImage = temp
            self.hasImage = true
        } else {
            self.noteImage = nil
            self.hasImage = false
        }
        self.caption = caption
        self.coordinate = coordinate
        //should initialize with empty array but adding for testing
        self.seenBy = seenBy
        self.isAnonymous = isAnonymous
        
        super.init()
    }
    
    func addUserToSeenBy(item: String) { seenBy.append(item) }
    
}
