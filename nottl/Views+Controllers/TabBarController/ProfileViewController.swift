//
//  ProfileViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-10-08.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var myNotesButton: UIButton!
    @IBOutlet weak var myFavoritesButton: UIButton!
    
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
    
    @IBAction func myNotesPressed(_ sender: Any) {
        myNotes = true
        myNotesButton.setTitleColor(nottlRed, for: .normal)
        myFavoritesButton.setTitleColor(nottlGrey, for: .normal)
    }
    
    @IBAction func favoritesPressed(_ sender: Any) {
        myNotes = false
        myNotesButton.setTitleColor(nottlGrey, for: .normal)
        myFavoritesButton.setTitleColor(nottlRed, for: .normal)
    }
    
}
