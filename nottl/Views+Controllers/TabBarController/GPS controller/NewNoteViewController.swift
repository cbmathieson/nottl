//
//  NewNoteViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-12-12.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit

protocol ModalDelegate {
    func addNote(image: UIImage?, caption: String?, isAnonymous: Bool)
}

class NewNoteViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //removes status bar for fullscreen effect
    override var prefersStatusBarHidden: Bool { return true }

    @IBOutlet weak var topLeftImageButton: UIButton!
    @IBOutlet weak var plzLabel: UILabel!
    @IBOutlet weak var imgButton: UIButton!
    @IBOutlet weak var newImageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    var imagepickerActivated = false
    var delegate:ModalDelegate!
    var isAnonymous = false
    let nottlRed = UIColor(red: 179.0/255.0, green: 99.0/255.0, blue: 86/255.0, alpha: 1.0)
    let nottlGrey = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.captionTextField.delegate = self
        
        //add keyboard observers to adjust view
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler(_:)))
        view.addGestureRecognizer(gestureRecognizer)
        
        statusBarHeight = getStatusBarHeight()
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if !imagepickerActivated {
            print("this is a view leaving")
            //remove keyboard observers
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        } else {
            print("this is image Picker")
            imagepickerActivated = false
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
            if captionTextField.isFirstResponder {
                self.view.frame.origin.y = -keyboardSize.height/2
            }
        }
    }
    
    @IBAction func unwindToInitialVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    //called when user selects image icon; opens up imagepicker
    @IBAction func chooseImage(_ sender: Any) {
        
        imagepickerActivated = true
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
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
    
    @IBAction func yesButtonPressed(_ sender: Any) {
        isAnonymous = true
        yesButton.setTitleColor(nottlRed, for: .normal)
        noButton.setTitleColor(nottlGrey, for: .normal)
    }
    
    @IBAction func noButtonPressed(_ sender: Any) {
        isAnonymous = false
        noButton.setTitleColor(nottlRed, for: .normal)
        yesButton.setTitleColor(nottlGrey, for: .normal)
    }
    
    //when image has been chosen in image picker, then we update UIImageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        newImageView.image = image
        imgButton.isEnabled = false
        topLeftImageButton.isHidden = false
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    //Dismiss image picker on cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //hides keyboard on return press
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //when share button is pressed, sends data to parent view to deal with
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        if let newImage = newImageView.image {
            delegate?.addNote(image: newImage, caption: captionTextField.text, isAnonymous: isAnonymous)
            self.dismiss(animated: true, completion: nil)
        } else {
            plzLabel.isHidden = false
        }
    }
    
    //gets height of status bar to account when swiping down to dismiss
    func getStatusBarHeight() -> CGFloat {
        //gets actual height of frame since status bar is present
        let statusBarSize = UIApplication.shared.statusBarFrame.size
        return Swift.min(statusBarSize.width, statusBarSize.height)
    }
    
    //dismiss view when swiped down
    var initialTouchPoint = CGPoint.zero
    var statusBarHeight: CGFloat = 0.0
    
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
