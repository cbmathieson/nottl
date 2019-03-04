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
        
        profileImageView.layer.cornerRadius = 45.0
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = nottlRed.cgColor
        profileImageView.layer.borderWidth = 2.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //wait for request to finish before reloading notes
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.fetchUserData(completed: {
                DispatchQueue.main.async { [weak self] in
                    if self?.myNotes ?? true {
                        self?.myNotesTableView.reloadData()
                    } else {
                        self?.favoritesTableView.reloadData()
                    }
                }
            })
        }
    }
    
    func fetchUserData(completed: () -> ()) {
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
                
                self.databaseFavoriteNotes.removeAll()
                self.databaseMyNotes.removeAll()
                
                //get favorited note urls
                if let favorites = dictionary["favorites"] as? [String: AnyObject] {
                    for (note, _) in favorites {
                        self.databaseFavoriteNotes.append(note)
                    }
                }
                
                //get favorite urls
                if let userNotes = dictionary["myNotes"] as? [String: AnyObject] {
                    for (note, _) in userNotes {
                            self.databaseMyNotes.append(note)
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
                
                if(self.databaseMyNotes.count == 0) {
                    self.myNotesCount.text = "0";
                } else {
                    self.myNotesCount.text = String(self.databaseMyNotes.count-1)
                }
                
                if(self.databaseFavoriteNotes.count == 0) {
                    self.favoritesCount.text = "0"
                } else {
                    self.favoritesCount.text = String(self.databaseFavoriteNotes.count-1)
                }
                
                self.favoriteNotes.removeAll()
                self.notes.removeAll()
                
                //get notes from database
                for ID in self.databaseFavoriteNotes {
                    Database.database().reference().child("notes").child(ID).observeSingleEvent(of: .value, with: { (snapshot) in
                        
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
                            
                            self.favoriteNotes.append(selectedNote)
                            
                        }
                    })
                }
                
                for ID in self.databaseMyNotes {
                    Database.database().reference().child("notes").child(ID).observeSingleEvent(of: .value, with: { (snapshot) in
                        
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
                            
                            self.notes.append(selectedNote)
                            
                        }
                    })
                }
            }
        }, withCancel: nil)

        while(true) {
            if(self.databaseFavoriteNotes.count-1 == favoriteNotes.count && self.databaseMyNotes.count-1 == notes.count) {
                completed()
                break
            }
        }
    }
    
    @IBAction func myNotesPressed(_ sender: Any) {
        myNotes = true
        myNotesButton.setTitleColor(nottlRed, for: .normal)
        myFavoritesButton.setTitleColor(nottlGrey, for: .normal)
        myNotesUnderlay.isHidden = false
        favoritesUnderlay.isHidden = true
        fetchUserData { () -> () in
            myNotesTableView.reloadData()
        }
        favoritesView.isHidden = true
        myNotesView.isHidden = false
    }
    
    @IBAction func favoritesPressed(_ sender: Any) {
        myNotes = false
        myNotesButton.setTitleColor(nottlGrey, for: .normal)
        myFavoritesButton.setTitleColor(nottlRed, for: .normal)
        myNotesUnderlay.isHidden = true
        favoritesUnderlay.isHidden = false
        fetchUserData { () -> () in
            favoritesTableView.reloadData()
        }
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
            if(note.seenBy.count == 1) {
                cell.favoritesCount.font = cell.favoritesCount.font.withSize(25)
                cell.favoritesCount.text = "_♡"
            } else {
                cell.favoritesCount.font = cell.favoritesCount.font.withSize(17)
                cell.favoritesCount.text = String(note.seenBy.count-1) + "♡"
            }
            
            //get profile picture from server
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
            if(note.seenBy.count == 1) {
                cell.favoriteCount.text = "_♡"
            } else {
                cell.favoriteCount.text = String(note.seenBy.count-1) + "♡"
            }
            
            // get cell.noteImage from note.noteImage url
            let url = URL(string: note.noteImage)
            
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
