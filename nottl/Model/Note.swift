//
//  Note.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-11-03.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import Foundation

import MapKit

enum EventType: String {
    case onEntry = "On Entry"
    case onExit = "On Exit"
}

class Note: NSObject, MKAnnotation {
    let id: String
    let userName: String
    let noteDescription: String
    let coordinate: CLLocationCoordinate2D
    let type: String
    
    init(id: String, userName: String, noteDescription: String, coordinate: CLLocationCoordinate2D, type: String) {
        self.id = id
        self.userName = userName
        self.noteDescription = noteDescription
        self.coordinate = coordinate
        self.type = type
        
        super.init()
    }
    
    //will further implement into app once ive added a database
    //Expecting [<username>,<noteDescription>,<latitude>,<longitude>, <type>]
    init?(json: [Any]) {
        self.id = json[0] as! String
        self.userName = json[1] as? String ?? ""
        self.noteDescription = json[2] as! String
        
        if let latitude = Double(json[3] as! String),let longitude = Double(json[4] as! String) {
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            self.coordinate = CLLocationCoordinate2D()
        }
        
        self.type = json[5] as! String
    }
    
    var title: String? {
        return userName
    }
    var subtitle: String? {
        return noteDescription
    }
    
    //visual representation of Note on marker
    var markerTintColor: UIColor {
        switch type {
        case "?":
            return .darkGray
        case "user":
            return .red
        case "read":
            return .lightGray
        default:
            return .lightGray
        }
    }
}
