//
//  HealthStoreWatch.swift
//  Group8Application WatchKit Extension
//
//  Created by roblof-8 on 2021-02-22.
//

import Foundation
import HealthKit

class HealthStoreWatch:  NSObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    
    
    
    
    var healthStore: HKHealthStore?
    // Our workout session
    var session: HKWorkoutSession?
    // Live workout builder
    var builder: HKLiveWorkoutBuilder?
    // Tracking our workout state
    var workingOut = false
    // Var that holds current heartRate
    var heartRate : String
    var distanceWalked : Int
    let configuration : HKWorkoutConfiguration?
    
    override init() {
        heartRate = "0"
        distanceWalked = 0
        configuration = HKWorkoutConfiguration()
        super.init()
        if (HKHealthStore.isHealthDataAvailable()) {
            healthStore = HKHealthStore()
            
            //Workout
            configuration!.activityType = .running
            configuration!.locationType = .outdoor
                    
            guard let healthStore = healthStore else { return }
                    
                    
            do {
                session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration!)
                builder = session?.associatedWorkoutBuilder()
            } catch {
                // Handle failure here.
                return
            }
            guard let session = session else { return }
            guard let builder = builder else { return }
                    
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
                    
            session.delegate = self
            builder.delegate = self
        }
    }
    
    func requestAuthorization(completion:@escaping (Bool) ->Void) {
            
            // Readable/Writable data
    
            let typesToShare = Set([HKQuantityType.workoutType()])
            
            //Quantities to read from HealthStore
            let typesToRead = Set([
                HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                //HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!,
                HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
            ])
            
            //unwrapping healthStore i.e checking if healthstore has been initiated and not nil
            guard let healthStore = self.healthStore else { return completion(false)}
            
            
            healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
                completion(success)
            }
    }
    
    func startWorkout()
    {
        guard let session = session else { return }
        guard let builder = builder else { return }
        print("\n\n\n\n\n\n\n start workout method")
        print(session.state.rawValue)
        if session.state.rawValue != 2 {
            session.startActivity(with: Date())
            builder.beginCollection(withStart: Date()){ (success, error) in
                guard success else {
                    print("begin collection crashed")
                    return
                }
                print("Session and builder started")
            }
        }
        
    }
    
    public func getHeartRate() -> Int {
        return Int(self.heartRate)!
    }
    
    public func getDistanceWalked() -> Int{
        return self.distanceWalked
    }

    public func exitWorkout(){
        
        self.session!.end()
        self.builder!.endCollection(withEnd: Date()){ (success,error) in
            guard success else {
                print("end collection did not go through")
                return
            }
            self.builder!.finishWorkout{ (workout, error) in
                guard workout != nil else {
                    print("workout is not nil")
                    return
                }
                
            }
        }
    }
    public func recoverFromCrash(){
        healthStore!.recoverActiveWorkoutSession{(session,error) in
            guard error == nil else {
                print("there is an error")
                print(error)
                return
            }
            self.session = session!
            
            do {
                self.session = try HKWorkoutSession(healthStore: self.healthStore!, configuration: self.configuration!)
                self.builder = session?.associatedWorkoutBuilder()
            } catch {
                // Handle failure here.
                return
            }
            guard let session = self.session else { return }
            guard let builder = self.builder else { return }
                    
            builder.dataSource = HKLiveWorkoutDataSource(healthStore: self.healthStore!, workoutConfiguration: self.configuration!)
                    
            session.delegate = self
            builder.delegate = self
        }
    }
    // ---------------------------------------------------------------------------
    
    // Event functions
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("[workoutSession] Changed State: \(toState.rawValue)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("[workoutSession] Encountered an error: \(error)")
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return
            }
            switch quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let statistics = workoutBuilder.statistics(for: quantityType)
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                let value = statistics!.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
                let stringValue = String(Int(Double(round(1 * value!) / 1)))
                //print("[workoutBuilder] Heart Rate: \(stringValue)")
                self.heartRate = stringValue
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
                let statistics = workoutBuilder.statistics(for: quantityType)
                let distanceUnit = HKUnit.meter()
                let valueRun = statistics!.mostRecentQuantity()?.doubleValue(for: distanceUnit)
                let stringValue = String(Int(Double(round(1 * valueRun!) / 1)))
                //print("[workoutBuilder] Distance walked: \(stringValue)")
                self.distanceWalked += Int(stringValue)!
                //print(workoutBuilder.dataSource?.typesToCollect)
    
            default:
                return
            }
        }
    }
    
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Retreive the workout event.
        guard let workoutEventType = workoutBuilder.workoutEvents.last?.type else { return }
        print("[workoutBuilderDidCollectEvent] Workout Builder changed event: \(workoutEventType.rawValue)")
    }
}

