//
//  DoorView.swift
//  Group8Application WatchKit Extension
//
//  Created by roblof-8 on 2021-03-10.
//

import SwiftUI

struct DoorView: View {
    
    
    // connection reference
    var connection: Connection
    @ObservedObject var fibCont: FibContainerDoor
    
    init(connection : Connection){
        self.connection = connection
        self.fibCont = connection.fibCSDoor
    }
    
    var body: some View {
       
        if(fibCont.getFibDoorsStatus()){
             VStack{
                ScrollView{
                   let list = fibCont.getFibDoor()
                    ForEach(0..<list.count){ index in
                        let dic = list[index] as! NSDictionary
                        HStack{
                           
                            if(dic.value(forKey: "value") as! Bool){
                                Text("\(dic.value(forKey: "name") as! String)").foregroundColor(.red)
                            }
                            else{
                                Text("\(dic.value(forKey: "name") as! String)").foregroundColor(.green)
                            }
                            
                        }
                            //ToggleView(phoneCon: self.phoneCon, name: dic.value(forKey: "name") as! String, id: dic.value(forKey: "nodeID") as! Int, status: dic.value(forKey: "value") as! Bool)
                    }
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
        connection.send(msg: msg)
        print("protocol FIBARO msg was created and sent")
    }
}
/*
struct DoorView_Previews: PreviewProvider {
    static var previews: some View {
        DoorView()
    }
}*/
