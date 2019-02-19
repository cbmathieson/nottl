//
//  NoteAnnotation.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-12-12.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import Foundation
import MapKit

class NoteAnnotation: NSObject, MKAnnotation {
    var noteID: String
    var coordinate: CLLocationCoordinate2D
    
    init(noteID: String, coordinate: CLLocationCoordinate2D) {
        self.noteID = noteID
        self.coordinate = coordinate
        super.init()
    }
}
