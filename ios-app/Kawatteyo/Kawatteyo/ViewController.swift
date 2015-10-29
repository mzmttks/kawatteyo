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

    @IBOutlet weak var userIdTextField: UITextField!
    @IBOutlet weak var getLocationButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    var isPositionGetting = false
    var mLocationManager: CLLocationManager!
    var socket = WebSocket(url: NSURL(string: "ws://dev.hosts.hark.jp:8080/socket")!)
    
    var myUuid: String!
    
    let regex = try? NSRegularExpression(pattern: "[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", options: NSRegularExpressionOptions())
    
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
        print("Message received: \(text)")
        
        let receivedMessage = parseMessage(text)

        if receivedMessage["from"] != nil {
            let from = receivedMessage["from"] as! String
            print("from=\(from)")
            
            if from == "client" {
                return
            }
        }

        if receivedMessage as! NSObject == 0 {
            print("error")
            return
        }
        
        if ((receivedMessage["uuid"] as! String?) != nil) {
            print("@@@@uuid=\(receivedMessage["uuid"])")
            
            self.myUuid = receivedMessage["uuid"] as! String
            registerUserId()
            return
        }
        
        if (receivedMessage["type"] as! String?) != nil && receivedMessage["type"] as! String == "Registered" {
            print("Registered")
            sendKawatteyo()
            return
        }
        
//        let receivedText = text
//        let result = regex?.firstMatchInString(receivedText as String, options: NSMatchingOptions(), range: NSRange(location: 0, length: receivedText.characters.count))
////        let result = regex?.firstMatchInString(text as String, options: NSMatchingOptions(), range: NSRange(location: 0, length: text.characters.count))
//        if result != nil {
//            // received message is uuuid
//            print("***uuid= \(receivedText) ***" )
//            
//            let startIndex = receivedText.endIndex.advancedBy(-36)
//            self.myUuid = receivedText.substringFromIndex(startIndex)
//            print("### \(self.myUuid)")
//            
//            registerUserId()
//            return
//        }
//        
//        if text.hasPrefix("[Server]Registered") {
//            print("***registered***")
//            sendKawatteyo()
//        }
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
        let userId = userIdTextField.text!
        let message = "{\"from\":\"client\", \"command\":\"setname\", \"uuid\":\"\(self.myUuid)\",\"name\":  \"\(userId)\"}"
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

