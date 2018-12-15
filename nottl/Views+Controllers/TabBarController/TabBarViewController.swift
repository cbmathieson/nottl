//
//  TabBarViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-10-08.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.delegate = self
        //Initial view is GPS page
        self.selectedIndex = 1
    }
    
    //checks if already on gps tab when clicked, if so: resets location
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if tabBarController.selectedIndex == 1 {
            if let gpsVC = viewController as? GPSViewController {
                gpsVC.updateMapWithAnimation()
            }
        }
        return true
    }
}
