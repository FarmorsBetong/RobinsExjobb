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
    
    override init()
    {
        self.roomLocaion = "Unknown locaion"
        self.coordinateContainer = CoordsContainer()
        super.init()
        if WCSession.isSupported()
        {
            self.session = WCSession.default
            session?.delegate = self
            session?.activate()
            print(session!.activationState)
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
