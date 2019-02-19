//
//  ProfileViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-10-08.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    //profile information
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    
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
        
        profileImageView.layer.cornerRadius = 37.5
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = nottlRed.cgColor
        profileImageView.layer.borderWidth = 2.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchUserData()
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
                
                //will implement notes/favorites table later on...
            }
        }, withCancel: nil)
        
    }
    
    @IBAction func myNotesPressed(_ sender: Any) {
        myNotes = true
        myNotesButton.setTitleColor(nottlRed, for: .normal)
        myFavoritesButton.setTitleColor(nottlGrey, for: .normal)
        myNotesUnderlay.isHidden = false
        favoritesUnderlay.isHidden = true
    }
    
    @IBAction func favoritesPressed(_ sender: Any) {
        myNotes = false
        myNotesButton.setTitleColor(nottlGrey, for: .normal)
        myFavoritesButton.setTitleColor(nottlRed, for: .normal)
        myNotesUnderlay.isHidden = true
        favoritesUnderlay.isHidden = false
    }
    
}
