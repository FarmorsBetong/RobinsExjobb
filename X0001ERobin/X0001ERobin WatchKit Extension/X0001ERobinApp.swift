//
//  X0001ERobinApp.swift
//  X0001ERobin WatchKit Extension
//
//  Created by roblof-8 on 2021-06-19.
//

import SwiftUI

@main
struct X0001ERobinApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
