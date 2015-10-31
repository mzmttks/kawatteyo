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
import AVFoundation

class ViewController: UIViewController, CLLocationManagerDelegate, WebSocketDelegate, UITextFieldDelegate{

    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var getLocationButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!

    var isPositionGetting = false
    var mLocationManager: CLLocationManager!
//    var socket = WebSocket(url: NSURL(string: "ws://localhost:8080/socket")!)
    var socket = WebSocket(url: NSURL(string: "ws://dev.hosts.hark.jp:8080/socket")!)
    var myUuid: String!
    var myUserId = "Your Name" // default

    override func viewDidLoad() {
        super.viewDidLoad()
        socket.delegate = self
        userIdTextField.delegate = self
        
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        userIdTextField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Broadcast kawatteyo message
    @IBAction func kawatteyo(sender: AnyObject) {
        print("in kawatteyo")
        sendKawatteyo()
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
        print("Message received: \(text)")
        
        let receivedMessage = parseMessage(text)
        // Drop message if it cannot be parsed
        if receivedMessage as! NSObject == 0 {
            print("error")
            return
        }
        
        // Drop my own message
        if receivedMessage["from"] != nil {
            let from = receivedMessage["from"] as! String
            print("from=\(from)")
            
            if from == "client" {
                return
            }
        }
        
        // --- Message handling ---
        if ((receivedMessage["uuid"] as! String?) != nil) {
            // Channel identifier generation result
            print("@@@@uuid=\(receivedMessage["uuid"])")
            
            self.myUuid = receivedMessage["uuid"] as! String
            registerUserId()
            return
        }
        
//        if (receivedMessage["type"] as! String?) != nil && receivedMessage["type"] as! String == "Registered" {
//            // user registration result
//            print("Registered")
//            return
//        }
        
        if (receivedMessage["type"] as! String?) != nil {

            if (receivedMessage["type"] as! String) == "Registered" {
                // user registration result, do nothing so far
                print("Registered")
                return
            }
            
            if (receivedMessage["type"] as! String) == "Kawatteyo" {
                // Kawatteyo broadcast, notfiy user
                handleKawatteyo()
                return
            }
        }
        
        if (receivedMessage["message"] as! String?) != nil {
            
            if (receivedMessage["message"] as! String) == "Kawatteyo" {
                
                if (receivedMessage["user"] as! String) == self.myUserId {
                    // if this message is from myself, skip
                    return
                }
                
                // Kawatteyo broadcast, notfiy user
                handleKawatteyo()
                return
            }
        }

    }
    
    func handleKawatteyo() {
        print("in handleKawatteyo")
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        let alert = UIAlertView()
        alert.title = "Kawatteyo"
        alert.message = "かわってよ"
        alert.addButtonWithTitle("OK")
        alert.show()
    }
    
    func parseMessage(message: String) -> AnyObject {
        let data = message.dataUsingEncoding(NSUTF8StringEncoding)
        do{
            let jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
            return jsonArray
        } catch{
            print("error")
            return 0
        }
    }
    
    func sendKawatteyo() {
        print("in sendKawatteyo")
        let message = "{\"from\":\"client\", \"command\":\"Kawatteyo\", \"uuid\":\"\(self.myUuid)\"}"
        socket.writeString(message)
    }
    
    func registerUserId() {
        self.myUserId = userIdTextField.text!
        
        let message = "{\"from\":\"client\", \"command\":\"setname\", \"uuid\":\"\(self.myUuid)\",\"name\":  \"\(self.myUserId)\"}"
        print("in registerUserId:send=\(message)")
        socket.writeString(message)
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

        if socket.isConnected {
            getLocationButton.setTitle("Connect", forState: UIControlState.Normal)
            socket.disconnect()
        } else {
            getLocationButton.setTitle("Disconnect", forState: UIControlState.Normal)
            socket.connect()
        }
    }
}

