//
//  ContentView.swift
//  MQTT App WatchKit Extension
//
//  Created by roblof-8 on 2021-08-10.
//

import SwiftUI

struct ContentView: View {
    var connection: Connection?
    var store: HealthStoreWatch?
    var phoneCon : IOSCommunication?
    
    init(healthStore : HealthStoreWatch, connection : Connection, phoneCon : IOSCommunication) {
        print("Content view init loaded")
        self.store = healthStore
        self.connection = connection
        self.phoneCon = phoneCon
    }
    
    var body: some View {
        ScrollView
        {
            VStack {
                Text("Robins Application").padding()
                
                NavigationLink(
                    destination: HealthView(store:store!).onDisappear(){
                        store!.updateInfo = false
                    },
                    label: {
                        HStack {
                            Text("Health App")
                            Image(systemName: "heart")
                        }
                })
                    
                NavigationLink(
                    destination: FibaroView(connection: self.connection!),
                    label: {
                        Text("Fibaro")
                        Image(systemName: "house")
                })
                
                NavigationLink(
                    destination: PhilipHueView(con: self.connection!).onAppear(){
                        self.connection!.send(msg: ["HUE":true,"GET":true ,"CODE":0]) //Call to fetch data for view.
                    }.onDisappear(){
                        connection!.getHueContainer().resetStatus()
                        print("Reset HUE ")
                    },
                    label: {
                        Text("PhilipHue")
                        Image(systemName: "lightbulb.fill")
                })
                
                NavigationLink(
                    destination: WideFindView(phoneCon: phoneCon!),
                    label: {
                        Text("WideFind")
                        Image(systemName: "tag")
                })
                
            }
        }
        
    
        
        
    }
}

