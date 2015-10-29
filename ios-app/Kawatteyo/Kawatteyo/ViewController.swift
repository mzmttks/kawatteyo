//
//  ViewController.swift
//  Kawatteyo
//
//  Created by Satoru Noguchi on 10/26/15.
//  Copyright © 2015 kawatteyo. All rights reserved.
//

import UIKit
import CoreLocation
import Starscream

class ViewController: UIViewController, CLLocationManagerDelegate, WebSocketDelegate{

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var getLocationButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    var isPositionGetting = false
    var mLocationManager: CLLocationManager!
    var socket = WebSocket(url: NSURL(string: "ws://localhost:8080/")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        socket.delegate = self
        
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

    // ----- WebcSocket Delegates ------
    func websocketDidConnect(ws: WebSocket) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(ws: WebSocket, error: NSError?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(ws: WebSocket, text: String) {
        print("Received text: \(text)")
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        print("Received data: \(data.length)")
    } // ----------------------------------
    
    
    // ----- CLLocationManager Delegates -----
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
    } // ----------------------------------
    
    @IBAction func send(sender: AnyObject) {
        
//        if (locationTextField.text == nil || locationTextField.text == "") {
//            locationLabel.text = "Enter a valid resource path"
//            return
//        }

        if socket.isConnected {
            getLocationButton.setTitle("Connect", forState: UIControlState.Normal)
            socket.disconnect()
        } else {
            getLocationButton.setTitle("Disconnect", forState: UIControlState.Normal)
            socket.connect()
        }
        
//        if (isPositionGetting) {
//            getLocationButton.setTitle("Start", forState: UIControlState.Normal)
//            locationLabel.text = ""
//            isPositionGetting = false
//            return
//        }
//        
//        if (locationTextField.text == nil || locationTextField.text == "") {
//            locationLabel.text = "Enter a valid WebSocket Server's URL"
//            return
//        }
//        
//        mLocationManager.startUpdatingLocation()
//        
//        getLocationButton.setTitle("Stop", forState: UIControlState.Normal)
//        locationLabel.text = "Getting location..."
//        isPositionGetting = true
    }
}

