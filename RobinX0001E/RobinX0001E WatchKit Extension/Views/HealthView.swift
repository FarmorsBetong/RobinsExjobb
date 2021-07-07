//
//  HealthView.swift
//  Group8Application WatchKit Extension
//
//  Created by roblof-8 on 2021-02-22.
//

import SwiftUI

struct HealthView: View {
    var store: HealthStoreWatch?
    @State private var heartRate: Int = 0
    @State private var distance: Int = 0
    @State private var heart: Bool = true
    @State private var oxygenSaturation : Int = 0
    
    init(store: HealthStoreWatch?){
        self.store = store
        self.store!.getOxygenSat()
        
    }
    
    var body: some View {
        VStack{
            //Displays the heartrate
            if heart{
            Label(String(heartRate), systemImage: "heart.fill").foregroundColor(.red)
            }else {
                Label(String(heartRate), systemImage: "heart").foregroundColor(.red)
            }
            ProgressView(value: Double(heartRate), total: 200.0).preferredColorScheme(.dark)
            
            Label(String(distance), systemImage: "figure.walk").foregroundColor(.green)
            
            //ProgressView(value: Double(distance), total: 1000.0).preferredColorScheme(.dark)
            
            Label(String(oxygenSaturation), systemImage: "percent").foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            
            

        }
        .onAppear(){
            //Starts the function that updates the current value of State variable
            update()
        }
    }
    
    func update() {
        // Update first then create a sync call to delay next update
        self.heartRate = self.store!.getHeartRate()
        self.distance = self.store!.distanceWalked
        self.oxygenSaturation = self.store!.getOxygen()
        self.heart.toggle()
        
        self.store!.getOxygenSat()
        //self.updateTime = 60/heartRate
        //self.store!.test()
        //self.store!.getOxygenSat()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
            update()
        }
    }
}


/*
struct HealthView_Previews: PreviewProvider {
    static var previews: some View {
        HealthView()
    }
}*/
