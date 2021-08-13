//
//  HealthStoreWatch.swift
//  Group8Application WatchKit Extension
//
//  Created by roblof-8 on 2021-02-22.
//

import Foundation
import HealthKit
import CoreMotion

class HealthStoreWatch:  NSObject/*, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate */{
    
    
    
    
    var healthStore: HKHealthStore?
    
    
    // health variables
    var heartRate : Int = 0
    var distanceWalked : Int = 0
    var oxygenSaturation : Int = 0
    
    var updateInfo : Bool = false
    
    // Tracking our workout state
    var workingOut = false
    var alerting = false
    
    let notCreator : NotificationCreator?
    
    //Containers
    var hrCon : HeartRateContainer
    var stepCon : StepsContainer
    var oxygenCon : OxygenContainer
    
    //testing pendometer
    let pedo : CMPedometer
    
    init(notification : NotificationCreator) {
        //configuration = HKWorkoutConfiguration()
        // set notification reference
        self.notCreator = notification
        
        //Create container references
        self.hrCon = HeartRateContainer()
        self.stepCon = StepsContainer()
        self.oxygenCon = OxygenContainer()
        self.pedo = CMPedometer()
        
        super.init()
        if (HKHealthStore.isHealthDataAvailable()) {
            healthStore = HKHealthStore()
           
            /*
            //Workout
            configuration!.activityType = .running
            configuration!.locationType = .indoor
                    
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
            builder.delegate = self*/
        }
    }
    
    func testingPedoMeter()
    {
        if(CMPedometer.isStepCountingAvailable())
        {
            print("vi kan hämta steps")
            let calendar = Calendar.current
            
            self.pedo.startUpdates(from: Date()) { data, error in
                print("Vi kommer inte in i closesuren")
                print(data)
            }
            
            
           /* self.pedo.queryPedometerData(from: calendar.startOfDay(for: Date()), to: Date()) { (data, error) in
                    print(data)
            }*/
            
            
            
        }
    }
    
    func requestAuthorization(completion:@escaping (Bool) ->Void) {
            
            // Readable/Writable data
    
    /*        let typesToShare = Set([
                HKQuantityType.quantityType(forIdentifier: .height)!
            ])
      */
            //Quantities to read from HealthStore
            let typesToRead = Set([
                HKQuantityType.quantityType(forIdentifier: .heartRate)!,
                HKQuantityType.quantityType(forIdentifier: .stepCount)!,
                HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)!,
                HKQuantityType.quantityType(forIdentifier: .respiratoryRate)!,
                HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
                HKQuantityType.quantityType(forIdentifier: .height)!,
                HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
            ])
            
            //unwrapping healthStore i.e checking if healthstore has been initiated and not nil
            guard let healthStore = self.healthStore else { return completion(false)}
            
            
            healthStore.requestAuthorization(toShare: [], read: typesToRead) { (success, error) in
                completion(success)
            }
    }
    
    
    func testFunc()
    {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .height) else {return}
        
        
    }
    
    func getOxygenSat(){
        
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation) else { return }
        
        let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (sample, result, error) in

            guard error == nil else {
                print("error")
                print(error)
                return
            }
            
            
            guard result!.isEmpty == false else {
                print("array empty")
                return
            }
            
            let data = result![0] as! HKQuantitySample
        
            
            let unit = HKUnit(from: "%")
            
            let latestOxygen = data.quantity.doubleValue(for: unit)
            
            print("Latest oxygen rate \(latestOxygen)")
            
            
            //updating container
            DispatchQueue.main.async {
                self.oxygenCon.recievedNewOxygenLevel(oxygen: Int(latestOxygen * 100))
            }
        }
        
        healthStore?.execute(query)
    }
    
   
    // Heart Rate
    
    func getHR(){
        
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (sample, result, error) in

            guard error == nil else {
                print("error")
                print(error)
                return
            }
            
            
            guard result!.isEmpty == false else {
                print("array empty")
                return
            }
            
            let data = result![0] as! HKQuantitySample
            
            
            let unit = HKUnit(from: "count/min")
            let latestHR = data.quantity.doubleValue(for: unit)
            
            print("Latest HR \(latestHR) BPM" )
            
            DispatchQueue.main.async
            {
                self.hrCon.recievedNewHR(heartRate: Int(latestHR))
            }
            
        }
        healthStore?.execute(query)
    }
    
    
    func startStepUpdate()
    {
        if(CMPedometer.isStepCountingAvailable())
        {
            self.pedo.startUpdates(from: Date()) { data, error in
                
                if error != nil {
                    print("PedoMeter Upate error")
                    print(error)
                    return
                }
                
                DispatchQueue.main.async {
                    self.stepCon.recievedMoreSteps(newSteps: Int(data!.distance!))
                    
                    if(data?.currentPace == nil)
                    {
                        self.stepCon.recievedCurrentPace(pace: 0)
                    }
                    else
                    {
                        self.stepCon.recievedCurrentPace(pace: Double(data!.currentPace!))
                    }
                    
                }
                
            }
        }
    }

    
    
    func observQueryHeartRate()
    {
       
        guard let hr = HKObjectType.quantityType(forIdentifier: .heartRate) else {return}
        
        let query = HKObserverQuery(sampleType: hr, predicate: nil) { (query, completionHandler, errorOrNil) in
            
            if let error = errorOrNil {
                print("ObsQHeartR error")
                return
            }
            
            self.getHR()
            // Take whatever steps are necessary to update your app.
            // This often involves executing other queries to access the new data.
            
            // If you have subscribed for background updates you must call the completion handler here.
            // completionHandler()
        }
        healthStore!.execute(query)

    }
    
    
    func observQueryOxygenSaturation()
    {
       
        guard let steps = HKObjectType.quantityType(forIdentifier: .oxygenSaturation) else {return}
        
        let query = HKObserverQuery(sampleType: steps, predicate: nil) { (query, completionHandler, errorOrNil) in
            
            if let error = errorOrNil {
                print("obsQOxygen error")
                print(error)
                return
            }
                
            print("oxygen change has occured, getting and updating new data")
            
            self.getOxygenSat()
            
    
            // If you have subscribed for background updates you must call the completion handler here.
            // completionHandler()
        }
        healthStore!.execute(query)
    }
    
    
    
    //Used for sending notifications.
    func sendLocalNotification(_ title: String = "Robins app",_ subtitle: String = "Warning", body: String){
        if let notificationCreater = self.notCreator{
            notificationCreater.createNotification(title: title, subtitle: subtitle, body: body, badge: 0)
            //Change badge to increament
        }
    }
    
    func testNotifcation()
    {
        if self.heartRate >= 80 && !alerting
        {
            print("high hr, fall increased get help")
            sendLocalNotification(body: "YOUR HEART RATE IS HIGH GET HELP")
            alerting = true
            
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3) {
            print("calling myself again")
            self.testNotifcation()
        }
    }
    
    

    // ----------------------- Workout functions ----------------------
    /*
    func startWorkout()
    {
        guard let session = session else { return }
        guard let builder = builder else { return }
        print("Start workout session state : \(session.state.rawValue)")
        if session.state.rawValue == 1 && !self.workoutStarted {
            
            session.startActivity(with: Date())
            builder.beginCollection(withStart: Date()){ (success, error) in
                guard success else {
                    print("begin collection crashed")
                    return
                }
                print("Session and builder started")
                print("Workout started")
                self.workoutStarted = true;
            }
        }
        
        if session.state.rawValue == 3 {
            print("resuming workout")
            //session.resume()
            session.prepare()
        }
    }*/
    /*
    func pauseWorkout()
    {
        //wrap vars
        guard let session = session, let builder = builder else { return }
        if session.state.rawValue != 3 && session.state.rawValue != 4
        {
            session.pause()
        }
        if session.state.rawValue == 4
        {
            session.resume()
        }
        print("Pause workout func session state value : \(session.state.rawValue)")
        
    }
    
    func endWorkout()
    {
        guard let session = session else { return }
        print("ending workout")
        session.end()
        
    }
     
     public func exitWorkout()
     {
         
         self.session!.end()
         self.builder!.endCollection(withEnd: Date())
         { (success,error) in
             guard success else {
                 print("end collection did not go through")
                 return
             }
             self.builder!.finishWorkout
             { (workout, error) in
                 guard workout != nil else
                 {
                     print("workout is not nil")
                     return
                 }
             }
         }
         self.workoutStarted = false;
     }
     public func recoverFromCrash()
     {
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
     
     */
    
   
    
   
    // ---------------------------------------------------------------------------
    /*
    // Event functions
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        print("[workoutSession] Changed State: \(toState.rawValue)")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("[workoutSession] Encountered an error: \(error)")
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        print("we got data from delegate")
        //print(collectedTypes)
        for type in collectedTypes {
            
            guard let quantityType = type as? HKQuantityType else {
                return
            }
            switch quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let statistics = workoutBuilder.statistics(for: quantityType)
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                let value = statistics!.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
                let Value = Int(Double(round(1 * value!) / 1))
                //print("[workoutBuilder] Heart Rate: \(stringValue)")
                self.heartRate = Value
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
    }*/
}

class HeartRateContainer : ObservableObject
{

    @Published var heartRate : Int
    
    init()
    {
        self.heartRate = 0
    }
    
    func getHeartRate() -> Int
    {
        return self.heartRate
    }
    
    func recievedNewHR(heartRate : Int)
    {
        self.heartRate = heartRate
    }
}

class StepsContainer : ObservableObject
{

    @Published var  totalSteps : Int
    @Published var currentPace : String
    
    init()
    {
        self.totalSteps = 0
        self.currentPace = "0"
    }
    
    func getSteps() -> Int
    {
        return self.totalSteps
    }
    
    func getPace() -> String
    {
        self.currentPace
    }
    
    func recievedCurrentPace(pace : Double)
    {
        let stringPace : String = String(format: "%.2f",pace)
        self.currentPace = stringPace
    }
    
    func recievedMoreSteps(newSteps : Int)
    {
        self.totalSteps = newSteps
    }
}

class OxygenContainer: ObservableObject
{

    @Published var oxygenPercent : Int
    
    init()
    {
        self.oxygenPercent = 0
    }
    
    func getOxygenLevel() -> Int
    {
        return self.oxygenPercent
    }
    
    func recievedNewOxygenLevel(oxygen : Int)
    {
        self.oxygenPercent = oxygen
    }
}


