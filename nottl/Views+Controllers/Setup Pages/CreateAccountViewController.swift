//
//  CreateAccountViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-10-03.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import Foundation
import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var newUserName: UITextField!
    @IBOutlet weak var newEmailAddress: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var inputErrorLabel: UILabel!
    
    //brackets to go around incorrect text inputs
    @IBOutlet weak var userNameLeft: UILabel!
    @IBOutlet weak var userNameRight: UILabel!
    @IBOutlet weak var emailLeft: UILabel!
    @IBOutlet weak var emailRight: UILabel!
    @IBOutlet weak var pass1Left: UILabel!
    @IBOutlet weak var pass1Right: UILabel!
    @IBOutlet weak var pass2Left: UILabel!
    @IBOutlet weak var pass2Right: UILabel!
    
    //removes status bar for fullscreen effect
    override var prefersStatusBarHidden: Bool { return true }
    
    var isKeyboardActive = false
    let nottlRed = UIColor(red: 179.0/255.0, green: 99.0/255.0, blue: 86/255.0, alpha: 1.0)
    let nottlGrey = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.newUserName.delegate = self
        self.newEmailAddress.delegate = self
        self.newPassword.delegate = self
        self.confirmPassword.delegate = self
        
        //add keyboard observers to adjust view
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //add swipe to dismiss gesture recognizer
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler(_:)))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //remove keyboard observers
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //resets view if keyboard leaves
    @objc func keyboardWillHide() {
        self.view.frame.origin.y = 0
    }
    
    //detects off keyboard actions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //moves view up when keyboard is presented
    @objc func keyboardWillChange(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if newUserName.isFirstResponder || newEmailAddress.isFirstResponder || newPassword.isFirstResponder || confirmPassword.isFirstResponder {
                self.view.frame.origin.y = -keyboardSize.height/2
            }
        }
    }

    
    //moves textfields after next is pressed or sends data if last textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == confirmPassword {
            confirmPassword.resignFirstResponder()
            createAccount(nil)
        } else if textField == newUserName {
            newEmailAddress.becomeFirstResponder()
        } else if textField == newEmailAddress {
            newPassword.becomeFirstResponder()
        } else if textField == newPassword {
            confirmPassword.becomeFirstResponder()
        }
        return true
    }

    @IBAction func unwindToInitialVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createAccount(_ sender: Any?) {
        //once database is setup: will implement
        self.view.window?.endEditing(true)
        if checkInputs(username: newUserName.text, email: newEmailAddress.text, password: newPassword.text, password2: confirmPassword.text) {
            //send data
            performSegue(withIdentifier: "createAccountSegue", sender: nil)
        }
    }
    
    //checks validity of values passed
    func checkInputs(username: String?, email: String?, password: String?, password2: String?) -> Bool {
        
        //reset input error indicators
        inputErrorLabel.isHidden = true
        
        userNameLeft.isHidden = true
        userNameRight.isHidden = true
        emailLeft.isHidden = true
        emailRight.isHidden = true
        pass1Left.isHidden = true
        pass1Right.isHidden = true
        pass2Left.isHidden = true
        pass2Right.isHidden = true

        guard let usrName = username, let eml = email, let pass = password, let pass2 = password2 else {
            inputErrorLabel.text = "something went wrong :("
            inputErrorLabel.isHidden = false
            return false
        }

        if !usrName.matches("\\w+$"){
            inputErrorLabel.text = "numbers, letters, and _ only"
            inputErrorLabel.isHidden = false
            userNameLeft.isHidden = false
            userNameRight.isHidden = false
            return false
        }
        
        //RFC 5322 regex email match
        if !eml.matches("(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
            "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
            "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])") {
            
            inputErrorLabel.text = "invalid email address"
            inputErrorLabel.isHidden = false
            
            emailLeft.isHidden = false
            emailRight.isHidden = false
            
            return false
        }
        
        if pass.count < 8 {
            inputErrorLabel.text = "give it at least 8 characers"
            inputErrorLabel.isHidden = false
            pass1Left.isHidden = false
            pass1Right.isHidden = false
            return false
        }
        
        //check if values are what we want from the user
        if pass != pass2 {
            inputErrorLabel.text = "passwords must match"
            inputErrorLabel.isHidden = false
            pass2Left.isHidden = false
            pass2Right.isHidden = false
            return false
        }
        return true
    }
    
    var initialTouchPoint = CGPoint.zero
    
    @IBAction func panGestureRecognizerHandler(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: view?.window)
        
        switch sender.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            if touchPoint.y > initialTouchPoint.y {
                view.frame.origin.y = (touchPoint.y - initialTouchPoint.y)
            }
        case .ended, .cancelled:
            if touchPoint.y - initialTouchPoint.y > 150 {
                dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.frame = CGRect(x: 0,
                                             y: 0,
                                             width: self.view.frame.size.width,
                                             height: self.view.frame.size.height)
                })
            }
        case .failed, .possible:
            break
        }
    }
    
}

extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
