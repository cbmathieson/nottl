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
import Firebase

//any class using this protocol must implement detailsrequestedfornote
protocol NoteDetailMapViewDelegate: class {
    func detailsRequestedForNote(note: Note, currentAvatarImage: UIImage?)
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
        delegate?.detailsRequestedForNote(note: note, currentAvatarImage: imageButton.image(for: .normal))
    }
    
    @IBAction func viewedBySelected(_ sender: Any) {
        delegate?.detailsRequestedForSeenBy(note: note)
    }
    
    //functions
    
    //sets values to callout
    func configureWithNote(note: Note) {
        self.note = note
        
        //convert url to image from storage
        
        let url = URL(string: note.profileImage)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil {
                print("error with getting image from url")
                return
            }
            
            if let image = UIImage(data: data!) {
                DispatchQueue.main.async {
                    self.imageButton.setImage(image, for: .normal)
                }
            } else {
                print("image not found in storage")
            }
        }).resume()
        
        userNameLabel.text = note.userName
        descriptionLabel.text = note.caption
        
        let userCount = String(note.seenBy.count-1) + "♡"
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
        
        //makes sure callout is not delselected when anything but the buttons are selected
        return backgroundContentButton.hitTest(convert(point, to: backgroundContentButton), with: event)
    }
    
    
}
