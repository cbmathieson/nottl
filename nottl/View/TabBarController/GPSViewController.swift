//
//  GPSViewController.swift
//  nottl
//
//  Created by Craig Mathieson on 2018-10-08.
//  Copyright © 2018 Craig Mathieson. All rights reserved.
//

import UIKit
import MapKit

class GPSViewController: UIViewController, CLLocationManagerDelegate {
    
    //Outlets
    @IBOutlet weak var FailedPermissionsView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    //Variables
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //finds location
        locationManager.delegate = self
        findLocation()
        //add observer for checking location services when entering foreground
        NotificationCenter.default.addObserver(self, selector: #selector(findLocation), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    //Functions
    
    //Allow user to change location settings
    @IBAction func changePermissions(_ sender: Any) {
        //set up settings alert
        let alertController = UIAlertController(title: "nottl", message: "Allow \"While Using the App\" location services for nottl", preferredStyle: .alert)
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
        
        //if button available, location services must be off. So we ask to go to settings
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //Start CLLocationManager
    @objc func findLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
            FailedPermissionsView.isHidden = false
        } else {
            FailedPermissionsView.isHidden = true
            locationManager.startUpdatingLocation()
        }
    }
    
    //Finds location and centers map to it at 400x400
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 400, longitudinalMeters: 400)
        mapView.setRegion(coordinateRegion, animated: true)
        locationManager.stopUpdatingLocation()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
