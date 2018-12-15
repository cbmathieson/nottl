//
//  ImageDetailsViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-12-14.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit

class ImageDetailsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var avatarButton: UIButton!
    
    //removes status bar for fullscreen effect
    override var prefersStatusBarHidden: Bool { return true }
    
    //data source
    var note: Note?
    
    //constant
    let nottlRed = UIColor(red: 179.0/255.0, green: 99.0/255.0, blue: 86/255.0, alpha: 1.0)
    let nottlGrey = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //sets button image as circle
        avatarButton.layer.cornerRadius = 25
        avatarButton.layer.masksToBounds = true
        avatarButton.layer.borderColor = nottlGrey.cgColor
        avatarButton.layer.borderWidth = 2.0
        
        if note != nil {
            imageView.image = note?.noteImage
            avatarButton.setImage(note?.avatar, for: .normal)
            caption.text = note?.caption
        }
    }
    
    //takes user to profile page of avatar clicked
    @IBAction func profileSelected(_ sender: Any) {
        //still needs implementation
    }
    
    //assigns note to your favorites
    @IBAction func favoritedNote(_ sender: Any) {
        //still needs implementation
    }
    
    //dismiss function
    @IBAction func unwindToInitialVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
