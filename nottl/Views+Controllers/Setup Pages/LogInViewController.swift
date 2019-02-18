//
//  LogInViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-12-23.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailLeft: UILabel!
    @IBOutlet weak var emailRight: UILabel!
    @IBOutlet weak var passwordLeft: UILabel!
    @IBOutlet weak var passwordRight: UILabel!
    
    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
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
            if emailTextField.isFirstResponder || passwordTextField.isFirstResponder {
                self.view.frame.origin.y = -keyboardSize.height/2
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            logInButtonPressed(self)
        }
        return true
    }
    
    var initialTouchPoint = CGPoint.zero
    
    //allows user to swipe down to dismiss
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
            let velocity = sender.velocity(in: view).y
            
            if touchPoint.x - initialTouchPoint.y > 150 || velocity > 1000 {
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
    
    func checkInputs(email: String?, password: String?) {
        
        errorLabel.isHidden = true
        emailLeft.isHidden = true
        emailRight.isHidden = true
        passwordLeft.isHidden = true
        passwordRight.isHidden = true
        
        guard let eml = email else {
            return
        }
        
        guard let pass = password else {
            return
        }
        
        //RFC 5322 regex email match
        if !eml.matches("(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" +
            "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
            "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])") {
            
            errorLabel.text = "invalid email address"
            errorLabel.isHidden = false
            
            emailLeft.isHidden = false
            emailRight.isHidden = false
            
            return
        }
        
        if pass.count < 8 {
            passwordLeft.isHidden = false
            passwordRight.isHidden = false
            errorLabel.text = "invalid password"
            errorLabel.isHidden = false
            return
        }
        
        //if checks pass, then send data to firbase auth
        AuthService.instance.loginUser(withEmail: eml, andPassword: pass) { (success, loginError) in
            print(String(describing: loginError))
            if success {
                //NOT PERFECT -> want to be able to dismiss to mapVC from login screen but currently cant while being able to swipe to dismiss to AuthVC
                if AuthService.instance.checkVerification() {
                    self.dismiss(animated: true, completion: nil)
                    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                } else {
                    self.errorLabel.text = "account has not been verified"
                    self.errorLabel.isHidden = false
                    self.emailLeft.isHidden = false
                    self.emailRight.isHidden = false
                    self.passwordLeft.isHidden = false
                    self.passwordRight.isHidden = false
                }
            } else {
                self.errorLabel.text = "invalid password or username"
                self.errorLabel.isHidden = false
                self.emailLeft.isHidden = false
                self.emailRight.isHidden = false
                self.passwordLeft.isHidden = false
                self.passwordRight.isHidden = false
            }
        }
    }
    
    @IBAction func logInButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        
        checkInputs(email: emailTextField.text, password: passwordTextField.text)
        
    }
}
