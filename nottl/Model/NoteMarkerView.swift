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
            let noteButton = UIButton(frame: CGRect(origin: CGPoint.zero,size: CGSize(width: 30, height: 30)))
            
            noteButton.setBackgroundImage(UIImage(named: "account_icon"), for: UIControl.State())
            rightCalloutAccessoryView = noteButton
            
            let noteLabel = UILabel()
            noteLabel.numberOfLines = 0
            noteLabel.font = noteLabel.font.withSize(12)
            noteLabel.text = note.subtitle
            detailCalloutAccessoryView = noteLabel
            
            markerTintColor = note.markerTintColor
            glyphText = String(note.userName.first!)
        }
    }
}
