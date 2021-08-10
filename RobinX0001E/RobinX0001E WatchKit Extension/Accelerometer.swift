//
//  Accelerometer.swift
//  RobinX0001E WatchKit Extension
//
//  Created by roblof-8 on 2021-07-21.
//

import Foundation
import CoreMotion

class Accelerometer
{
    
    
    private let manager : CMMotionManager
    //private var timer : Timer
    
    init()
    {
        manager = CMMotionManager()
        
    }
    
    func startAccelerometer ()
    {
        print("hej")
            print("accelerometer is on")
            
            manager.accelerometerUpdateInterval = 1.0 / 60.0 // 60 hz frequency
            manager.startAccelerometerUpdates()
            
            //timer to fetch data
            Timer.scheduledTimer(withTimeInterval: (1.0/60.0), repeats: true) { timer in
                if let data = self.manager.accelerometerData {
                    let x = data.acceleration.x
                    let y = data.acceleration.y
                    let z = data.acceleration.z
                    
                    print("x acc : \(x) and y : \(y) and z : \(z)")
                }
                
            }
        
    }
    
   
}
