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
    
    var hs : HealthStoreWatch
    
    var fallNotificationTimer : Bool
    
    init(notification : NotificationCreator, hue : HueClient, hs : HealthStoreWatch)
    {
        self.roomLocaion = "Unknown locaion"
        self.coordinateContainer = CoordsContainer()
        self.notification = notification
        self.fallNotificationTimer = false
        self.PHClient = hue
        self.hs = hs
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
                    
                        self.fallNotificationTimer = true
                        
                        // 5 sec timer after fall to avoid spam notification from phone messages
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+10) {
                            self.fallNotificationTimer = false
                        }
                        
                        self.PHClient?.fallAlarm(node: "13", onOff: true)
                        
                        // Create health list for phone info
                        var listInfo = [String : Any]()
                        
                        var dataList = [Int]()
                        dataList.append(self.hs.hrCon.getHeartRate())
                        dataList.append(self.hs.oxygenCon.getOxygenLevel())
                        dataList.append(Int(self.hs.stepCon.getPace())!)
                        
                        listInfo["DATA"] = dataList
                        
                        listInfo["LOCATION"] = self.roomLocaion
                        
                        self.sendMessageToPhone(msg: listInfo)
                        
                    }
                }
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }
    
    func sendMessageToPhone(msg : [String : Any])
    {
        guard let session = self.session else {
            print("session was not initialited ending send msg")
            return
        }
        
        if !(session.isReachable){
            print("phone not reachable")
        }
        
        session.sendMessage(msg, replyHandler: nil) { error in
            print(error.localizedDescription)
        }

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
