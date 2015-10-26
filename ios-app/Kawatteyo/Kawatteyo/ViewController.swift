//
//  ViewController.swift
//  Kawatteyo
//
//  Created by Satoru Noguchi on 10/26/15.
//  Copyright © 2015 kawatteyo. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var getLocationButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    var isPositionGetting = false
    var mLocationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mLocationManager = CLLocationManager()
        mLocationManager.delegate = self
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if(authorizationStatus == CLAuthorizationStatus.NotDetermined) {
            print("not detrmined")
            self.mLocationManager.requestAlwaysAuthorization()
        }
        
        mLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        mLocationManager.distanceFilter = 100
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func send(sender: AnyObject) {
        if (isPositionGetting) {
            getLocationButton.setTitle("Get position", forState: UIControlState.Normal)
            locationTextField.text = ""
            locationLabel.text = "Enter URL"
            isPositionGetting = false
            return
        }
        
//        if (locationTextField.text == nil || locationTextField.text == "") {
//            locationLabel.text = "Enter a valid URL"
//            return
//        }
        
        mLocationManager.startUpdatingLocation()
        
        getLocationButton.setTitle("Stop", forState: UIControlState.Normal)
        locationLabel.text = "Getting location..."
        isPositionGetting = true
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print("didChangeAuthorizationStatus");
        var statusStr = "";
        
        switch (status) {
        case .NotDetermined:
            statusStr = "NotDetermined"
        case .Restricted:
            statusStr = "Restricted"
        case .Denied:
            statusStr = "Denied"
        case .AuthorizedAlways:
            statusStr = "AuthorizedAlways"
        case .AuthorizedWhenInUse:
            statusStr = "AuthorizedWhenInUse"
        }
        print(" CLAuthorizationStatus: \(statusStr)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("location updated.")
        let timestamp = manager.location!.timestamp
        let latitude = manager.location!.coordinate.latitude
        let longitude = manager.location!.coordinate.longitude
        
        locationLabel.text = "tst: \(timestamp)\n lat: \(latitude) \n lon \(longitude)"
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error")
    }
}

