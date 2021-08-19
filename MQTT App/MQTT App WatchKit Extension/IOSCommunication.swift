//
//  IOSCommunication.swift
//  MQTT WatchKit Extension
//
//  Created by roblof-8 on 2021-08-10.
//

import Foundation
import WatchConnectivity

class IOSCommunication : NSObject, WCSessionDelegate 
{
    var session : WCSession?
    var coordinateContainer : CoordsContainer
    
    var roomLocaion : String?
    
    var notification : NotificationCreator?
    
    var PHClient : HueClient?
    
    var fallNotificationTimer : Bool
    
    init(notification : NotificationCreator, hue : HueClient)
    {
        self.roomLocaion = "Unknown locaion"
        self.coordinateContainer = CoordsContainer()
        self.notification = notification
        self.fallNotificationTimer = false
        self.PHClient = hue
        super.init()
        if WCSession.isSupported()
        {
            self.session = WCSession.default
            session?.delegate = self
            session?.activate()
            print(session!.activationState)
        }
    }
    
    //Used for sending notifications.
    func sendLocalNotification(_ title: String = "Robins app",_ subtitle: String = "Warning", body: String){
        if let notificationCreater = self.notification{
            notificationCreater.createNotification(title: title, subtitle: subtitle, body: body, badge: 0)
            //Change badge to increament
        }
    }
    
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Watch recieved msg from Phone")
        for x in message {
            print(x)
        }
        if let mqtt = message["MQTT"]
        {
            
            if let pos = message["POS"]
            {
                DispatchQueue.main.async
                {
                    self.coordinateContainer.updateCoordinates(pos: pos as! [Int])
                }
            }
            
            if let location = message["LOCATION"]
            {
                DispatchQueue.main.async {
                    self.coordinateContainer.newLocation(location: location as! String)
                }
            }
            
            if let fall = message["FALL"]
            {
                
                //Used to reset a timer to minize the events created
                if(!fallNotificationTimer)
                {
                    DispatchQueue.main.async {
                        self.sendLocalNotification(body: fall as! String)
                        print("sätter not timer till true")
                        self.fallNotificationTimer = true
                        self.PHClient!.turnOnLight(light: "13")
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5) {
                            print("sätter not timer till false")
                            self.fallNotificationTimer = false
                        }
                    }
                }
               
                
            }
           
            
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }
}

class CoordsContainer : ObservableObject {
    @Published private var pos : [Int]
    @Published private var roomLocation : String
    
    init()
    {
        self.pos = [0,0,0]
        self.roomLocation = "Unknown location"
    }
    
    func updateCoordinates(pos : [Int])
    {
        self.pos = pos
    }
    
    func newLocation(location : String)
    {
        self.roomLocation = location
    }
    
    func getLocaion() -> String
    {
        return self.roomLocation
    }
    
    func getPosition() -> [Int]
    {
        return pos
    }
}
