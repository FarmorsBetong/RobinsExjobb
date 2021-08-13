//
//  WatchOSCommunication.swift
//  MQTT
//
//  Created by roblof-8 on 2021-08-09.
//

import Foundation
import WatchConnectivity

class WatchConnection : NSObject, WCSessionDelegate , MQTTObserver {
    func moveEvent(event : String) {
        print("not used atm")
    }
    
    
    var session : WCSession?
    
    //var mqttObservers : [MQTTObserver]
    
    override init()
    {
        super.init()
        if(WCSession.isSupported())
        {
            self.session = WCSession.default
            self.session?.delegate = self
            self.session?.activate()
            print(session?.activationState)
        }
    }
    /*
    func addObserver(obs : MQTTObserver) {
        mqttObservers.append(obs)
    }*/
    
    func sendMsgToWatch(message : [String : Any])
    {
        if !(self.session!.isReachable){
            print("Watch was not reachable returning send func")
            
            
            if let msg = message["MQTT"]
            {
                                
               if let initState = message["LOCATION"]{
                     
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5) {
                        self.sendMsgToWatch(message: message)
                    }
                }
                
            }
            return
        }
        print("Watch is reachable sending msg")
        
        
        guard let session = self.session else {
            print("session was not initialited ending send msg")
            return
        }
        
        session.sendMessage(message, replyHandler: nil) { error in
            print(error.localizedDescription)
        }
    }
    
    
    // Delegate functions
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        //
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        //
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Telefonen tog emot ett meddelande")
        
        for(key,value) in message {
            print("msg recieved: key \(key) and value: \(value)")
        }
        
        
        //if let mqtt = message["MQTT"]
    }
    
    
    
}



