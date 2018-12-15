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

        // Do any additional setup after loading the view.
    }
    

    @IBAction func unwindToInitialVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
