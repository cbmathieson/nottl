//
//  AuthService.swift
//  nottl
//
//  Created by Craig Mathieson on 2019-01-02.
//  Copyright © 2019 Craig Mathieson. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

class AuthService {
    static let instance = AuthService()
    
    func registerUser(withEmail email: String, andPassword password: String, username: String, profileImage: UIImage, userCreationCompleted: @escaping(_ status: Bool, _ error: Error?) -> ()) {
        //attempt to create user with firebase
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            //check if authResult returns a valid user
            guard let user = user?.user else {
                userCreationCompleted(false, error)
                return
            }
            
            var profileUploadSuccess = true
            var profileImageLink = ""
            
            //upload image to firebase storage
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_pictures/\(imageName).jpg")
            if let uploadData = profileImage.compressImage(maxHeight: 75.0, maxWidth: 75.0, compressionQuality: 0.8) {
                storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                    if error != nil {
                        print(String(describing: error))
                        //ABORT!!!!!!
                        profileUploadSuccess = false
                        return
                    }
                    
                    //once upload completes, get url
                    storageRef.downloadURL(completion: { (url, error) in
                        if let link = url?.absoluteString {
                            profileImageLink = link
                        } else {
                            profileUploadSuccess = false
                        }
                        
                        if !profileUploadSuccess {
                            return
                        }
                        
                        //if successful, add the new user to the database
                        //Adding ability to add captions later on...
                        let favorites = ["favorite notes here"]
                        let myNotes = ["my notes here"]
                        
                        let userData = ["provider": user.providerID, "email": user.email!, "username": username, "caption": "", "profileImageLink": profileImageLink, "favorites": favorites, "myNotes": myNotes] as [String: Any]
                        DataService.instance.createDBUser(uid: user.uid, userData: userData as Dictionary<String, Any>)
                        userCreationCompleted(true, nil)
                    })
                }
            }
            
        }
    }
    
    func loginUser(withEmail email: String, andPassword password: String, loginCompleted: @escaping(_ status: Bool, _ error: Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if error != nil {
                loginCompleted(false, error)
                return
            }
            
            loginCompleted(true, nil)
        }
    }
    
    func sendEmailVerification() -> Bool {
        var success = true
        Auth.auth().currentUser?.sendEmailVerification { (error) in
            if error != nil {
                print(String(describing: error?.localizedDescription))
                success = false
            }
        }
        return success
    }
    
    func checkVerification() -> Bool {
        guard let isVerified = Auth.auth().currentUser?.isEmailVerified else {
            print("failed to get user info")
            return false
        }
        return isVerified
    }
    
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
        } catch let err {
            print(err)
            return false
        }
        return true
    }
}
