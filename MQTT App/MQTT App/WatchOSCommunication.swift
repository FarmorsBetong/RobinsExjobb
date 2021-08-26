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
    
    var alarmContainer = AlarmCon()
    
    //var mqttObservers : [MQTTObserver]
    
    override init()
    {
        super.init()
        if(WCSession.isSupported())
        {
            self.session = WCSession.default
            self.session?.delegate = self
            self.session?.activate()
            print(session!.activationState)
        }
    }
    /*
    func addObserver(obs : MQTTObserver) {
        mqttObservers.append(obs)
    }*/
    
    func sendMsgToWatch(message : [String : Any])
    {
        guard let session = self.session else {
            print("session was not initialited ending send msg")
            return
        }
        
        print(session.isPaired)
        print(session.isReachable)
        
        
        if !(session.isReachable){
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
        
        //Fall message recieved
        if let fall = message["FALL"]
        {
            if let fallInfo = message["DATA"] as? NSArray{
                DispatchQueue.main.async {
                    self.alarmContainer.setHR(hr: fallInfo[0] as! Int)
                    self.alarmContainer.setOxygen(oxy: fallInfo[1] as! Int)
                    self.alarmContainer.setAlarmStatus(status: true)
                }
            }
            
            if let msg = message["STATUS"]
            {
                DispatchQueue.main.async {
                    self.alarmContainer.setStatus(status: msg as! String)
                    
                }
            }
        }
        
    }
    
    
    
}

class AlarmCon : ObservableObject {
    @Published private var hr : Int
    @Published private var oxygen : Int
    @Published private var speed : Double
    @Published private var alarmStatus : Bool
    @Published private var status : String
    
    init(){
        hr = 0
        oxygen = 0
        speed = 0.0
        alarmStatus = false
        status = ""
    }
    
    func setStatus(status : String)
    {
        self.status = status
    }
    
    func setHR(hr : Int)
    {
        self.hr = hr
    }
    func setOxygen(oxy : Int)
    {
        self.oxygen = oxy
    }
    
    func setSpeed(speed : Double)
    {
        self.speed = speed
    }
    
    func setAlarmStatus(status : Bool)
    {
        self.alarmStatus = status
    }
    
    func getStatus() -> String
    {
        return self.status
    }
    
    func getHR() -> Int
    {
        return self.hr
    }
    
    func getOxy() -> Int
    {
        return self.oxygen
    }
    
    func getSpeed() -> Double
    {
        return self.speed
    }
    
    func getAlarmStatus() -> Bool
    {
        return self.alarmStatus
    }
    
}



