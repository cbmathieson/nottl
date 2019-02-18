//
//  DataService.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-12-24.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

//Database url
let DB_BASE = Database.database().reference()

class DataService {
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    //user folder
    private var _REF_USERS = DB_BASE.child("users")
    //Notes folder
    private var _REF_MAPPED_NOTES = DB_BASE.child("notes")
    
    var REF_BASES: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_MAPPED_NOTES: DatabaseReference {
        return _REF_MAPPED_NOTES
    }
    
    //creates user with userid and values associated as dictionary
    func createDBUser(uid: String, userData: Dictionary<String, Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    func addToMyNotes(noteURL: String, uid: String) {
        REF_USERS.child(uid).child("myNotes").childByAutoId().setValue(noteURL)
    }
    
    //sends new note to firebase
    func createNewNote(noteData: Dictionary<String, Any>, latitude: String, longitude: String, noteImage: UIImage, completion: @escaping (Bool) -> ()) {
        
        //check if value already exists in the space
        //allows dictionary to be mutated
        var noteData = noteData
        //gets location of note to reference as user
        var noteLocationPath = ""
        //get timestamp for note
        let timestamp = getCurrentTime()
        noteData["dateC"] = timestamp
        noteData["dateF"] = ""
        
        guard let imageName = noteData["id"] as? String else {
            print("failed to get note id")
            completion(false)
            return
        }
        
        let storageRef = Storage.storage().reference().child("notes/\(imageName).jpg")
        
        //compress image to <100KB ... hopefully
        guard let uploadData = noteImage.compressImage(maxHeight: 640.0, maxWidth: 1136.0, compressionQuality: 0.5) else {
            print("could not compress image data")
            completion(false)
            return
        }
        
        self.REF_MAPPED_NOTES.child(latitude).child(longitude).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                print("note exists already")
                completion(false)
                return
            }
            
            //upload image to firebase storage
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print(String(describing: error))
                    //ABORT!
                    print("failed to upload image data")
                    completion(false)
                    return
                }
                
                //once upload completes, get url and create note with noteimage link
                storageRef.downloadURL(completion: { (url, error) in
                    if let link = url?.absoluteString {
                        noteData["noteImage"] = link
                    } else {
                        print("failed to get image link")
                        completion(false)
                        return
                    }
                    print("attempting to upload note")
                    self.REF_MAPPED_NOTES.child(latitude).child(longitude).updateChildValues(noteData)
                    
                    if let uid = noteData["uid"] as? String {
                        noteLocationPath = String(describing: snapshot.ref.description())
                        print(String(describing: noteLocationPath))
                        
                        self.addToMyNotes(noteURL: noteLocationPath, uid: uid)
                    }
                })
            }
        }
        completion(true)
    }
    
    func addToFavorites(note: Note?) {
        guard let note = note else {
            print("failed to get current note!")
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("could not get current user")
            return
        }
        
        let latitude = note.latitude.truncate(places: 5)!.replacingOccurrences(of: ".", with: "")
        let longitude = note.longitude.truncate(places: 5)!.replacingOccurrences(of: ".", with: "")
        
        let favoriteNoteURL = String(describing: self.REF_MAPPED_NOTES.child(latitude).child(longitude))
        REF_USERS.child(uid).child("favorites").child(note.id).setValue(favoriteNoteURL)
    }
    
    func getCurrentTime() -> String {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        return "\(year)/\(month)/\(day)/\(hour):\(minutes):\(seconds)"
    }
    
}
