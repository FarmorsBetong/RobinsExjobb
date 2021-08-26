//
//  WideFindView.swift
//  RobinX0001E WatchKit Extension
//
//  Created by roblof-8 on 2021-07-28.
//

import SwiftUI

struct WideFindView: View {
    
    var con : IOSCommunication?
    var motion : Accelerometer?
    
    //containers
    @ObservedObject var coordinates : CoordsContainer
    @ObservedObject var acceleration : AccelerationContainer
    init(phoneCon : IOSCommunication, accelerometer : Accelerometer) {
        self.con = phoneCon
        self.motion = accelerometer
        coordinates = self.con!.coordinateContainer
        self.acceleration = self.motion!.accelerationCon
    }
    var body: some View {
        let pos = coordinates.getPosition()
        
        ScrollView {
                VStack(alignment: .leading) {
                    
                    VStack{
                        Label(coordinates.getLocation(), systemImage : "location")
                        
                        HStack{
                            Label(String(pos[0]), systemImage: "x.circle")
                        }
                        HStack{
                            Label(String(pos[1]), systemImage: "y.circle")
                        }
                        HStack{
                            Label(String(pos[2]), systemImage: "z.circle")
                        }
                       
                        Label(self.acceleration.getTotAccel() ,systemImage : "speedometer")
                        
                        Text(self.acceleration.getFall())
                        
                        Button(action: {
                            self.acceleration.setFallDetect(fall: "No fall detected")
                        }, label: {
                            Text("Reset fall")
                        })
                        
                        if(self.acceleration.getFall() == "Fall has occured") {
                            Button(action: {
                                msgToPhone(message: "I fell but I am okey!")
                            }, label: {
                                Text("I fell but I am okey!")
                            }).padding()
                            
                            Button(action: {
                                msgToPhone(message: "I fell and I need help fast!")
                            }, label: {
                                Text("I fell and I need help fast!")
                            }).padding()
                            
                        }
                        /*
                        Text("Only Accelerometer")
                        Label(self.acceleration.getTotAcc(), systemImage : "speedometer")
                        */
                        /*
                        Text("Highest acc")
                        Text(self.acceleration.getHighestAccel())
             */
                    }
                }
            }
        
       
    }
    
    func msgToPhone(message : String){
        var msg = [String : Any]()
        
        msg["FALL"] = true
        msg["STATUS"] = message
        
        self.con!.sendMessageToPhone(msg: msg)
    }
}

/*
struct WideFindView_Previews: PreviewProvider {
    static var previews: some View {
        WideFindView()
    }
}*/
