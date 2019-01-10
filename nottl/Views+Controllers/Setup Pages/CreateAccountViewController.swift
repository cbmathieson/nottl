//
//  CreateAccountViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-10-03.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import Foundation
import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var newUserName: UITextField!
    @IBOutlet weak var newEmailAddress: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var inputErrorLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var imageSelectButton: UIButton!
    
    //brackets to go around incorrect text inputs
    @IBOutlet weak var userNameLeft: UILabel!
    @IBOutlet weak var userNameRight: UILabel!
    @IBOutlet weak var emailLeft: UILabel!
    @IBOutlet weak var emailRight: UILabel!
    @IBOutlet weak var passwordLeft: UILabel!
    @IBOutlet weak var passwordRight: UILabel!
    
    //removes status bar for fullscreen effect
    override var prefersStatusBarHidden: Bool { return true }
    var imagePickerActivated = false
    var imageChosen: UIImage? = nil
    
    var isKeyboardActive = false
    let nottlRed = UIColor(red: 179.0/255.0, green: 99.0/255.0, blue: 86/255.0, alpha: 1.0)
    let nottlGrey = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.newUserName.delegate = self
        self.newEmailAddress.delegate = self
        self.newPassword.delegate = self
        
        profileImageView.layer.cornerRadius = 37.5
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = nottlRed.cgColor
        profileImageView.layer.borderWidth = 2.0
        
        //add keyboard observers to adjust view
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //add swipe to dismiss gesture recognizer
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler(_:)))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !imagePickerActivated {
            //remove keyboard observers
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        } else {
            imagePickerActivated = false
        }
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
            if newUserName.isFirstResponder || newEmailAddress.isFirstResponder || newPassword.isFirstResponder {
                self.view.frame.origin.y = -keyboardSize.height/2
            }
        }
    }

    
    //moves textfields after next is pressed or sends data if last textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == newUserName {
            newEmailAddress.becomeFirstResponder()
        } else if textField == newEmailAddress {
            newPassword.becomeFirstResponder()
        } else if textField == newPassword {
            createAccount(nil)
        }
        return true
    }

    @IBAction func unwindToInitialVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectImageButtonPressed(_ sender: Any) {
        imagePickerActivated = true
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.modalPresentationStyle = .overCurrentContext
        
        //makes user choose photos or camera as source
        let actionSheet = UIAlertController(title: "Note Image", message: "Choose a source", preferredStyle: .actionSheet)
        
        //camera option
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera not available")
            }
        }))
        
        //photos option
        actionSheet.addAction(UIAlertAction(title: "Photos", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        //cancel button
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.image = image
            imageSelectButton.setTitle("", for: .normal)
            imageChosen = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = image
            imageSelectButton.setTitle("", for: .normal)
            imageChosen = image
        } else {
            print("something went wrong :(")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createAccount(_ sender: Any?) {
        self.view.window?.endEditing(true)
        if startRegistration(username: newUserName.text, email: newEmailAddress.text, password: newPassword.text) {
            performSegue(withIdentifier: "createAccountSegue", sender: nil)
        } else {
            inputErrorLabel.text = "could not complete registration :("
            inputErrorLabel.isHidden = false
        }
    }
    
    //checks validity of values passed
    func startRegistration(username: String?, email: String?, password: String?) -> Bool {
        
        //reset input error indicators
        inputErrorLabel.isHidden = true
        
        userNameLeft.isHidden = true
        userNameRight.isHidden = true
        emailLeft.isHidden = true
        emailRight.isHidden = true
        passwordRight.isHidden = true
        passwordLeft.isHidden = true

        guard let usrName = username, let eml = email, let pass = password else {
            inputErrorLabel.text = "something went wrong :("
            inputErrorLabel.isHidden = false
            return false
        }

        if !usrName.matches("^\\w+$") {
            inputErrorLabel.text = "numbers, letters, _ only"
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
            passwordLeft.isHidden = false
            passwordRight.isHidden = false
            inputErrorLabel.text = "Give it at least 8 characters"
            inputErrorLabel.isHidden = false
            return false
        }
        
        guard var image = imageChosen else {
            inputErrorLabel.text = "please select a profile image"
            inputErrorLabel.isHidden = false
            return false
        }
        
        //make image 75*75
        image = image.imageWith(newSize: CGSize(width: 75, height: 75))
        
        var registrationSuccess = true

        AuthService.instance.registerUser(withEmail: eml, andPassword: pass, username: usrName, profileImage: image, userCreationCompleted: { (success, registrationError) in
            if success {
                AuthService.instance.loginUser(withEmail: eml, andPassword: pass, loginCompleted: { (success, nil) in
                    if !AuthService.instance.sendEmailVerification() {
                        registrationSuccess = false
                    }
                })
            } else {
                print(String(describing: registrationError?.localizedDescription))
                registrationSuccess = false
            }
        })
        return registrationSuccess
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
            
            let velocity = sender.velocity(in: view).y
            
            if touchPoint.y - initialTouchPoint.y > 150 || velocity > 1000 {
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
