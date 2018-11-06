//
//  NoteMarkerView.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-11-04.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//
//  Creates custom annotation marker based on username/anonimity

import Foundation
import MapKit

class NoteMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let note = newValue as? Note else { return }
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

            markerTintColor = note.markerTintColor
            glyphText = String(note.userName.first!)
        }
    }
}
