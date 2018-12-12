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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let red = UIColor(red: 179.0/255.0, green: 99.0/255.0, blue: 86/255.0, alpha: 1.0)
        
        profileImageView.layer.cornerRadius = 37.5
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = red.cgColor
        profileImageView.layer.borderWidth = 2.0
        
    }
}
