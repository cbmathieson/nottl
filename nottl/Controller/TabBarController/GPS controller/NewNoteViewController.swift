//
//  NewNoteViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-12-12.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit

class NewNoteViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var newImageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    var isAnonymous = false
    let nottlRed = UIColor(red: 179.0/255.0, green: 99.0/255.0, blue: 86/255.0, alpha: 1.0)
    let nottlGrey = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.captionTextField.delegate = self
    }
    
    @IBAction func unwindToInitialVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //called when user selects image icon; opens up imagepicker
    @IBAction func chooseImage(_ sender: Any) {
        
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

}
