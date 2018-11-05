//
//  Note.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-11-03.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import Foundation

import MapKit

class Note: NSObject, MKAnnotation {
    let userName: String
    let noteDescription: String
    let coordinate: CLLocationCoordinate2D
    let type: String
    
    init(userName: String, noteDescription: String, coordinate: CLLocationCoordinate2D, type: String) {
        self.userName = userName
        self.noteDescription = noteDescription
        self.coordinate = coordinate
        self.type = type
        
        super.init()
    }
    
    //will further implement into app once ive added a database
    //Expecting [<username>,<noteDescription>,<latitude>,<longitude>, <type>]
    init?(json: [Any]) {
        self.userName = json[0] as? String ?? ""
        self.noteDescription = json[1] as! String
        
        if let latitude = Double(json[2] as! String),let longitude = Double(json[3] as! String) {
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            self.coordinate = CLLocationCoordinate2D()
        }
        
        self.type = json[4] as! String
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
