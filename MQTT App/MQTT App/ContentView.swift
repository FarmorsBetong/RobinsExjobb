//
//  ContentView.swift
//  MQTT App
//
//  Created by roblof-8 on 2021-08-10.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var container : AlarmCon
    var watchCon : WatchConnection
    
    init(watch: WatchConnection){
        self.watchCon = watch
        container = watch.alarmContainer
    }
    
    var body: some View {
        
        if container.getAlarmStatus(){
            
            
            Text("HeartRate when fallen").fontWeight(.bold)
            HStack{
                Label(String(container.getHR()), systemImage: "heart")
                    .labelStyle(TitleOnlyLabelStyle()).padding()
                Text("BPM")
    
            }
           
            
            Text("Oxygen Saturation when fallen")
            HStack{
                
                Label(String(container.getOxy()), systemImage: "percent")
                    .labelStyle(TitleOnlyLabelStyle()).padding()
            
                
            }
            
            
            Button(action: {
                container.setAlarmStatus(status: false)
            }, label: {
                Text("Click here to reset the view")
            })
            
        }
        else {
            Text("Waiting for a alarm")
                .padding()
        }
        
    }
}
