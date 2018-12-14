//
//  NoteManager.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-12-12.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import Foundation
import MapKit

private let _singletonInstance = NoteManager()

private let numberOfExampleNotes = 7

class NoteManager: NSObject {
    //shared instance of NoteManager
    class var sharedInstance: NoteManager { return _singletonInstance }
    
    //note list
    var notes = [Note]()
    
    //initialize notes
    override init() {
        super.init()
        fillWithExamples()
    }
    
    //adds test values to note list
    func fillWithExamples() {
        let userNames = ["OrenNimmons", "FlorAddington", "BernadetteBachus", "CraigMathieson", "EricPoarch", "PaigeNeedham", "BigYEET69"]
        
        let coordinates = [CLLocationCoordinate2D(latitude: 49.84897225706291, longitude: -119.615764284726),CLLocationCoordinate2D(latitude: 49.84978225706291, longitude: -119.613264284726),CLLocationCoordinate2D(latitude: 49.84768425786291, longitude: -119.614164284226),CLLocationCoordinate2D(latitude: 49.84958525706291, longitude: -119.611864284926),CLLocationCoordinate2D(latitude: 49.84748625736291, longitude: -119.614464284126),CLLocationCoordinate2D(latitude: 49.8487548828125, longitude: -119.61301303479785),CLLocationCoordinate2D(latitude: 49.84628825706291, longitude: -119.613764284726)]
        
        notes = []
        for i in 0...(numberOfExampleNotes-1) {
            let userName = userNames[i]
            let avatar = UIImage(named: "IMG_0169")
            let noteImage = UIImage(named: "doggo image")
            let caption = "some generic joke that takes up two lines so i can debug"
            let coordinate = coordinates[i]
            //this will change dynamically later on
            //also want to implement this with a seperate table view that pops out when you click on "seen by x people"
            let seenBy = ["BigYEET69", "CraigMathieson", "FlorAddington"]
            
            let note = Note(id: i, userName: userName, avatar: avatar!, noteImage: noteImage, caption: caption, coordinate: coordinate, seenBy: seenBy, isAnonymous: false)
            notes.append(note)
        }
    }
}
