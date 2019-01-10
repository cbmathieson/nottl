//
//  LogOutViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2019-01-02.
//  Copyright © 2019 Craig Mathieson. All rights reserved.
//

import UIKit

class LogOutViewController: UIViewController {

    @IBOutlet weak var failedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        failedLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        if !AuthService.instance.signOut() {
            failedLabel.isHidden = false
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func xButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
