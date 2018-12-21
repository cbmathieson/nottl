//
//  InitialViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-10-03.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? LogInViewController {
            vc.modalPresentationCapturesStatusBarAppearance = true
        }
        if let vc = segue.destination as? CreateAccountViewController {
            vc.modalPresentationCapturesStatusBarAppearance = true
        }
    }
    
}
