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
    var accelerationCon : AccelerationContainer
    
    private var store : HealthStoreWatch
    private var con : IOSCommunication
    
    init(store : HealthStoreWatch, con : IOSCommunication)
    {
        manager = CMMotionManager()
        self.accelerationCon = AccelerationContainer()
        self.store = store
        self.con = con
        
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
                                
                            var totAcc = sqrt((accelerometerX * accelerometerX) + (accelerometerY * accelerometerY) + (accelerometerZ * accelerometerZ))
                            
                            if let data = self.manager.deviceMotion {
                            // Get the attitude relative to the magnetic north reference frame.
                                let motionX = data.attitude.pitch
                                let motionY = data.attitude.roll
                                let motionZ = data.attitude.yaw
                                                            
                                var accelerationX = motionX + accelerometerX
                                var accelerationY = motionY + accelerometerY
                                var accelerationZ = motionZ + accelerometerZ
                        
                                var totalAcceleration = sqrt((accelerationX * accelerationX) + (accelerationY * accelerationY) + (accelerationZ * accelerationZ))
                                
                                //sets the value of total acceleration for the view
                                DispatchQueue.main.async {
                                    self.accelerationCon.setTotalAcceleration(accel: totalAcceleration)
                                    //self.accelerationCon.setTotAcceleration(accel: totAcc)
                                    
                                    if(totalAcceleration > 6.0)
                                    {
                                        //Fall detected
                                        self.accelerationCon.setFallDetect(fall: "Fall has occured")
                                        
                                        var msg = [String : Any]()
                                        msg["FALL"] = true
                                        
                                        var data = [Int]()
                                        data.append(self.store.hrCon.getHeartRate())
                                        data.append(self.store.oxygenCon.getOxygenLevel())
                                        data.append(Int(self.store.stepCon.getPace())!)
                                        
                                        msg["DATA"] = data
                                        
                                        self.con.sendMessageToPhone(msg: msg)
                                        
                                    }
                                    /*
                                    if(4.0 < totalAcceleration){
                                        self.accelerationCon.sethighestAcceleration(accel: totalAcceleration)
                                    }*/
                                }
                                //print("tot Acceleration : \(totalAcceleration)")

                            }
                        }
            })
            // Add the timer to the current run loop.
            RunLoop.current.add(self.timer!,forMode: .default)
                
        }
    }
    
   
}

class AccelerationContainer : ObservableObject {
    @Published var totalAcell : String // accelerometer x,y,z + devicemotion pith, roll, yaw and new values sqrt(x2,y2,z2)
    @Published var totAcc : String // accelerometer x,y,z sqrt(x2,y2,z2)
    @Published var highestAcc : String
    @Published var fallDetected : String
    
    init(){
        self.totalAcell = "0.0"
        self.totAcc = "0.0"
        self.highestAcc = "0.0"
        self.fallDetected = "No fall detected"
    }
    
    func setFallDetect(fall : String){
        self.fallDetected = fall
    }

    
    func setTotalAcceleration(accel : Double) {
        let stringAccel : String = String(format: "%.4f",accel)
        self.totalAcell = stringAccel
    }
    
    func setTotAcceleration(accel : Double) {
        let stringAccel : String = String(format: "%.4f",accel)
        self.totAcc = stringAccel
    }
    
    func sethighestAcceleration(accel : Double) {
        let stringAccel : String = String(format: "%.4f",accel)
        self.highestAcc = stringAccel
    }
    
    func getHighestAccel() -> String {
        return self.highestAcc
    }
    
    func getTotAccel() -> String {
        return totalAcell
    }
    func getTotAcc() -> String {
        return self.totAcc
    }
    
    func getFall() -> String
    {
        return self.fallDetected
    }
    
}
