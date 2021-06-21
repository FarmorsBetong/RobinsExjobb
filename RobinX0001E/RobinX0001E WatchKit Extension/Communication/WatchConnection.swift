//
//  WatchConnection.swift
//  Group8Application
//
//  Created by Sven Andersson on 2/28/21.
//
import Foundation
import WatchConnectivity

class WatchConnection : NSObject, WCSessionDelegate, FibaroObserver, HueObserver{

    



    var session : WCSession!
    var fibaro : Fibaro?
    var hue : HueClient?
    //var con : Connection?

    init(fib : Fibaro/*, hue : HueClient*/){
        super.init()
        //self.con = con
        self.fibaro = fib
            //self.hue = hue
            
        
        

    }

    
    //If get request sent from watch -> call that objects recMsgFromWatch!
    //Else (no data to return to watch) simply call requested function in respective object.
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Vi tog emot meddelandet")
        
        //DispatchQueue.main.async {
            for (key,value) in message{
                print("RECIEVED \(key) \(value) in phone.")
            }
            //<!----------------- FIBARO --------------------!>//
        if let fibaroReq = message["FIBARO"]{
            if let GET = message["GET"]{
                return self.fibaro!.recMsgFromWatch(code: message["CODE"] as! Int)
            }
            //If not get request -> post request, performe some action in the lab.
            switch message["CODE"] as! Int{
            case 0:
                //Code 0 -> turn off "NODE" binarySwitch.
                self.fibaro!.turnOffSwitch(id: message["NODE"] as! Int)
            case 1:
                //Code 1 -> turn on "NODE" binarySwitch.
                self.fibaro!.turnOnSwitch(id: message["NODE"] as! Int)
            case 2:
                print("Läs kommentar, har flyttat skiten.")
                //Code 2 -> retrive all outlets in the network.
                /*
                print("Vi är i watchConnection för att hämta listan") meddelandet ska komma in i get. dvs medelandet ska
                var list = [String: Any]()                            skickas från klockan med message["GET"] = true, se                                                                                            recMsgFromWatch i Homekit klassen
                list["FIBARO"] = true
                list["CODE"] = 0
                list["BODY"] = self.fibaro!.watchGetOutlets()
                */
            default :
                print("No more actions to be taken for fibaro, call your lokal developper noob.")
            }
            
            return
        }
            //<!----------------- PHILIP HUE --------------------!>//
        if let hueReq = message["HUE"]{
            if let GET = message["GET"]{
                return self.hue!.recMsgFromWatch(code: message["CODE"] as! Int)
            }
            //If not get request -> post request, perform some action in the lab.
            switch message["CODE"] as! Int{
            case 0:
                //Code 0 -> turn off "NODE" light.
                self.hue!.turnOffLight(light : message["NODE"] as! String)
            case 1:
                //Code 1 -> turn off "NODE" light.
                self.hue!.turnOnLight(light : message["NODE"] as! String)
            default:
                print("No more actions to be taken for philip hue, call your lokal developper noob.")
            }
            return
        }
        
            
            //<!---------------- BUG TESTING -------------------!>//
        print("Recieved following msg in phone without a handler:")
        for (key,value) in message{
           print("Key: \(key) value: \(value)")
        }
            
        //}
    }

    //Send msg to watch for processing.
    func send(message : [String : Any]){
        if !(session.isReachable){
            return
        }
        session.sendMessage(message, replyHandler: nil, errorHandler: {
            error in
            print(error.localizedDescription)
        })
    }
    //Varför internal?
    internal func fibNotification(_ msg :[String : Any]){
        
        print("Fib response recieved with the msg:")
        for(key,value) in msg{
            print("Key: \(key), value: \(value)")
        }
        
        DispatchQueue.main.async{
            //self.send(message: msg)
            print("Recieved msg from Fib in phoneConnection")
            //self.con!.fibBS.recieveFibSwitches(switches: msg["BODY"] as! [Dictionary<String, Any>])
        }
        
    }
    
    func hueNotification(_ msg: [String : Any]) {
        /*
        print("Hue response recieved with the msg:")
        for(key,value) in msg{
            print("Key: \(key), value: \(value)")
        }
        */
        DispatchQueue.main.async{
            self.send(message : msg)
        }
    }
    
    
    
    
    //To be implemented.
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    //func sessionDidBecomeInactive(_ session: WCSession) {}
    //func sessionDidDeactivate(_ session: WCSession) {}

}
