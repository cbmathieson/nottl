//
//  GPSViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-10-08.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit
import MapKit

class GPSViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var FailedPermissionsView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    //Variables
    var locationManager = CLLocationManager()
    var notes: [Note] = []
    //Global variables
    var isAnimated = false
    var zoomIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initialize location settings
        locationManager.delegate = self
        mapView.delegate = self
        updateMapWithoutAnimation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //add observer for checking location services when entering foreground
        NotificationCenter.default.addObserver(self, selector: #selector(updateMapWithoutAnimation), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        //implements custom annotation
       mapView.register(NoteMarkerView.self,forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        //adding notes for map
        loadInitialData()
        pickupRegionOverlay()
        mapView.addAnnotations(notes)
        
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
    
    //will load data from database but right now we just loading in tests
    func loadInitialData() {
        let newNotes = [["00000001","?","skeet","48.4851970875","-123.3252241625","?"],["00000002","bong?","skeet","48.4801970875","-123.3252241620","user"],["00000003","craiigg","skeet","48.4751970875","-123.3252241620","read"],["00000004","crag","skeet","48.4851970870","-123.3352241625","user"],["00000005","eric","skeet","48.4851970879","-123.3152241627","user"], ["00000006","sket","test","48.46205995","-123.31141980604804","user"], ["00000007","paige","test","48.46369387570571","-123.30975823961442", "user"]]
        let validGoods = newNotes.compactMap { Note(json: $0) }
        notes.append(contentsOf: validGoods)
    }
    
    //adds 50m radius circle around annotations for visual representation
    func pickupRegionOverlay(){
        for note in notes {
            let center = note.coordinate
            let circle = MKCircle(center: center, radius: 50.0)
            mapView.addOverlay(circle)
        }
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

extension GPSViewController: MKMapViewDelegate {
    
    //Builds overlay circle for visual representation of note pick up area
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.lightGray.withAlphaComponent(0.5)
        circleRenderer.strokeColor = UIColor.red
        circleRenderer.lineWidth = 0.1
        return circleRenderer
    }
    
    //still fucking broken
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let view = annotation as? MKUserLocation {
            view.title = ""
            return nil
        }
 
        let annotationView = NoteMarkerView(annotation: annotation, reuseIdentifier: "note")
        annotationView.canShowCallout = inRange(annotation: annotation)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            if let view = annotation as? MKUserLocation {
                view.title = ""
            } else {
                if inRange(annotation: annotation) {
                    view.canShowCallout = true
                } else {
                    mapView.deselectAnnotation(annotation, animated: false)
                    view.canShowCallout = false
                }
            }
        }
    }
    
    //checks to see if user is in note's area
    //Uses the Haversine Formula to find distance between note and user
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
}
