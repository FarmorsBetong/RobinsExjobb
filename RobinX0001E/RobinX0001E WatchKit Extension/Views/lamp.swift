//
//  lamp.swift
//  Group8Application WatchKit Extension
//
//  Created by roblof-8 on 2021-03-05.
//

import SwiftUI

struct lamp: View {
    
    // connection reference
    var phoneCon: PhoneConnection
    @ObservedObject var fibCont: FibContainer
    
    init(phoneCon : PhoneConnection){
        self.phoneCon = phoneCon
        self.fibCont = phoneCon.fibBS
    }
    
    var body: some View {
       
        if(fibCont.getFibSwitchesStatus()){
            VStack{
                ScrollView{
                    let list = fibCont.getFibSwitches()
                    
                   // ForEach(list.)
                    ForEach(0..<list.count, id: \.self){ index in
                            let dic = list[index] as! NSDictionary
            
                            ToggleView(phoneCon: self.phoneCon, name: dic.value(forKey: "name") as! String, id: dic.value(forKey: "nodeID") as! Int, status: dic.value(forKey: "value") as! Bool)
                    }
                    
                    
                    /*ForEach(, id: \.self) { key in
                            HStack {
                                //Text(key)
                                //Text("\(recievedLights[key]!)")
                                PhilipHueToggleView(WMC: self.WMC,id : key, onOff: recievedLights[key]!)
                            }
                        }*/
                }
            } //Vstack end
        }// if end
        else{
            Text("vi laddar data")
            Image(systemName: "hourglass")
        }
    }
    
    func sendMsgToPhone(code : Int){
        var msg = [String : Any]()
        msg["FIBARO"] = true
        msg["GET"] = true
        msg["CODE"] = code
        phoneCon.send(msg: msg)
        print("protocol FIBARO msg was created and sent")
    }
    
    // Vad gör denna? 
    /*public func updateList(list : [Dictionary<String, Any>])
    {
        for node in list {
            let id : Int
            let name : String
            let value : Bool
            
            print("HEJ IGEN!!!")
            if node.keys as! String == "nodeID" {
                
            }
            //let tempNode = tempItem(nodeID: node["nodeID"], name: node["name"], status: node["value"])
            //tempList.append(tempItem(nodeID: node["nodeID"], name: node["name"], status: node["value"]))
        }
        print("Uppdate list")
    }*/
}




/*
struct lamp_Previews: PreviewProvider {
    static var previews: some View {
        lamp()
    }
}*/
