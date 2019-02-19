//
//  GPSViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-10-08.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class GPSViewController: UIViewController, MKMapViewDelegate, NoteDetailMapViewDelegate, ModalDelegate {    
    
    //Outlets
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceFromPinView: UIView!
    @IBOutlet weak var FailedPermissionsView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    //Variables
    var locationManager = CLLocationManager()
    //Global variables
    var isAnimated = false
    var zoomIn = false
    var selectedNote: Note?
    var currentUserImage: UIImage?
    var pins = [NoteAnnotation]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNotesInMap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.definesPresentationContext = true
        
        //initialize location settings
        locationManager.delegate = self
        mapView.delegate = self
        updateMapWithoutAnimation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //add observer for checking location services when entering foreground
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapWithoutAnimation), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    //Functions
    
    //Allow user to change location settings
    @IBAction func changePermissions(_ sender: Any) {
        //set up settings alert
        let alertController = UIAlertController(title: "nottl", message: "Allow \"While in Use\" location services in settings", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        //if button available, location services is off. So we ask to go to settings
        self.present(alertController, animated: true, completion: nil)
    }
    
    //add notes currently in array
    @objc func configureNotesInMap() {
        
        //remove old overlays
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        //get notes from database
        
        //TODO: optimize to only get notes in visible range of the map!!
        //this will mean hopefully figuring out how to grab only certain sections of a dictionary from the database
        Database.database().reference().child("map").observeSingleEvent(of: .value) { (snapshot) in
            if let latDictionary = snapshot.value as? [String: AnyObject] {
                for (lat,value) in latDictionary {
                    if let lonDictionary = value as? [String: AnyObject] {
                        for (lon, value) in lonDictionary {
                            if let noteID = value as? String {
                                
                                guard let coordinate = self.makeCoordinate(lat: lat, lon: lon) else {
                                    print("failed to get coordinates!")
                                    break
                                }
                                
                                print(noteID)
                                
                                let newPin = NoteAnnotation(noteID: noteID, coordinate: coordinate)
                                
                                self.pins.append(newPin)
                            } else {
                                print("could not get noteID :(")
                                break
                            }
                        }
                    }
                }
            }
            
            var annotations = [MKAnnotation]()
            for pin in self.pins {
                annotations.append(pin)
            }
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
        }
    }
    
    func makeCoordinate(lat: String,lon: String) -> CLLocationCoordinate2D? {
        var latArr = lat.compactMap{$0}
        var lonArr = lon.compactMap{$0}
        
        let latLength = latArr.count
        let lonLength = lonArr.count
        
        latArr.insert(".", at: (latLength-5))
        lonArr.insert(".", at: (lonLength-5))
        
        //make sure it will format properly if no leading zero and only decimal
        //-----------
        if(latArr[0] == ".") {
            latArr.insert("0", at: 0)
        } else if latArr[0] == "-" && latArr[1] == "." {
            latArr.insert("0", at: 1)
        }
        
        if(lonArr[0] == ".") {
            lonArr.insert("0", at: 0)
        } else if lonArr[0] == "-" && lonArr[1] == "." {
            lonArr.insert("0", at: 1)
        }
        //-----------
        
        var latStr = ""
        for i in latArr {
            latStr += String(i)
        }
        
        var lonStr = ""
        for i in lonArr {
            lonStr += String(i)
        }
        
        if let latitude = Double(latStr), let longitude = Double(lonStr) {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            return nil
        }
    }
    
    //MKMapViewDelegate methods
    
    //Builds overlay circle for visual representation of note pick up area
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.lightGray.withAlphaComponent(0.5)
        circleRenderer.strokeColor = UIColor(red: 179.0/255.0, green: 99.0/255.0, blue: 86/255.0, alpha: 1.0)
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }
    
    //sets initial geofencing for notes when loaded
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let view = annotation as? MKUserLocation {
            view.title = ""
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "note")
        
        if annotationView == nil {
            annotationView = NoteAnnotationView(annotation: annotation, reuseIdentifier: "note")
            (annotationView as! NoteAnnotationView).noteDetailDelegate = self
        } else {
            annotationView!.annotation = annotation
        }
        
        addOverlay(annotation: annotation)
        return annotationView
    }
    
    //checks to see if user is in note's area
    //Uses Haversine Formula to find distance between note and user
    func inRange(note: Note) -> Int {
        let annotationLatitude = note.latitude
        let annotationLongitude = note.longitude
        
        let userLatitude = locationManager.location!.coordinate.latitude
        let userLongitude = locationManager.location!.coordinate.longitude
        
        //setup for haversine formula
        let earthsRadius: Double = 6371000.0 //in metres
        let aLatRadians = annotationLatitude * (.pi/180)
        let uLatRadians = userLatitude * (.pi/180)
        let latDifference = abs((annotationLatitude - userLatitude) * (.pi/180))
        let longDifference = abs((annotationLongitude - userLongitude) * (.pi/180))
        
        //Haversine formula
        let a = sin(latDifference/2) * sin(latDifference/2)
        let b = cos(aLatRadians) * cos(uLatRadians) * sin(longDifference/2) * sin(longDifference/2)
        let c = a + b
        let d = 2 * atan2(sqrt(c), sqrt(1-c))
        let difference = earthsRadius * d
        
        //send back distance from user to note
        return Int(difference)
    }
    
    func addOverlay(annotation: MKAnnotation) {
        let center = annotation.coordinate
        let circle = MKCircle(center: center, radius: 50.0)
        mapView.addOverlay(circle)
    }
    
    //selecting note and segue to new view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageDetails" {
            if let vc = segue.destination as? ImageDetailsViewController {
                vc.modalPresentationCapturesStatusBarAppearance = true
                vc.note = self.selectedNote
                if let image = self.currentUserImage {
                    vc.currentUserImage = image
                }
            }
            return
        } else if segue.identifier == "viewedBy" {
            if let vc = segue.destination as? SeenByViewController {
                vc.note = self.selectedNote
            }
        }
    }
    
    //if avatar image is selected and within 50m: run segue to fullscreen image
    //else print distance to note on screen
    func detailsRequestedForNote(note: Note, currentAvatarImage: UIImage?) {
        let distance = inRange(note: note)
        if distance < 50 {
            self.selectedNote = note
            self.currentUserImage = currentAvatarImage
            self.performSegue(withIdentifier: "imageDetails", sender: nil)
        } else {
            //break into thousands with commas
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.groupingSeparator = ","
            if let distanceString = numberFormatter.string(from: NSNumber(value: distance)) {
                distanceLabel.text = distanceString + "m out"
                //begin fades...
                UIView.animate(withDuration: 0.5, animations: {
                    self.distanceFromPinView.alpha = 0.5
                    self.distanceLabel.alpha = 1.0
                }) { (finished) in
                    UIView.animate(withDuration: 1.5, animations: {
                        //wait 1.5 secs
                        self.distanceFromPinView.alpha = 0.51
                    }) { (finished) in
                        UIView.animate(withDuration: 0.5, animations: {
                            self.distanceLabel.alpha = 0.0
                            self.distanceFromPinView.alpha = 0.0
                        }) //
                    }
                }
            }
        }
    }
    
    //if user selects "viewed by..." run segue to tableview of users
    func detailsRequestedForSeenBy(note: Note) {
        self.selectedNote = note
        self.performSegue(withIdentifier: "viewedBy", sender: nil)
    }
    
    
    //when share button is pressed in NewNoteVC, form is passed here to create new note
    func addNote(image: UIImage?, caption: String?, isAnonymous: Bool) {
        
        //take uid, avatar, etc from current user and call
        //this with all note information inside a dictionary!
        guard let caption = caption, let image = image else {
            print("nil value for caption/image")
            return
        }
        
        //gets coordinates to set in lists in firebase. Truncates to coordinates within 1.1m
        //which is slightly finer than the accuracy of the gps chip
        let fullLatitude = locationManager.location!.coordinate.latitude
        let fullLongitude = locationManager.location!.coordinate.longitude
        
        let latitude = fullLatitude.truncate(places: 5)!.replacingOccurrences(of: ".", with: "")
        let longitude = fullLongitude.truncate(places: 5)!.replacingOccurrences(of: ".", with: "")
        
        //get current user information
        guard let uid = Auth.auth().currentUser?.uid else {
            print("failed to get user information")
            return
        }
        
        var username: String?
        var profileImageURL: String?
        
        //get user data for note and call DataService to upload
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                username = dictionary["username"] as? String
                profileImageURL = dictionary["profileImageLink"] as? String
                
                if username == nil || profileImageURL == nil {
                    print("failed to fetch userdata")
                    return
                }
                
                let seenBy = ["uids here"]
                
                let newNote = ["uid": uid, "userName": username!, "profileImage": profileImageURL!, "noteImage": "", "caption": caption, "isAnonymous": isAnonymous, "latitude": fullLatitude, "longitude": fullLongitude, "seenBy": seenBy] as [String : Any]
                DataService.instance.createNewNote(noteData: newNote, latitude: latitude, longitude: longitude, noteImage: image, completion: { (success) -> Void in
                    if !success {
                        print("could not add new note, something went wrong uploading :(")
                        print("there may be a note already there")
                    } else {
                        //wait for a sec before updating map
                        self.perform(#selector(self.configureNotesInMap), with: nil, afterDelay: 3.0)
                    }
                })
            }
        }, withCancel: nil)
    }
    
    @IBAction func newNoteButtonPressed(_ sender: Any) {
        let newNoteVC = self.storyboard?.instantiateViewController(withIdentifier: "NewNoteViewController") as! NewNoteViewController
        newNoteVC.delegate = self
        
        newNoteVC.modalPresentationStyle = .overFullScreen
        newNoteVC.modalPresentationCapturesStatusBarAppearance = true
        self.present(newNoteVC, animated: true, completion: nil)
    }
}

extension GPSViewController: CLLocationManagerDelegate {
    
    //Attempt to start CLLocationManager
    func findLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            FailedPermissionsView.isHidden = true
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
            FailedPermissionsView.isHidden = false
        }
    }
    
    @objc func updateMapWithoutAnimation() {
        isAnimated = false
        zoomIn = true
        findLocation()
    }
    
    @objc func updateMapWithAnimation() {
        isAnimated = true
        zoomIn = true
        findLocation()
    }
    
    //Finds location and centers map to it at 325x325 if needed
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        
        //update to default screen when clicking highlighted gps button
        //else just updating for accuracy
        if zoomIn {
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 325, longitudinalMeters: 325)
            mapView.setRegion(coordinateRegion, animated: isAnimated)
        } else {
            mapView.setCenter(location.coordinate, animated: true)
        }
        zoomIn = false
        locationManager.stopUpdatingLocation()
    }
}
