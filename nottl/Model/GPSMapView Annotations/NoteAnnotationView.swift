//
//  NoteAnnotationView.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-12-12.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import Foundation
import MapKit
import Firebase

class NoteAnnotationView: MKAnnotationView {
    
    //create instance of custom callout
    weak var noteDetailDelegate: NoteDetailMapViewDelegate?
    weak var customCalloutView: NoteDetailMapView?
    override var annotation: MKAnnotation? {
        willSet { customCalloutView?.removeFromSuperview() }
        
    }
    
    //changes annotation to a red pin rather than default
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = false
        self.image = UIImage(named: "filled_gps_tab")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.canShowCallout = false
        self.image = UIImage(named: "filled_gps_tab")
    }
    
    // show/hide callouts
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            //remove previous callout
            self.customCalloutView?.removeFromSuperview()
            
            //create custom callout
            if let newCustomCalloutView = loadNoteDetailMapView() {
                //set callout bubble to centered above annotation rather than overtop
                newCustomCalloutView.frame.origin.x -= newCustomCalloutView.frame.width / 2.0 - (self.frame.width / 2.0)
                newCustomCalloutView.frame.origin.y -= newCustomCalloutView.frame.height
                
                //set callout view
                self.addSubview(newCustomCalloutView)
                self.customCalloutView = newCustomCalloutView
                
                //fade it in
                if animated {
                    self.customCalloutView!.alpha = 0.0
                    UIView.animate(withDuration: 0.2, animations: {
                        self.customCalloutView!.alpha = 1.0
                    })
                }
            }
        } else {
            //if deselecting rather than selecting a new callout: simply fade it out
            if customCalloutView != nil {
                if animated {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.customCalloutView!.alpha = 0.0
                    }, completion: { (success) in
                        self.customCalloutView!.removeFromSuperview()
                    })
                } else {
                    //if not animated, just remove callout
                    self.customCalloutView!.removeFromSuperview()
                }
            }
        }
    }
    
    //loads nib as NoteDetailMapView rather than UIView
    func loadNoteDetailMapView() -> NoteDetailMapView? {
        if let views = Bundle.main.loadNibNamed("NoteDetailMapView", owner: self, options: nil) as? [NoteDetailMapView], views.count > 0 {
            let noteDetailMapView = views.first!
            noteDetailMapView.delegate = self.noteDetailDelegate
            if let noteAnnotation = annotation as? NoteAnnotation {
                let noteID = noteAnnotation.noteID
                
                Database.database().reference().child("notes").child(noteID).observeSingleEvent(of: .value) { (snapshot) in
                    
                    if let noteDictionary = snapshot.value as? [String: AnyObject] {
                        guard let caption = noteDictionary["caption"] as? String, let id = noteDictionary["id"] as? String, let isAnonymous = noteDictionary["isAnonymous"] as? Bool, let noteImage = noteDictionary["noteImage"] as? String, let profileImage = noteDictionary["profileImage"] as? String, let userName = noteDictionary["userName"] as? String, let latitude = noteDictionary["latitude"] as? Double, let longitude = noteDictionary["longitude"] as? Double, let dateC = noteDictionary["dateC"] as? String, let dateF = noteDictionary["dateF"] as? String else {
                            
                            print("failed to get note data")
                            return
                        }
                        
                        var seenByForNote = [String]()
                        
                        if let seenBy = noteDictionary["seenBy"] as? [String: AnyObject] {
                            for (username, _) in seenBy {
                                seenByForNote.append(username)
                            }
                        } else {
                            seenByForNote.append("0")
                        }
                        
                        let selectedNote = Note(caption: caption, id: id, isAnonymous: isAnonymous, noteImage: noteImage, profileImage: profileImage, userName: userName, latitude: latitude, longitude: longitude, dateC: dateC, dateF: dateF, seenBy: seenByForNote)
                        
                        noteDetailMapView.configureWithNote(note: selectedNote)
                    }
                }
                return noteDetailMapView
            }
        }
        return nil
    }
    
    //lets callout be used for a new pin
    override func prepareForReuse() {
        super.prepareForReuse()
        self.customCalloutView?.removeFromSuperview()
    }
    
    //passes hit recognition through mapview and into the NoteAnnotationView
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let parentHitView = super.hitTest(point, with: event) {
            return parentHitView
        } else {
            if customCalloutView != nil {
                return customCalloutView!.hitTest(convert(point, to: customCalloutView), with: event)
            } else {
                return nil
            }
        }
    }
    
}
