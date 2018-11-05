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
        
        //implements custom annoatation
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
        let newNotes = [["?","skeet","48.4851970875","-123.3252241625","?"],["bong?","skeet","48.4801970875","-123.3252241620","user"],["craiigg","skeet","48.4751970875","-123.3252241620","read"],["crag","skeet","48.4851970870","-123.3352241625","user"],["eric","skeet","48.4851970879","-123.3152241627","user"], ["sket","test","48.46205995","-123.31141980604804","user"]]
        let validGoods = newNotes.compactMap { Note(json: $0) }
        notes.append(contentsOf: validGoods)
    }
    
    func pickupRegionOverlay(){
        for note in notes {
            let center = note.coordinate
            let circle = MKCircle(center: center, radius: 150.0)
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
        circleRenderer.lineWidth = 3
        circleRenderer.lineDashPattern = [6,12]
        circleRenderer.lineJoin = .miter
        return circleRenderer
    }
    

    
    
    //Gonna use this later for placing around notes @ passed location
    /*
     func addNoteCircle(location: CLLocation) {
     let circle = MKCircle(center: location.coordinate, radius: 50 as CLLocationDistance)
     mapView.addOverlay(circle)
     }
     */
    
    //defines overlay to be placed a pickup region
    //Gonnna use this later for placing around notes dropped
    /*
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.init(red: 169/255,green: 103/255,blue: 90/255,alpha: 1.0)
            circle.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 1
            
            return circle
        } else {
            //only way to silence warning for delegate method. Would normally return nil and use optionals, but it is messed up
            return MKPolylineRenderer()
        }
    }
    */
}
