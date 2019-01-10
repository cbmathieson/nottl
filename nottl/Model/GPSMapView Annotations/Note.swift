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
    var userName: String
    var avatar: UIImage
    var noteImage: UIImage
    var caption: String
    var coordinate: CLLocationCoordinate2D
    var seenBy = [String]()
    var isAnonymous: Bool
    
    init(id: Int, userName: String, avatar: UIImage, noteImage: UIImage, caption: String, coordinate: CLLocationCoordinate2D, seenBy: [String], isAnonymous: Bool) {
        self.id = id
        self.userName = userName
        self.avatar = avatar
        self.noteImage = noteImage
        self.caption = caption
        self.coordinate = coordinate
        //should initialize with empty array but adding for testing
        self.seenBy = seenBy
        self.isAnonymous = isAnonymous
        
        super.init()
    }
    
    func addUserToSeenBy(item: String) { seenBy.append(item) }
    
}
