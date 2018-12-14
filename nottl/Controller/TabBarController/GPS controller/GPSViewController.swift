//
//  GPSViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-10-08.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit
import MapKit

class GPSViewController: UIViewController, MKMapViewDelegate, NoteDetailMapViewDelegate {
    
    //Outlets
    @IBOutlet weak var FailedPermissionsView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    //Variables
    var locationManager = CLLocationManager()
    //Global variables
    var isAnimated = false
    var zoomIn = false
    var selectedNote: Note?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNotesInMap()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    //add singleton testing notes
    func configureNotesInMap() {
        var annotations = [MKAnnotation]()
        for note in NoteManager.sharedInstance.notes {
            let annotation = NoteAnnotation(note: note)
            annotations.append(annotation)
        }
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotations)
    }
    
    //MKMapViewDelegate methods
    
    //Builds overlay circle for visual representation of note pick up area
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.lightGray.withAlphaComponent(0.5)
        circleRenderer.strokeColor = UIColor(red: 179.0/255.0, green: 99.0/255.0, blue: 86/255.0, alpha: 1.0)
        circleRenderer.lineWidth = 0.5
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
        annotationView?.isEnabled = inRange(annotation: annotation)
        return annotationView
    }
    
    //rechecks if note is within distance when tapped
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            if let view = annotation as? MKUserLocation {
                view.title = ""
            } else {
                if inRange(annotation: annotation) {
                    view.isEnabled = true
                } else {
                    mapView.deselectAnnotation(annotation, animated: false)
                    view.isEnabled = false
                }
            }
        }
    }
    
    //checks to see if user is in note's area
    //Uses Haversine Formula to find distance between note and user
    func inRange(annotation: MKAnnotation) -> Bool {
        let annotationLatitude = annotation.coordinate.latitude
        let annotationLongitude = annotation.coordinate.longitude
        
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
        
        //check if user within 50m
        return difference < 50.0
    }
    
    func addOverlay(annotation: MKAnnotation) {
        let center = annotation.coordinate
        let circle = MKCircle(center: center, radius: 50.0)
        mapView.addOverlay(circle)
    }
    
    //selecting note and segue to new view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        /*if segue.identifier == "imageDetails" {
            if let vc = segue.destination as? NoteDetailsViewController {
                vc.note = self.selectedNote
            }
        } else if segue.identifier == "viewedBy" {
            if let vc = segue.destination as? SeenByViewController {
                vc.note = self.selectedNote
            }
        }*/
    }
    
    //if avatar image is selected: run segue to fullscreen image
    func detailsRequestedForNote(note: Note) {
        self.selectedNote = note
        self.performSegue(withIdentifier: "imageDetails", sender: nil)
    }
    
    //if user selects "viewed by..." run segue to tableview of users
    func detailsRequestedForSeenBy(note: Note) {
        self.selectedNote = note
        self.performSegue(withIdentifier: "viewedBy", sender: nil)
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
