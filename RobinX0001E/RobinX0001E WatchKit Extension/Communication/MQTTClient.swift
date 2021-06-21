//
//  MQTTClient.swift
//  Group8Application
//
//  Created by Sven Andersson on 2/19/21.
//
/*
import Foundation
import CocoaMQTT


class MQTTClient{
    
    var observers: [MQTTObserver]?
    var con: CocoaMQTT
    var host: String
    var port: UInt16
    var clientID: String
    var pos: [Int]!
    var location,settings: [Bool]!
    //bajs

    
    init(_ host: String, _ port: UInt16, _ clientID: String){
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
        
        
        //self.con.logLevel = .debug
    }
    
    func get_post() -> [Int]{
        return pos!
    }
    
    //TODO: Find a way to check if observers are alrdy in observers, duplicate observers will suck.
    func registerObserver(obs : MQTTObserver) -> Void{
        observers!.append(obs)
    }

    func notifyObservers(event : String ) -> Void{
        print(observers!)
        if let arr = observers{
            for obs in arr{
                obs.moveEvent(code: event)
            }
        }
    }
    func setInitialState() -> Void{
            if pos[0] < -1000{
                //Starting from outside the appartement.
                location[0] = false; location[1] = false;
            }else if pos[1] > 0{
                //Starting from bedroom.
                location[0] = false; location[1] = true;
            }else{
                //Starting from kitchen.
                location[0] = true; location [1] = false;
            }
        }
    //TODO: Check for settings -> if user wants the desired functionality.
    //entering 
    func checkState() -> Void{
            switch (location[0],location[1]){
                case (true,false):
                    //Currently in kitchen
                    if (pos[0] < -1000){
                        //Leaving appartement
                        location[0] = false
                        return notifyObservers(event: "leaving appartement")
                    }
                    if (pos[1] > 0){
                        //Entering bedroom from kitchen
                        location[0] = false; location[1] = true
                        return notifyObservers(event: "entering bedroom")
                    }
                case (false,true):
                    //Currently in bedroom
                    if(pos[0] < -1000){
                        //Leaving appartement
                        location[1] = false
                        return notifyObservers(event: "leaving appartement")
                    }
                    if(pos[1] < 0){
                        //Entering kitchen from bedroom
                        location[0] = true; location[1] = false
                        return notifyObservers(event: "entering kitchen")
                    }
                case (false,false):
                    if (pos[0] > -1100){
                        if(pos[1] > 0){
                            location[1] = true
                            notifyObservers(event: "entering bedroom")
                            return notifyObservers(event: "entering appartement")
                        }
                        location[0] = true
                        notifyObservers(event: "entering kitchen")
                        return notifyObservers(event: "entering appartement")
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
    func moveEvent(code : String)

}*/
