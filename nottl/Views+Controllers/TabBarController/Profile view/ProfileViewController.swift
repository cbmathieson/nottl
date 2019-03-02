//
//  ProfileViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-10-08.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //profile information
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var favoritesCount: UILabel!
    @IBOutlet weak var myNotesCount: UILabel!
    
    //My Notes View
    @IBOutlet weak var myNotesView: UIView!
    @IBOutlet weak var myNotesTableView: UITableView!
    var databaseMyNotes = [String]()
    var notes = [Note]()
    
    //Favorites View
    @IBOutlet weak var favoritesView: UIView!
    @IBOutlet weak var favoritesTableView: UITableView!
    var databaseFavoriteNotes = [String]()
    var favoriteNotes = [Note]()
    
    //interactions
    @IBOutlet weak var myNotesButton: UIButton!
    @IBOutlet weak var myFavoritesButton: UIButton!
    @IBOutlet weak var myNotesUnderlay: UIView!
    @IBOutlet weak var favoritesUnderlay: UIView!
    
    var myNotes = true
    let nottlRed = UIColor(red: 179.0/255.0, green: 99.0/255.0, blue: 86/255.0, alpha: 1.0)
    let nottlGrey = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUserData()
        
        profileImageView.layer.cornerRadius = 45.0
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = nottlRed.cgColor
        profileImageView.layer.borderWidth = 2.0
        
        perform(#selector(myNotesPressed(_:)), with: nil, afterDelay: 2.0)
    }
    
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("no user logged in!")
            profileName.text = ""
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //get dictionary values
                self.profileName.text = dictionary["username"] as? String
                
                //convert profileImageURL to image from storage
                guard let profileImageURL = dictionary["profileImageLink"] as? String else {
                    print("no image to be found!!!")
                    return
                }
                
                //get favorited note urls
                if let favorites = dictionary["favorites"] as? [String: AnyObject] {
                    for (_, value) in favorites {
                        
                        if let faveID = value as? String {
                            self.databaseFavoriteNotes.append(faveID)
                        }
                    }
                }
                
                if let userNotes = dictionary["myNotes"] as? [String: AnyObject] {
                    for (_, value) in userNotes {
                        if let userNoteID = value as? String {
                            self.databaseMyNotes.append(userNoteID)
                        }
                    }
                }
                
                let url = URL(string: profileImageURL)
                URLSession.shared.dataTask(with: url!, completionHandler: { ( data, response, error) in
                    
                    //download issue get out
                    if error != nil {
                        print("error")
                        return
                    }
                    
                    if let image = UIImage(data: data!) {
                        DispatchQueue.main.async {
                            self.profileImageView.image = image
                        }
                    } else {
                        print("image not found in storage from link")
                    }
                    
                }).resume()
                
                self.myNotesCount.text = String(self.databaseMyNotes.count)
                self.favoritesCount.text = String(self.databaseFavoriteNotes.count)
                
                //get notes from database
                for ID in self.databaseFavoriteNotes {
                    Database.database().reference().child("notes").child(ID).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let noteDictionary = snapshot.value as? [String: AnyObject] {
                            guard let caption = noteDictionary["caption"] as? String, let id = noteDictionary["id"] as? String, let isAnonymous = noteDictionary["isAnonymous"] as? Bool, let noteImage = noteDictionary["noteImage"] as? String, let profileImage = noteDictionary["profileImage"] as? String, let userName = noteDictionary["userName"] as? String, let latitude = noteDictionary["latitude"] as? Double, let longitude = noteDictionary["longitude"] as? Double, let seenBy = noteDictionary["seenBy"] as? [String], let dateC = noteDictionary["dateC"] as? String, let dateF = noteDictionary["dateF"] as? String else {
                                print("failed to get note data")
                                return
                            }
                            
                            let selectedNote = Note(caption: caption, id: id, isAnonymous: isAnonymous, noteImage: noteImage, profileImage: profileImage, userName: userName, latitude: latitude, longitude: longitude, dateC: dateC, dateF: dateF, seenBy: seenBy)
                            
                            self.favoriteNotes.append(selectedNote)
                            
                        }
                    })
                }
                
                for ID in self.databaseMyNotes {
                    Database.database().reference().child("notes").child(ID).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let noteDictionary = snapshot.value as? [String: AnyObject] {
                            guard let caption = noteDictionary["caption"] as? String, let id = noteDictionary["id"] as? String, let isAnonymous = noteDictionary["isAnonymous"] as? Bool, let noteImage = noteDictionary["noteImage"] as? String, let profileImage = noteDictionary["profileImage"] as? String, let userName = noteDictionary["userName"] as? String, let latitude = noteDictionary["latitude"] as? Double, let longitude = noteDictionary["longitude"] as? Double, let seenBy = noteDictionary["seenBy"] as? [String], let dateC = noteDictionary["dateC"] as? String, let dateF = noteDictionary["dateF"] as? String else {
                                print("failed to get note data")
                                return
                            }
                            
                            let selectedNote = Note(caption: caption, id: id, isAnonymous: isAnonymous, noteImage: noteImage, profileImage: profileImage, userName: userName, latitude: latitude, longitude: longitude, dateC: dateC, dateF: dateF, seenBy: seenBy)
                            
                            self.notes.append(selectedNote)
                            
                        }
                    })
                }
                
            }
        }, withCancel: nil)
        
    }
    
    @IBAction func myNotesPressed(_ sender: Any) {
        myNotes = true
        myNotesButton.setTitleColor(nottlRed, for: .normal)
        myFavoritesButton.setTitleColor(nottlGrey, for: .normal)
        myNotesUnderlay.isHidden = false
        favoritesUnderlay.isHidden = true
        self.myNotesTableView.reloadData()
        favoritesView.isHidden = true
        myNotesView.isHidden = false
    }
    
    @IBAction func favoritesPressed(_ sender: Any) {
        myNotes = false
        myNotesButton.setTitleColor(nottlGrey, for: .normal)
        myFavoritesButton.setTitleColor(nottlRed, for: .normal)
        myNotesUnderlay.isHidden = true
        favoritesUnderlay.isHidden = false
        self.favoritesTableView.reloadData()
        favoritesView.isHidden = false
        myNotesView.isHidden = true
    }
    
    //TableView Delegate Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(!myNotes) {
            return favoriteNotes.count
        } else {
            return notes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(!myNotes) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "favoritesCell", for: indexPath) as! FavoritesTableViewCell
            
            let note: Note
            note = favoriteNotes[indexPath.row]
            
            cell.profileName.text = note.userName
            cell.noteDescription.text = note.caption
            cell.favoritesCount.text = String(12)
            //need to get profile image from note.profileImage url
            
            let url = URL(string: note.profileImage)
            
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print("error with getting image from url")
                    return
                }
                
                if let image = UIImage(data: data!) {
                    DispatchQueue.main.async {
                        cell.noteImage.image = image
                    }
                } else {
                    print("image not found in storage")
                }
            }).resume()
            
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "myNotesCell", for: indexPath) as! ProfileViewControllerTableViewCell

            let note: Note
            note = notes[indexPath.row]

            cell.noteDescription.text = note.caption
            cell.favoriteCount.text = String(69)
            
            // get cell.noteImage from note.noteImage url
            let url = URL(string: note.profileImage)
            
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print("error with getting image from url")
                    return
                }
                
                if let image = UIImage(data: data!) {
                    DispatchQueue.main.async {
                        cell.noteImage.image = image
                    }
                } else {
                    print("image not found in storage")
                }
            }).resume()
            
            return cell
        }
    }
}
