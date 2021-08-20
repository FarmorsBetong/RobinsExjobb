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
    private var timer : Timer?
    
    init()
    {
        manager = CMMotionManager()
        
    }
    
    func startAccelerometer ()
    {
        /*
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
        }*/
        
        var highX = 0.0
        var highY = 0.0
        var highZ = 0.0
        
        // Make sure the accelerometer hardware is available.
        if self.manager.isAccelerometerAvailable && self.manager.isDeviceMotionAvailable{
            
            print("accelerometer and devicemotion hardware is available")
            
            // seting up accelerometer
            self.manager.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
            self.manager.startAccelerometerUpdates()

            
            // setting up device motion
            self.manager.deviceMotionUpdateInterval = 1.0 / 60.0
            self.manager.showsDeviceMovementDisplay = true
            self.manager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical)
            // Configure a timer to fetch the data.
            self.timer = Timer(fire: Date(), interval: (1.0/60.0),
                    repeats: true, block: { (timer) in
                        // Get the accelerometer data.
                        if let data = self.manager.accelerometerData {
                            let accelerometerX = data.acceleration.x
                            let accelerometerY = data.acceleration.y
                            let accelerometerZ = data.acceleration.z
                                
                            
                            if let data = self.manager.deviceMotion {
                            // Get the attitude relative to the magnetic north reference frame.
                                let motionX = data.attitude.pitch
                                let motionY = data.attitude.roll
                                let motionZ = data.attitude.yaw
                                                            
                                var accelerationX = motionX + accelerometerX
                                var accelerationY = motionY + accelerometerY
                                var accelerationZ = motionZ + accelerometerZ
                        
                                var totalAcceleration = sqrt((accelerationX * accelerationX) + (accelerationY * accelerationY) + (accelerationZ * accelerationZ))
                                
                                print("tot Acceleration : \(totalAcceleration)")
                            }
                        }
            })
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer!,forMode: .default)
                
        }
    }
    
   
}
