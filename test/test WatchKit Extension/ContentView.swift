//
//  ContentView.swift
//  test WatchKit Extension
//
//  Created by roblof-8 on 2021-08-19.
//
import SwiftUI
import UserNotifications

//new class to store notification text and to tell the NavigationView to go to a new page
class NotificationManager : ObservableObject {
    @Published var currentNotificationText : String?
    
    var navigationBindingActive : Binding<Bool> {
        .init { () -> Bool in
            self.currentNotificationText != nil
        } set: { (newValue) in
            if !newValue { self.currentNotificationText = nil }
        }
        
    }
}

enum Identifiers {
    static let viewAction = "VIEW_IDENTIFIER"
    static let readableCategory = "READABLE"
}

@main
struct MyApp: App , UIApplicationDelegate {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            TabView{
                NavigationView{
                    ContentView(notificationManager: appDelegate.notificationManager) //pass the notificationManager as a dependency
                }
                .tabItem {
                    Label("Home", systemImage : "house")
                }
            }
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    var notificationManager = NotificationManager() //here's where notificationManager is stored
    
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self// set the delegate
        registerForPushNotifications()
        return true
    }
    func application(  // registers for notifications and gets token
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("device token : \(token)")
    }//handles sucessful register for notifications
    
    func application( //handles unsucessful register for notifications
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error)")
    }//handles unsucessful register for notifications
    
    func application(   //handles notifications when app in foreground
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler:
            @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        print("new notification received")
        handleNotification(aps: aps)
        completionHandler(.noData)
    }//handles notifications when app in foreground
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                print("permission granted: \(granted)")
                guard granted else { return }
                let viewAction = UNNotificationAction(
                    identifier: Identifiers.viewAction,
                    title: "Mark as read",
                    options: [.foreground])
                
                let readableNotification = UNNotificationCategory(
                    identifier: Identifiers.readableCategory,
                    actions: [viewAction],
                    intentIdentifiers: [],
                    options: [])
                UNUserNotificationCenter.current().setNotificationCategories([readableNotification])
                self?.getNotificationSettings()
            }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            print("notification settings: \(settings)")
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if let aps = userInfo["aps"] as? [String: AnyObject] {
            handleNotification(aps: aps)
        }
    }
}

extension AppDelegate {
    @discardableResult func handleNotification(aps: [String:Any]) -> Bool {

        guard let alert = aps["alert"] as? String else { //get the "alert" field
            return false
        }
        self.notificationManager.currentNotificationText = alert
        return true
    }
}

struct ContentView: View {
    @ObservedObject var notificationManager : NotificationManager
    
    var body: some View {
        VStack{
            Text("Welcome")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .shadow(radius: 8 )
        }
        .navigationTitle("My Mobile App")
        .overlay(NavigationLink(destination: MyView(text: notificationManager.currentNotificationText ?? ""), isActive: notificationManager.navigationBindingActive, label: {
            EmptyView()
        }))
    }
}

struct MyView: View {
    var text : String
    
    var body: some View {
        Text(text)
    }
