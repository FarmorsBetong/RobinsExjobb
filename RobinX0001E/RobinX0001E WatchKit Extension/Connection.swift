//
//  PhoneConnection.swift
//  Group8Application WatchKit Extension
//
//  Created by Sven Andersson on 2/28/21.
//

import Foundation
import WatchConnectivity



class Connection : NSObject, ObservableObject, Identifiable, FibaroObserver, HueObserver{
   
    
    
    private var notCreator : NotificationCreator!
    var fibaro : Fibaro?
    var hue : HueClient?
    var WC : WatchConnection?
    var philipHueLights : HueContainer
    var fibBS : FibContainer
    var fibCSDoor : FibContainerDoor
    
    
    init(notification : NotificationCreator, fib : Fibaro, hue : HueClient){
     
        self.philipHueLights = HueContainer()
        self.fibBS = FibContainer()
        self.fibCSDoor = FibContainerDoor()
        
        self.fibaro = fib;
        self.hue = hue;
        super.init()
        
        //self.WC = WatchConnection(fib : fibaro!)
        
        guard let fibaro = fibaro else { return }
        hue.registerObserver(obs: self)
        fibaro.registerObserver(obs: self)
    }
    
    
    //Used for sending notifications recieved from phone.
    func sendLocalNotification(_ title: String = "Grp8Application",_ subtitle: String = "Warning", body: String){
        if let notificationCreater = self.notCreator{
            notificationCreater.createNotification(title: title, subtitle: subtitle, body: body, badge: 0)
            //Change badge to increament
        }
    }

/*
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            print("A message has been recieved")
            /*
            print("Recieved following msg in watch:")
            for(key,value) in message{
                print("Key: \(key) value: \(value)")
            }
            */
            
                //<!--------------------- FIBARO -------------------!>//
            if let fibaroReq = message["FIBARO"] {
                print("Fibaro message recieved")
                if let notification = message["NOTIFICATION"]{
                    //Switch here if we want to support different types off notification.
                    self.sendLocalNotification(body: notification as! String)
                    return
                }
                if let responseCode = message["CODE"]{
                    switch responseCode as! Int{
                    case 0:
                        print("Recieved msg from Fib in phoneConnection")
                        self.fibBS.recieveFibSwitches(switches: message["BODY"] as! [Dictionary<String, Any>])
                    case 1:
                        print("Vi kommer till PC")
                        self.fibCSDoor.recieveFibDoors(doors: message["BODY"] as! [Dictionary<String, Any>])
                    default:
                        print("No more actions to be taken for fibaro with responseCode : \(responseCode as! Int) recieved in PhoneConnection")
                    }
                }
            }
                //<!--------------------- PHILIP HUE -------------------!>//
            if let hueReq = message["HUE"]
            {
                if let notification = message["NOTIFICATION"]{
                    //Inte satt ngn notification trigger för phue, 10:e mars.
                    print("HUE recieved")
                    self.sendLocalNotification(body: notification as! String)
                    return
                }
                if let responseCode = message["CODE"]{
                    switch responseCode as! Int{
                    case 0:
                        let recievedHue = message["BODY"] as! [String : Int]
                        print("Recieved msg from philip hue in phoneConnection")
                        for (key,value) in recievedHue{
                            print("Key \(key) value\(value)")
                        }
                        self.philipHueLights.recieveHueLights(lights: recievedHue) //Update hue lights
                        //Set view for philipHueSwitches.
                        print("Setup view for philipHue lights")
                    default:
                        print("No more actions to be taken for hue with responseCode : \(responseCode as! Int) recieved in PhoneConnection")
                
                    }
                }
            }
        }
    }*/
    
    
    // -------------   protocol functions ----------------
    internal func fibNotification(_ msg :[String : Any]){
        
        print("Fib response inside con class, recieved with the msg:")
        for(key,value) in msg
        {
            print("Key: \(key), value: \(value)")
        }
        
        DispatchQueue.main.async
        {
            
            //<!--------------------- FIBARO -------------------!>//
            if let fibaroReq = msg["FIBARO"] {
                print("Fibaro message recieved")
                
                /*if let notification = msg["NOTIFICATION"]
                {
                    //Switch here if we want to support different types off notification.
                    self.sendLocalNotification(body: notification as! String)
                    return
                }*/
                if let responseCode = msg["CODE"]{
                    switch responseCode as! Int
                    {
                    case 0:
                        print("Recieved fib switches")
                        self.fibBS.recieveFibSwitches(switches: msg["BODY"] as! [Dictionary<String, Any>])
                    case 1:
                        print("Recieved fib doors")
                        self.fibCSDoor.recieveFibDoors(doors: msg["BODY"] as! [Dictionary<String, Any>])
                    default:
                        print("No more actions to be taken for fibaro with responseCode : \(responseCode as! Int) recieved in Connection")
                    }
                }
            }
        }
        
    }
    
    func hueNotification(_ msg: [String : Any])
    {
        
        print("Hue response recieved with the msg:")
        for(key,value) in msg{
            print("Key: \(key), value: \(value)")
        }
        
        DispatchQueue.main.async
        {
            //<!--------------------- PHILIP HUE -------------------!>//
            if let hueReq = msg["HUE"]
            {
                /*if let notification = msg["NOTIFICATION"]{
                    //Inte satt ngn notification trigger för phue, 10:e mars.
                    print("HUE recieved")
                    self.sendLocalNotification(body: notification as! String)
                    return
                }*/
                if let responseCode = msg["CODE"]{
                    switch responseCode as! Int{
                    case 0:
                        let recievedHue = msg["BODY"] as! [String : Int]
                        print("recievd msg from hueclient with node information:")
                        for (key,value) in recievedHue{
                            print("Key \(key) value\(value)")
                        }
                        self.philipHueLights.recieveHueLights(lights: recievedHue) //Update hue lights
                        //Set view for philipHueSwitches.
                        print("Setup view for philipHue lights")
                    default:
                        print("No more actions to be taken for hue with responseCode : \(responseCode as! Int) recieved in Connection")
                    }
                }
            }
        }//main thread end
    }//func end

    //  ------------------------------------------------------
    
    //used to recognise what type of msg and start the chain of events
    func send(msg : [String : Any]){
        print("send msg func is being executed")
        for (key,value) in msg
        {
            print("SENDING KEY: \(key) Value: \(value)")
        }
        
        //<!--------------------- FIBARO -------------------!>//
        if let fibreq = msg["FIBARO"]
        {
            if let GET = msg["GET"]
            {
                fibaro!.msgCodeRecieved(code : msg["CODE"] as! Int)
            }
            
            guard let node = msg["NODE"] else {return}
            
            //If not get request -> post request, performe some action in the lab.
            switch msg["CODE"] as! Int
            {
            case 0:
                //Code 0 -> turn off "NODE" binarySwitch.
                self.fibaro!.turnOffSwitch(id: node as! Int)
            case 1:
                //Code 1 -> turn on "NODE" binarySwitch.
                self.fibaro!.turnOnSwitch(id: msg["NODE"] as! Int)
            default :
                print("No more actions to be taken for fibaro, call your local developper noob.")
            }
            
        }
        //<!--------------------- PHILIP HUE -------------------!>//
        if let huereq = msg ["HUE"]
        {
            // unwrapping hue, to avoid null pointer
    
            
            if let GET = msg["GET"]
            {
                self.hue!.msgCodeRecieved(code: msg["CODE"] as! Int)
            }
        
             guard let node = msg["NODE"] else  { return }
            //if the msg is not a get req, it's a post
            switch msg["CODE"] as! Int
            {
            case 0:
                //print("Vi vill sätta på hue med id \(msg["NODE"])")
                self.hue!.turnOffLight(light: node as! String )
            case 1:
                print("vill sätta på")
                self.hue!.turnOnLight(light: node as! String )
            default:
                print("No more action for philip hue")
            }
        }
    }
    
    func getHueContainer() -> HueContainer
    {
        return philipHueLights
    }
    
    func getFibContainer() -> FibContainer
    {
        return fibBS
    }
    func getFibCSDoor() -> FibContainerDoor
    {
        return fibCSDoor
    }

}

class HueContainer : ObservableObject
{
    
    @Published var lights : [String : Int]
    private var lightStatus : Bool = false
    
    init()
    {
        self.lights = [String : Int]()
    }
    
    //Light id = key, status = value.
    func recieveHueLights(lights : [String : Int])
    {
        print("Setting recieveHueLights to true.")
        self.lightStatus = true
        print("Updating published list off lights.")
        self.lights = lights
        print("Published list off lights set")
    }
    
    func getHueLights() -> [String : Int]
    {
        print(type(of: lights))
        return lights
    }
    
    func getHueLightStatus() -> Bool
    {
        return lightStatus
    }
    
    func resetStatus()
    {
        lightStatus = false
    }
}

// Fib container

class FibContainer : ObservableObject
{
    @Published var switches : [Dictionary<String, Any>]
    private var switchStatus : Bool = false
    
    init()
    {
    
        self.switches = [Dictionary<String, Any>]()
    }
    
    //Light id = key, status = value.
    func recieveFibSwitches(switches : [Dictionary<String, Any>])
    {
        
        print("Setting recieveFibSwitches to true.")
        self.switchStatus = true
        print("Updating published list off switches.")
        self.switches = switches
        print("Published list off switches set")
    }
    
    func getFibSwitches() -> [Dictionary<String, Any>]
    {
        return switches
    }
    
    func getFibSwitchesStatus() -> Bool
    {
        return switchStatus
    }
    
    func resetStatus()
    {
        switchStatus = false
    }
}

class FibContainerDoor : ObservableObject
{
    @Published var doors : [Dictionary<String, Any>]
    private var Status : Bool = false
    
    init()
    {
        self.doors = [Dictionary<String, Any>]()
    }
    
    //Light id = key, status = value.
    func recieveFibDoors(doors : [Dictionary<String, Any>])
    {
        print("Setting recieveFibSwitches to true.")
        self.Status = true
        print("Updating published list off switches.")
        self.doors = doors
        print("Published list off switches set")
    }
    
    func getFibDoor() -> [Dictionary<String, Any>]
    {
        
        return doors
    }
    
    func getFibDoorsStatus() -> Bool
    {
        return Status
    }
    func resetStatus()
    {
        Status = false
    }
}





