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
    var note: Note
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: note.latitude, longitude: note.longitude)
    }
    
    init(note: Note) {
        self.note = note
        super.init()
    }
    
    var title: String? {
        return note.userName
    }
    
    var subtitle: String? {
        return note.caption
    }
}
