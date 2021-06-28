//
//  HomeKit.swift
//  test
//
//  Created by roblof-8 on 2021-02-05.
//

import Foundation
import HomeKit
import SwiftUI


class Fibaro/*: MQTTObserver*/{
    
    var id : Int
    //weak var observing : MQTTClient?
    
    private var encoding : String?
    private var url_base : String?
    private var nodeList = [Dictionary<String, Any>]()
    private var saveEnergyNodes: [Int]?
    private var observers : [FibaroObserver]
    //var access: HMHomeManager?

    
    init(_ usr : String,_ pw : String,_ ip : String){
      /*  if (HMHomeManager.accessibilityActivate()) {
            access = HMHomeManager()
        }*/
        self.id = 80085
        
        //Fibaro base config.
        self.encoding = "\(usr):\(pw)".data(using: .utf8)!.base64EncodedString()
        self.url_base = "http://\(ip)/api/"
        
        self.observers = [FibaroObserver]()
        self.saveEnergyNodes = []
    }
    
    private func setupGetRequest(task : String) -> URLRequest{
        let url = URL(string : "\(url_base!)\(task)")
        let auth = "Basic \(encoding!)"
        
        var request = URLRequest(url : url!)
        request.setValue(auth, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    
    private func getPowerLevel(dic : [String:Any]) -> Int{
        // Limit for bug testing, remove when rdy.
        if(dic["roomID"] as! Int != 221){return -1}
        //
        
        if let power = (dic["properties"] as! [String:Any])["power"] as? Double{
            if (power > 0){
                return dic["id"] as! Int
            }
        }
        return -1 //Node does not consume energy
    }
    
    
    private func binarySwitchesConsumingEnergy(d : Data) -> [Int]{
        var binarySwitches : [Int] = []
        if let oneBSwitch = try! JSONSerialization.jsonObject(with: d, options: []) as? [String:Any]
        {
            let nodeConsuming = self.getPowerLevel(dic: oneBSwitch)
            if(nodeConsuming >= 0)
            {
                binarySwitches.append(nodeConsuming)
            }
            return binarySwitches
        }
        if let multipleBSwitch = try! JSONSerialization.jsonObject(with: d, options: []) as? [[String:Any]]
        {
            for node in multipleBSwitch
            {
                let nodeConsuming = self.getPowerLevel(dic: node)
                if(nodeConsuming >= 0)
                {
                    binarySwitches.append(nodeConsuming)
                }
            }
        }
        return binarySwitches
    }
    
    private func turnOnClosedSwitches(){
        if saveEnergyNodes!.isEmpty{
            return
        }
        for node in saveEnergyNodes!{
            let request = self.setupGetRequest(task: "callAction?deviceID=\(node)&name=turnOn")
            let task = URLSession.shared.dataTask(with: request){(_, response, _) in
                guard let response = response else{return}
                if let respCode = response as? HTTPURLResponse{
                    if respCode.statusCode >= 400{
                        print("Node : \(node) failed to be turned on!") //Remove printouts on release
                    }else{
                        print("Node : \(node) succeded in being turned on!") //Remove printouts on release
                    }
                }
            }
            task.resume()
        }
        //Reset temporarily saved nodes.
        saveEnergyNodes = []
    }
    
    //Strange behaviour inc if nodes alrdy existing in saveEnergyNodes.
    //Potentailly many fucking calls.
    private func turnOffConsumingSwitches(){
        let request = setupGetRequest(task: "devices?type=com.fibaro.binarySwitch")
        let task = URLSession.shared.dataTask(with: request){(data, response, error) in
            guard let data = data else{return}
            self.saveEnergyNodes = self.binarySwitchesConsumingEnergy(d: data)
            for consumingNode in self.saveEnergyNodes!{
                let request = self.setupGetRequest(task: "callAction?deviceID=\(consumingNode)&name=turnOff")
                let task = URLSession.shared.dataTask(with: request){(_, response, _) in
                    guard let response = response else {return}
                    if let respCode = response as? HTTPURLResponse{
                        print(respCode.statusCode)
                        if respCode.statusCode >= 400{
                            print("Node : \(consumingNode) failed to be turned off!")
                        }else{
                            print("Node : \(consumingNode) succeded in being turned off!")
                        }
                    }
                }
                task.resume()
            }
        }
        task.resume()
    }
    
    func watchGetOutlets() -> Void{
        print("getting outlets")
        self.updateOutletsHelper(completion:{ [weak self] result -> Void in
            switch result{
            case .failure(let error):
                print("error occured\n")
                print(error.localizedDescription)
            case .success(let list):
                print(" \n\n\n\n\n")
                print(type(of: list))
                for x in list {
                    print(x)
                }
                var msg = [String: Any]()
                msg["FIBARO"] = true
                msg["CODE"] = 0
                msg["BODY"] = list
                self!.notifyObservers(msg: msg)
            }
        })
    }
    
    func updateOutletsHelper(completion : @escaping(Result<[Dictionary<String, Any>], hueError>) -> Void){
        let request = setupGetRequest(task: "devices?type=com.fibaro.binarySwitch")
        let task = URLSession.shared.dataTask(with: request){(data, _, _) in
            guard let data = data else{
                completion(.failure(.noDataAvailable))
                return
            }
            let response = self.parseOutlets(d: data)
            completion(.success(response as [Dictionary<String, Any>]))
        }
        task.resume()
    }
    
    func parseOutlets(d: Data) -> [Dictionary<String, Any>]
    {
        do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: d, options: []) as? NSArray {
            
                    self.nodeList = [Dictionary<String, Any>]()
                    //print(convertedJsonIntoDict)
                    for basenode in convertedJsonIntoDict{
                        var dic = [String : Any]()
                        //print(basenode)
                        var check = false
                        //
                        for node in basenode as! NSDictionary{
                            if node.key as? String == "id"{
                                dic["nodeID"] = node.value as! Int
                            }
                            if node.key as? String == "name"{
                                dic["name"] = node.value as! String
                                dic["type"] = "com.fibaro.binarySwitch"
                                var checkIfOutlet: String =  node.value as! String
                                if checkIfOutlet.contains("vk"){
                                    check = true
                                }
                            }
                            if node.key as? String == "properties"{
                                // properties is of type Any Class, we need to downgrade it to Dictionary.
                                var propertiesDict: NSDictionary
                                propertiesDict = node.value as! NSDictionary
                                for attribute in propertiesDict{
                                    let obj = attribute.key as? String
                                    if obj == "value" {
                                        dic["value"] = attribute.value as! Bool
                                        
                                    }
                                }
                            }
                        }
                        if (check){
                            self.nodeList.append(dic)
                        }
                        check = false
                    }
                }
            }
            catch let error as NSError {
                print("catch let error")
                print(error.localizedDescription)
            }
        return nodeList
    }
    
    func turnOnSwitch(id: Int){
        print("turning on switch")
        let request = self.setupGetRequest(task: "callAction?deviceID=" + String(id) + "&name=turnOn")
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            print(data)
            print(response)
            print(error)
        } //Do something with response code?
        task.resume()
    }
    
    func turnOffSwitch(id: Int){
        print("turning off switch ")
        let request = setupGetRequest(task: "callAction?deviceID=" + String(id) + "&name=turnOff")
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in } //Do something with response code?
        task.resume()
    }
    /*
    private func checkOven() -> Void{
        //device id 267 -> oven in current fibaro configuration.
        let request = setupGetRequest(task: "energy/now-3600/now/compare/devices/power/267")
        let task = URLSession.shared.dataTask(with: request){(data, _, _) in
            guard let data = data else {return}
            if self.checkOvenParse(data){
                let msg = ["FIBARO":true, "CODE":0, "NOTIFICATION":"ALERT OVEN"] as [String : Any]
                self.notifyObservers(msg: msg)
            }
            
        }
        task.resume()
    }*/
    //MQTT
    /*
    //Currently only recieving one node -> change to parse several objects if change in
    //checkOven function to include several devices.
    private func checkOvenParse(_ data : Data) -> Bool{
        if let oven = try! JSONSerialization.jsonObject(with: data, options: []) as? [[String:Any]]{
            for onlyOne in oven{
                if ((onlyOne["W"] as! NSNumber).intValue > 0){
                    return true
                }
            }
        }
        return false
    }*/
    
    
    //Get request sent from watch controller, ie send something back.
    func msgCodeRecieved(code : Int){
        var response = [String : Any]()
        response["FIBARO"] = true
        
        switch code{
        case 0:
            //prep response with status of all binary switches.
            print("Fibaro recieved request to get all binary switches")
            response["CODE"] = 0
            response["BODY"] = self.watchGetOutlets()
            //self.notifyObservers(msg: response)
        case 1:
            print("Fibaro recieved request to send all doors to watch")
            //prep response with status of all doors.
            response["CODE"] = 1
            response["BODY"] = self.watchGetDoors()
            //self.notifyObservers(msg: response)
        default:
            print("Fibaro recieved code: \(code) from watch, somethings fucky.")
        }
    }
    
    // MQTT
    /*
    //Go over events in MQTTClient, mroe events should be called...
    func moveEvent(code: String) {
        switch code{
            case "entering appartement":
                print("Entering appartement event in fibaro")
                print("Turning on previously closed consuming nodes...")
                turnOnClosedSwitches()
                
            case "leaving appartement":
                print("Leaving appartement event in fibaro")
                print("Turning off consuming nodes...")
                turnOffConsumingSwitches()

            case "entering bedroom":
                print("Entering bedroom event in fibaro")
                print("CheckOven called.")
                checkOven()

            case "leaving bedroom":
                print("Leaving bedroom event in fibaro")

            case "entering kitchen":
                print("Entering kitchen event in fibaro")
                
            case "leaving kitchen":
                print("Leaving kitchen event in fibaro")
            default:
                print("I feel a disturbance in the force, event: [\(code)] was called.")
        }
        
    }*/
    
    func registerObserver(obs : FibaroObserver){
        observers.append(obs)
    }
    
    private func notifyObservers(msg : [String : Any]){
        print("Notifying observers of msg from Fibaro:")
        
        for (key,value) in msg
        {
            print("Key: \(key) value: \(value)")
        }
        for obs in observers
        {
            obs.fibNotification(msg)
        }
    }
    
    func watchGetDoors() -> Void{
        self.updateDoorsHelper(completion:{ [weak self] result -> Void in
            switch result{
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let list):
                var msg = [String: Any]()
                msg["FIBARO"] = true
                msg["CODE"] = 1
                msg["BODY"] = list
                self!.notifyObservers(msg: msg)
            }
        })
    }
    
    func updateDoorsHelper(completion : @escaping(Result<[Dictionary<String, Any>], hueError>) -> Void){
        let request = setupGetRequest(task: "devices?type=com.fibaro.doorSensor")
        let task = URLSession.shared.dataTask(with: request){(data, _, _) in
            guard let data = data else{
                completion(.failure(.noDataAvailable))
                return
            }
            let response = self.parseDoors(d: data)
            completion(.success(response as [Dictionary<String, Any>]))
        }
        task.resume()
    }
    
    func parseDoors(d: Data) -> [Dictionary<String, Any>]
    {
        do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: d, options: []) as? NSArray {
                    
                    self.nodeList = [Dictionary<String, Any>]()
                    //print(convertedJsonIntoDict)
                    for basenode in convertedJsonIntoDict{
                        var dic = [String : Any]()
                        //print(basenode)
                        var check = false
                        //
                        for node in basenode as! NSDictionary{
                            if node.key as? String == "id"{
                                dic["nodeID"] = node.value as! Int
                            }
                            if node.key as? String == "name"{
                                dic["name"] = node.value as! String
                                dic["type"] = "com.fibaro.doorWindowSensor"
                                var checkIfDoor: String =  node.value as! String
                                if (checkIfDoor.contains("Door") || checkIfDoor.contains("Fridge") || checkIfDoor.contains("Freezer")){
                                    check = true
                                }
                            }
                            if node.key as? String == "properties"{
                                // properties is of type Any Class, we need to downgrade it to Dictionary.
                                var propertiesDict: NSDictionary
                                propertiesDict = node.value as! NSDictionary
                                for attribute in propertiesDict{
                                    let obj = attribute.key as? String
                                    if obj == "value" {
                                        dic["value"] = attribute.value as! Bool
                                        
                                    }
                                }
                            }
                        }
                        if (check){
                            self.nodeList.append(dic)
                        }
                        check = false
                    }
                }
            }
            catch let error as NSError {
                print("catch let error")
                print(error.localizedDescription)
            }
        return nodeList
    }
}




protocol FibaroObserver{
    func fibNotification(_ msg : [String : Any]) -> Void
}
