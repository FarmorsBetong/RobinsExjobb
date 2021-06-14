//
//  testApp.swift
//  test WatchKit Extension
//
//  Created by Robin Olofsson on 2021-01-28.
//

import SwiftUI
import UserNotifications

@main
struct RobinX0001EApp: App {
    
    @Environment(\.scenePhase) var phase
    
    var phoneCon: PhoneConnection?
    var healthStore: HealthStoreWatch?
    var notification = NotificationCreator()
    
    init() {
        self.healthStore = HealthStoreWatch()
        self.phoneCon = PhoneConnection(notification: notification)
    }
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView(healthStore: healthStore!, phoneCon: phoneCon!).onAppear(){
                    print("View did load, requesting access to notifications:")
                    notification.RequestNotificationAuthorization()
                }
            }.onChange(of: phase){ newPhase in
                switch newPhase{
                case .active:
                    print("App is active")
                    healthStore!.startWokrout()
                case .inactive:
                    print("App is now inactive")
                    //healthStore!.recoverFromCrash()
                    //healthStore!.exitWorkout()
                    
                case .background:
                    print("App is in background")
                    //healthStore!.exitWorkout()
                @unknown default:
                    print("Some new state, dafuq is happening in thies shieeet.")
                }
                
                
            }
        }
        

        //WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
    
    
}