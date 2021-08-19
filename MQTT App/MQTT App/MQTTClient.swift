//
//  MQTTClient.swift
//  Group8Application
//
//  Created by Sven Andersson on 2/19/21.
//
import Foundation
import CocoaMQTT


class MQTTClient {
   
    
    
    var observers: [MQTTObserver]?
    var con: CocoaMQTT
    var host: String
    var port: UInt16
    var clientID: String
    var pos: [Int]!
    var location,settings: [Bool]!
    var WOSCom : WatchConnection?
    

    
    init(_ host: String, _ port: UInt16, _ clientID: String, watch : WatchConnection){
        //Saving address incase of disconnects.
        self.host = host
        self.port = port
        self.clientID = clientID
        self.con = CocoaMQTT(clientID: self.clientID, host: self.host, port: self.port)
        self.con.keepAlive = 60
        self.observers = [MQTTObserver]()
        self.pos = [0,0,0]
        self.location = [false,false] //Uggly as fuck but will do the jobb, l[0] kitchen, l[1] bedroom
        self.settings = [false,false,false,false]
        self.con.delegate = self
        self.con.connect()
        self.WOSCom = watch
        
        
        //self.con.logLevel = .debug
    }
    
    func get_post() -> [Int]{
        return pos!
    }
    
    //TODO: Find a way to check if observers are alrdy in observers, duplicate observers will suck.
    func registerObserver(obs : MQTTObserver) -> Void{
        observers!.append(obs)
    }

    func notifyObservers(event : String) -> Void{
        print(observers!)
        if let arr = observers{
            for obs in arr{
                //obs.moveEvent(even)
            }
        }
    }
    
    func setInitialState() -> Void{
        var msg = [String : Any]()
        msg["MQTT"] = true
        print("sending initial location")
        guard let WOSCom = WOSCom else {return}
            if pos[0] < -1000{
                //Starting from outside the appartement.
                location[0] = false; location[1] = false;
                msg["LOCATION"] = "Outside the appartment"
                return WOSCom.sendMsgToWatch(message: msg)
            }else if pos[1] > 0{
                //Starting from bedroom.
                location[0] = false; location[1] = true;
                
                msg["LOCATION"] = "Bedroom"
                return WOSCom.sendMsgToWatch(message: msg)
            }else{
                //Starting from kitchen.
                location[0] = true; location [1] = false;
                
                msg["LOCATION"] = "Kitchen"
                return WOSCom.sendMsgToWatch(message: msg)
            }
        }
    
    
    //TODO: Check for settings -> if user wants the desired functionality.
    //entering 
    func checkState() -> Void{
            var msg = [String : Any]()
            msg["MQTT"] = true
            guard let WOSCom = WOSCom else {
            print("watchcom references not available")
            return}
    
            print("state : \(location[0]) : \(location[1])")
        
            switch (location[0],location[1]){
                case (true,false):
                    //Currently in kitchen
                    if (pos[0] < -1000){
                        //Leaving appartement
                        location[0] = false
                        msg["LOCATION"] = "Left the appartment from the kitchen"
                        return WOSCom.sendMsgToWatch(message: msg)
                        //return notifyObservers(event: "leaving appartement")
                    }
                    if (pos[1] > 0){
                        //Entering bedroom from kitchen
                        location[0] = false; location[1] = true
                        msg["LOCATION"] = "Bedroom"
                        return WOSCom.sendMsgToWatch(message: msg)
                        //return notifyObservers(event: "entering bedroom")
                    }
                    
                    if(pos[2] < 250) {
                        msg["FALL"] = "Fall detected inside the kitchen call for help"
                        return WOSCom.sendMsgToWatch(message: msg)
                    }
                case (false,true):
                    //Currently in bedroom
                    if(pos[0] < -1000){
                        //Leaving appartement
                        location[1] = false
                        msg["LOCATION"] = "Left the appartment from the bedroom"
                        return WOSCom.sendMsgToWatch(message: msg)
                        //return notifyObservers(event: "leaving appartement")
                    }
                    if(pos[1] < 0){
                        //Entering kitchen from bedroom
                        location[0] = true; location[1] = false
                        msg["LOCATION"] = "Kitchen"
                        return WOSCom.sendMsgToWatch(message: msg)
                        //return notifyObservers(event: "entering kitchen")
                    }
                    if(pos[2] < 250) {
                        msg["FALL"] = "Fall detected inside the bedroom call for help"
                        return WOSCom.sendMsgToWatch(message: msg)
                    }
                case (false,false):
                    if (pos[0] > -1100){
                        if(pos[1] > 0){
                            location[1] = true
                            msg["LOCATION"] = "Bedroom"
                            return WOSCom.sendMsgToWatch(message: msg)
                            //notifyObservers(event: "entering bedroom")
                            //return notifyObservers(event: "entering appartement")
                        }
                        location[0] = true
                        
                        msg["LOCATION"] = "Kitchen"
                        return WOSCom.sendMsgToWatch(message: msg)
                        //notifyObservers(event: "entering kitchen")
                        //return notifyObservers(event: "entering appartement")
                        
                        if(pos[2] < 250) {
                            msg["FALL"] = "Fall detected outside the lab call for help"
                            return WOSCom.sendMsgToWatch(message: msg)
                        }
                    }
                default:
                    print("somethings fucky, again... currently in kitchen and in beedrom at the same time??")
        }
    }
}



extension MQTTClient: CocoaMQTTDelegate{
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topics: [String]) {
        for topic in topics{
            print("Subscribed too : \(topic)")
        }
    }
    
     
     func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept{
            mqtt.subscribe("#", qos: CocoaMQTTQOS.qos0)
            return
        }
        //Raise error in the future.
        print("Failed to establish connection...")
     }
     

     
     func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        DispatchQueue.main.async {
            
            if let upperRange = message.string!.description.range(of: "REPORT:"),
               let lowerRange = message.string!.description.range(of: "source") {
                //if !(message.string!.contains("DAA617E02AC45D51")){
                //    print("call does not contain specifcif tag.")
                //}
                    let msg = message.string!.description[upperRange.upperBound...lowerRange.lowerBound].components(separatedBy: ",")
                    // FOR TESTING
                    print("X:\(msg[2]) Y:\(msg[3]) Z:\(msg[4]) ")
                    //Used for initial condition.
                if self.pos[0] == 0 && self.pos[1] == 0 && self.pos[2] == 0{
                    self.pos[0] = Int(msg[2]) ?? 0
                    self.pos[1] = Int(msg[3]) ?? 0
                    self.pos[2] = Int(msg[4]) ?? 0
                    return self.setInitialState()
                }
                self.pos[0] = Int(msg[2]) ?? 0
                self.pos[1] = Int(msg[3]) ?? 0
                self.pos[2] = Int(msg[4]) ?? 0
                
                var cords = [String : Any]()
                cords["MQTT"] = true
                cords["POS"] = self.pos
                
                guard let WOSCom = self.WOSCom else {return}
                
                WOSCom.sendMsgToWatch(message: cords)
                self.checkState()
            }
        }
        
     }
     
    
    
    
     func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("subscribed: \(success), failed: \(failed)")
     }
     
     //Call recconnect on missed ping from certain intervall ??
     func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("RECIEVED PING")
     }
     //Call reconnect??
     func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("DISCONNECTED")
        //Raise error
     }
    
    
    
    //Not used.
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {}
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16){}
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {}
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {}
    func mqttDidPing(_ mqtt: CocoaMQTT) {}
    
}

protocol MQTTObserver{
    func moveEvent(event : String)

}
