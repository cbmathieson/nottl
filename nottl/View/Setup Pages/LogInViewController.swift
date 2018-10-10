//
//  LogInViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-10-03.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwindToInitialVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //Sets initial view for tabBar to center when transitioning
    //Failed to impliment it within the UITabBarController. Will need to add it when opening app already logged in
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabBarController = segue.destination as! UITabBarController
        
        tabBarController.selectedIndex = 1
    }
 
}
