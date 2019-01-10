//
//  SeenByViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-12-14.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit

class SeenByViewController: UIViewController {
    
    var note: Note?

    override func viewDidLoad() {
        super.viewDidLoad()

        //TODO: Take data and build a table view for the accounts who have seen the note
    }
    

    @IBAction func unwindToInitialVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
