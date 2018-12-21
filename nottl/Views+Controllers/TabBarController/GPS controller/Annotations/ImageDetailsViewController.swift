//
//  ImageDetailsViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-12-14.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit

class ImageDetailsViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var imageViewButton: UIButton!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var imageFullscreen: UIImageView!
    @IBOutlet weak var fullscreenScroll: UIScrollView!
    @IBOutlet weak var contentCover: UIView!
    
    //removes status bar for fullscreen effect
    override var prefersStatusBarHidden: Bool { return true }
    
    //data source
    var note: Note?
    
    //constant
    let nottlRed = UIColor(red: 179.0/255.0, green: 99.0/255.0, blue: 86/255.0, alpha: 1.0)
    let nottlGrey = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set scrollView for fullscreen image
        self.fullscreenScroll.minimumZoomScale = 1.0;
        self.fullscreenScroll.maximumZoomScale = 6.0;
        self.fullscreenScroll.contentSize = self.imageFullscreen.frame.size;
        self.fullscreenScroll.delegate = self;
        
        //add single tap recognizer to scrollview
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(fullImageDismissed))
        singleTap.cancelsTouchesInView = false
        singleTap.numberOfTapsRequired = 1
        fullscreenScroll.addGestureRecognizer(singleTap)
        
        //add swipe to dismiss gesture recognizer
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerHandler(_:)))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //sets button image as circle
        avatarButton.layer.cornerRadius = 25
        avatarButton.layer.masksToBounds = true
        avatarButton.layer.borderColor = nottlGrey.cgColor
        avatarButton.layer.borderWidth = 2.0
        
        if note != nil {
            imagePreview.image = note?.noteImage
            imageFullscreen.image = note?.noteImage
            avatarButton.setImage(note?.avatar, for: .normal)
            caption.text = note?.caption
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageFullscreen
    }
    
    //presents fullscreen when image preview is selected by fading in
    @IBAction func imagePreviewSelected(_ sender: Any) {
        
        fullscreenScroll.alpha = 0.0
        contentCover.alpha = 0.0
        fullscreenScroll.isHidden = false
        contentCover.isHidden = false
       
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.fullscreenScroll.alpha = 1.0
            self.contentCover.alpha = 1.0
            self.imagePreview.alpha = 0.0
        }, completion: { (value: Bool) in
            self.imagePreview.isHidden = true
        })
    }
    
    //dismisses fullscreen image by fading out
    @objc func fullImageDismissed() {
        
        imagePreview.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.fullscreenScroll.alpha = 0.0
            self.contentCover.alpha = 0.0
            self.imagePreview.alpha = 1.0
        }, completion: { (value: Bool) in
            self.fullscreenScroll.isHidden = true
            self.contentCover.isHidden = true
        })
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
    
    //takes user to profile page of avatar clicked
    @IBAction func profileSelected(_ sender: Any) {
        //still needs implementation
    }
    
    //assigns note to your favorites
    @IBAction func favoritedNote(_ sender: Any) {
        //still needs implementation
    }
    
    //dismiss function
    @IBAction func unwindToInitialVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
