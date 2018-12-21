//
//  LogInViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-10-03.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userNameLeft: UILabel!
    @IBOutlet weak var userNameRight: UILabel!
    @IBOutlet weak var passLeft: UILabel!
    @IBOutlet weak var passRight: UILabel!
    
    
    @IBOutlet weak var inputErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    //removes status bar for fullscreen effect
    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.passwordTextField.delegate = self
        self.usernameTextField.delegate = self
        
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
            if passwordTextField.isFirstResponder || usernameTextField.isFirstResponder {
                self.view.frame.origin.y = -keyboardSize.height/2
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            logInButtonPressed(nil)
        } else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
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
    
    @IBAction func unwindToInitialVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logInButtonPressed(_ sender: Any?) {
        
        self.view.endEditing(true)
        
        if checkInputs(username: usernameTextField.text, password: passwordTextField.text) {
            performSegue(withIdentifier: "logInSegue", sender: nil)
        }
    }
    
    func checkInputs(username: String?, password: String?) -> Bool {
        
        inputErrorLabel.isHidden = true
        userNameLeft.isHidden = true
        userNameRight.isHidden = true
        passLeft.isHidden = true
        passRight.isHidden = true
        
        guard let usrName = username, let pass = password else {
            inputErrorLabel.text = "something went wrong :("
            inputErrorLabel.isHidden = false
            return false
        }
        
        if !usrName.matches("\\w+$"){
            inputErrorLabel.text = "invalid username :("
            inputErrorLabel.isHidden = false
            userNameLeft.isHidden = false
            userNameRight.isHidden = false
            return false
        }
        
        if pass.count < 8 {
            inputErrorLabel.text = "it's at least 8 characers..."
            inputErrorLabel.isHidden = false
            passLeft.isHidden = false
            passRight.isHidden = false
            return false
        }
        
        return true
    }
    
    
}
