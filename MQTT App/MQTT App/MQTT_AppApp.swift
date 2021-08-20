//
//  MQTT_AppApp.swift
//  MQTT App
//
//  Created by roblof-8 on 2021-08-10.
//

import SwiftUI

@main
struct MQTT_AppApp: App {
    
    //init references to the app
    @Environment(\.scenePhase) var phase
    
    var wf : MQTTClient?
    var watchCon : WatchConnection?
    init()
    {
        self.watchCon = WatchConnection()
       self.wf = MQTTClient("130.240.74.55",1883,"GRP8-\(String(Int.random(in: 1..<9999)))", watch: watchCon!)
        
        //guard let wf = wf, let watchCon = watchCon else {return}
        
        //wf.registerObserver(obs: watchCon)
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(watch: self.watchCon!)
        }.onChange(of: phase) { newPhase in
            switch newPhase{
            case .active:
                print("App is active")
                wf!.startMQTT()
            case .inactive:
                print("App is now inactive")
                
            case .background:
                print("App is in background")
                
            @unknown default:
                print("Some new state, dafuq is happening in thies shieeet.")
            }
        }
    }
}
