//
//  NoteDetailMapView.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-12-13.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit
import Foundation
import MapKit

//any class using this protocol must implement detailsrequestedfornote
protocol NoteDetailMapViewDelegate: class {
    func detailsRequestedForNote(note: Note)
    func detailsRequestedForSeenBy(note: Note)
}

class NoteDetailMapView: UIView {

    //outlets
    @IBOutlet weak var backgroundContentButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userCountButton: UIButton!
    
    //constants
    let nottlRed = UIColor(red: 179.0/255.0, green: 99.0/255.0, blue: 86/255.0, alpha: 1.0)
    
    //data
    var note: Note!
    weak var delegate: NoteDetailMapViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //sets button image as circle
        imageButton.layer.cornerRadius = 25
        imageButton.layer.masksToBounds = true
        imageButton.layer.borderColor = nottlRed.cgColor
        imageButton.layer.borderWidth = 2.0
    }
    
    //actions
    @IBAction func imageSelected(_ sender: Any) {
        delegate?.detailsRequestedForNote(note: note)
    }
    
    @IBAction func viewedBySelected(_ sender: Any) {
        delegate?.detailsRequestedForSeenBy(note: note)
    }
    
    //functions
    
    //sets values to callout
    func configureWithNote(note: Note) {
        self.note = note
        
        imageButton.setImage(note.avatar, for: .normal)
        userNameLabel.text = note.userName
        descriptionLabel.text = note.caption
        
        let userCount = "viewed by " + String(note.seenBy.count) + " users"
        userCountButton.setTitle(userCount, for: .normal)
    }
    
    //hitTest -> override in order to detect hits in our custom callout
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        //image button clicked
        if let result = imageButton.hitTest(convert(point, to: imageButton), with: event) {
            return result
        }
        
        // viewedBy selected
        if let result = userCountButton.hitTest(convert(point, to: userCountButton), with: event) {
            return result
        }
        
        return backgroundContentButton.hitTest(convert(point, to: backgroundContentButton), with: event)
 
    }
}
