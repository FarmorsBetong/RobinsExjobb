//
//  NotificationCreator.swift
//  Group8Application WatchKit Extension
//
//  Created by Sven Andersson on 3/8/21.
//

import Foundation
import UserNotifications

class NotificationCreator : NSObject{
    
    func createNotification(title: String, subtitle: String, body: String, badge: Int?){
        let notification = UNMutableNotificationContent()
        notification.title = title
        notification.subtitle = subtitle
        notification.body = body
        notification.badge = badge! as NSNumber
        notification.sound = UNNotificationSound.defaultCritical

        
        let request = UNNotificationRequest(identifier: "TestLocalNotification", content: notification, trigger: nil)
        
        UNUserNotificationCenter.current().add(request){error in
            if let error = error{
                print("Something went to shit for notification")
                print(error.localizedDescription)
            }
            
        }
    }
    
    func RequestNotificationAuthorization(){
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [ .alert, .sound, .badge]
        center.requestAuthorization(options: options) {granted, error in
            if let error = error{
                print("ERROR IN SHIET")
                print(error.localizedDescription)
            }
            if granted{
                print("Access granted for notifications.")
                center.delegate = self
            }else{
                print("Access not granted for notifications.")
            }
            
        }
    }
    
    func checkNotificationSetting()
    {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings() { (settings) in
            print(settings.announcementSetting.rawValue)
        }
    }
}



extension NotificationCreator : UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("The notification is about to be presented.")
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("This shit is not called, why?? ")
        let identifier = response.actionIdentifier
        switch identifier{
        case UNNotificationDismissActionIdentifier:
            print("User dissmised the notification.")
            completionHandler()
        case UNNotificationDefaultActionIdentifier:
            print("User pushed the notification.")
            completionHandler()
        default:
            print("unknown action.")
        }
    }
}

