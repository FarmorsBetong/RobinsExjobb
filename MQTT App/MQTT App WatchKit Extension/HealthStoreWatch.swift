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
            
            
            //Create the running queries
            observQueryHeartRate()
            observQueryOxygenSaturation()
            startStepUpdate()
            
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
                HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!,
                HKQuantityType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
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
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage) else {return}
        
        let startDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        
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
        
            
            
            let unit = HKUnit(from: "count/s")
            let latestHR = data.quantity.doubleValue(for: unit)
            
            print("Todays Rest rate \(latestHR*60) BPM" )
            
    
            
            //updating container
            DispatchQueue.main.async {
                self.hrCon.recievedNewResting(heartRate: Int(latestHR*60))
            }
        }
        
    healthStore?.execute(query)
        
    }
    
    func getWalkAvg()
    {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage) else {return}
        
        let startDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        
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
        
            
            
            let unit = HKUnit(from: "count/s")
            let latestHR = data.quantity.doubleValue(for: unit)
            
            //print("Todays Rest rate \(latestHR*60) BPM" )
            
    
            
            //updating container
            DispatchQueue.main.async {
                self.hrCon.recievedNewWalkAvg(heartRate: Int(latestHR*60))
            }
        }
        
    healthStore?.execute(query)
    }
    
    func getRestRate()
    {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .restingHeartRate) else {return}
        
        let startDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        
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
        
            
            
            let unit = HKUnit(from: "count/s")
            let latestHR = data.quantity.doubleValue(for: unit)
            
            //print("Todays Rest rate \(latestHR*60) BPM" )
            
    
            
            //updating container
            DispatchQueue.main.async {
                self.hrCon.recievedNewResting(heartRate: Int(latestHR*60))
            }
        }
        
    healthStore?.execute(query)
    }
    
    
    func getOxygenSat(){
        
        guard let sampleType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation) else { return }
        
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
}

class HeartRateContainer : ObservableObject
{

    @Published var heartRate : Int
    @Published var restingRate : Int
    @Published var walkingAvg : Int
    
    init()
    {
        self.heartRate = 0
        self.restingRate = 0
        self.walkingAvg = 0
    }
    
    func getHeartRate() -> Int
    {
        return self.heartRate
    }
    
    func getRestingRate() -> Int
    {
        return self.restingRate
    }
    
    func getWalkingAvg() -> Int
    {
        return self.walkingAvg
    }
    
    func recievedNewHR(heartRate : Int)
    {
        self.heartRate = heartRate
    }
    
    func recievedNewResting(heartRate : Int)
    {
        self.restingRate = heartRate
    }
    
    func recievedNewWalkAvg(heartRate : Int)
    {
        self.walkingAvg = heartRate
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


