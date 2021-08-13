//
//  MQTT_AppApp.swift
//  MQTT App WatchKit Extension
//
//  Created by roblof-8 on 2021-08-10.
//

import SwiftUI

@main
struct MQTT_AppApp: App {
    
    @Environment(\.scenePhase) var phase
    
    var fibaro : Fibaro?
    var hue : HueClient?
    
    var connection: Connection?
    var healthStore: HealthStoreWatch?
    var notification = NotificationCreator()
    
    var phoneCon : IOSCommunication?
    
    //Fall references
    //let motion = Accelerometer()
    //let FDM : Falldetection?
    
    init() {
        self.healthStore = HealthStoreWatch(notification: notification)
        
        self.fibaro = Fibaro("unicorn@ltu.se", "jSCN47bC", "130.240.114.44")
        self.hue = HueClient("130.240.114.9");
        
        //self.FDM = Falldetection(NotifcationCreator: notification)
        
        self.connection = Connection(fib: fibaro!, hue: hue!)
        
        self.phoneCon = IOSCommunication()
        
        //motion.startAccelerometer()
        
    }
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(healthStore: healthStore!, connection: connection!,phoneCon: phoneCon!).onAppear(){
                    print("View did load, requesting access to notifications:")
                    notification.RequestNotificationAuthorization()
                    healthStore!.requestAuthorization()
                    { success in
                        if success
                        {
                            print("Authorazation was sucessfully completed")
                        }
                    }
                    //notification.checkNotificationSetting()
                }
            }.onChange(of: phase){ newPhase in
                switch newPhase{
                case .active:
                    print("App is active")
                case .inactive:
                    print("App is now inactive")
                    
                case .background:
                    print("App is in background")
                    
                @unknown default:
                    print("Some new state, dafuq is happening in thies shieeet.")
                }
                
                
            }
        }
        

        //WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
