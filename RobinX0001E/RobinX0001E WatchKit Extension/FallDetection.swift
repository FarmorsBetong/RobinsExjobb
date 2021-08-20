//
//  FallDetection.swift
//  RobinX0001E WatchKit Extension
//
//  Created by roblof-8 on 2021-06-28.
//

import Foundation
import CoreMotion

class Falldetection: NSObject, CMFallDetectionDelegate
{
   
    let NC : NotificationCreator?
    var FD : CMFallDetectionManager?

    init(NotifcationCreator : NotificationCreator)
    {
        self.NC = NotifcationCreator
        self.FD = nil
        super.init()
        initiateFallDetection()
      
    }
    
    
    func initiateFallDetection()
    {
        
        if CMFallDetectionManager.isAvailable  {
           
            print("Falldetectuion is available for this devices")
            
            // Create the manager.
            let manager = CMFallDetectionManager()
            
            // Assign a delegate that adopts the CMFallDetectionDelegte protocol.
            manager.delegate = self
            
            // Keep a reference to the manager.
            self.FD = manager
        }
    }
    
    func authorization()
    {
        // Check to see if you have already asked the user to
        // authorize fall detection event notifications.
        guard let FD = FD else {return}
        
        if FD.authorizationStatus == .notDetermined {
            
            // Request Authorization.
            FD.requestAuthorization { (authorizationStatus) in
                
                print("auth complete for fall detection")
            }
        }
    }
    
    
    //Used for sending notifications.
    func sendLocalNotification(_ title: String = "Robins app",_ subtitle: String = "Warning", body: String){
        if let notificationCreater = self.NC{
            notificationCreater.createNotification(title: title, subtitle: subtitle, body: body, badge: 0)
            //Change badge to increament
        }
    }
    
    // CMFallDetection delegate functions -----------------
    
    func fallDetectionManager(_ fallDetectionManager: CMFallDetectionManager, didDetect event: CMFallDetectionEvent, completionHandler handler: @escaping () -> Void) {
        print("Event detected from fall detection!!!!")
        //sendLocalNotification(body: "Fall has been detected!")
    }

}
