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
    
    struct NotesCell {
        var note: Note
        var image: UIImage
        var profileImage: UIImage
    }
    
    var userNotes = [NotesCell]()
    
    //Favorites View
    @IBOutlet weak var favoritesView: UIView!
    @IBOutlet weak var favoritesTableView: UITableView!
    var databaseFavoriteNotes = [String]()
    
    struct FavoritesCell {
        var note: Note
        var profileImage: UIImage
    }
    
    var faveNotes = [FavoritesCell]()
    
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
        
        //wait for request to finish before reloading notes
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.fetchUserData(completed: {
                DispatchQueue.main.async { [weak self] in
                    self?.myNotesTableView.reloadData()
                    self?.favoritesTableView.reloadData()
                }
            })
        }
    }
    
    @IBAction func reloadData(_ sender: Any) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.fetchUserData(completed: {
                DispatchQueue.main.async { [weak self] in
                    self?.myNotesTableView.reloadData()
                    self?.favoritesTableView.reloadData()
                }
            })
            
            print("printing fave notes...")
            for index in self.faveNotes {
                print(index.note.caption)
            }
            
            print("printing myNotes...")
            for index in self.userNotes {
                print(index.note.caption)
            }
            
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
                
                self.faveNotes.removeAll()
                self.userNotes.removeAll()
                
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
                            
                            let url = URL(string: selectedNote.profileImage)
                            
                            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                                
                                if error != nil {
                                    print("error with getting image from url")
                                    return
                                }
                                
                                if let image = UIImage(data: data!) {
                                    //add to images list to use when selected
                                    self.faveNotes.append(FavoritesCell(note: selectedNote, profileImage: image))
                                } else {
                                    print("image not found in storage")
                                }
                            }).resume()
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
                            
                            let url = URL(string: selectedNote.noteImage)
                            
                            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                                
                                if error != nil {
                                    print("error with getting image from url")
                                    return
                                }
                                
                                guard let image = UIImage(data: data!) else {
                                    print("image not found in storage")
                                    return
                                }
                                //get note's profile image for when it's selected
                                let profileURL = URL(string: selectedNote.profileImage)
                                URLSession.shared.dataTask(with: profileURL!, completionHandler: { (data, response, error) in
                                    
                                    if error != nil {
                                        print("error with getting image from url")
                                        return
                                    }
                                    
                                    guard let pImage = UIImage(data: data!) else {
                                        print("image not found in storage")
                                        return
                                    }
                                    self.userNotes.append(NotesCell(note: selectedNote, image: image, profileImage: pImage))
                                }).resume()
                            }).resume()
                        }
                    })
                }
            }
        }, withCancel: nil)
        
        while(true) {
            if(databaseFavoriteNotes.count + databaseMyNotes.count - 2 == userNotes.count + faveNotes.count) {
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
        favoritesTableView.reloadData()
        myNotesTableView.reloadData()
        favoritesView.isHidden = true
        myNotesView.isHidden = false
    }
    
    @IBAction func favoritesPressed(_ sender: Any) {
        myNotes = false
        myNotesButton.setTitleColor(nottlGrey, for: .normal)
        myFavoritesButton.setTitleColor(nottlRed, for: .normal)
        myNotesUnderlay.isHidden = true
        favoritesUnderlay.isHidden = false
        myNotesTableView.reloadData()
        favoritesTableView.reloadData()
        favoritesView.isHidden = false
        myNotesView.isHidden = true
    }
    
    //TableView Delegate Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(!myNotes) {
            return faveNotes.count
        } else {
            return userNotes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(!myNotes) {
            let cell = favoritesTableView.dequeueReusableCell(withIdentifier: "favoritesCell", for: indexPath) as! FavoritesTableViewCell
            let note: Note
            
            print(String(indexPath.row) + "->" + String(faveNotes.count))
            note = faveNotes[indexPath.row].note
            
            cell.noteImage.image = faveNotes[indexPath.row].profileImage
            cell.profileName.text = note.userName
            cell.noteDescription.text = note.caption
            if(note.seenBy.count == 1) {
                cell.favoritesCount.text = "_♡"
            } else {
                cell.favoritesCount.text = String(note.seenBy.count-1) + "♡"
            }
            
            return cell
            
        } else {
            let cell = myNotesTableView.dequeueReusableCell(withIdentifier: "myNotesCell", for: indexPath) as! ProfileViewControllerTableViewCell
            
            let note: Note
            print(String(indexPath.row) + "->" + String(userNotes.count))
            note = userNotes[indexPath.row].note
            
            cell.noteImage.image = userNotes[indexPath.row].image
            cell.noteDescription.text = note.caption
            if(note.seenBy.count == 1) {
                cell.favoriteCount.text = "_♡"
            } else {
                cell.favoriteCount.text = String(note.seenBy.count-1) + "♡"
            }
            
            return cell
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myNoteImageDetail" {
            if let indexPath = myNotesTableView.indexPathForSelectedRow {
                let selectedRow = indexPath.row
                print("selected row: " + String(selectedRow))
                if let vc = segue.destination as? ImageDetailsViewController {
                    vc.modalPresentationCapturesStatusBarAppearance = true
                    vc.note = self.userNotes[selectedRow].note
                    vc.currentUserImage = self.userNotes[selectedRow].profileImage
                }
            }
        }   else if segue.identifier == "favoriteNoteDetail" {
            if let indexPath = favoritesTableView.indexPathForSelectedRow {
                let selectedRow = indexPath.row
                print("selected row: " + String(selectedRow))
                if let vc = segue.destination as? ImageDetailsViewController {
                    vc.modalPresentationCapturesStatusBarAppearance = true
                    vc.note = self.faveNotes[selectedRow].note
                    vc.currentUserImage = self.faveNotes[selectedRow].profileImage
                }
            }
        }
    }
}
