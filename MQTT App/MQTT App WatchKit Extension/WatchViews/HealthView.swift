//
//  HealthView.swift
//  Group8Application WatchKit Extension
//
//  Created by roblof-8 on 2021-02-22.
//

import SwiftUI


struct DataList: Identifiable {
    var id = UUID()
    var dataName : String
}


struct HealthView: View
{
    var store: HealthStoreWatch?
    @State private var heart: Bool = true
    
    
    @ObservedObject var hrCon: HeartRateContainer
    @ObservedObject var stepsCon : StepsContainer
    @ObservedObject var oxygenCon : OxygenContainer
    
    var data :[DataList] = [
    DataList(dataName: "Current Heart Rate"),
    DataList(dataName: "OxygenSaturation"),
    DataList(dataName: "Steps")
    
    ]
    
    init(store: HealthStoreWatch?)
    {
        self.store = store
        
        //set containers
        self.hrCon = store!.hrCon
        self.stepsCon = store!.stepCon
        self.oxygenCon = store!.oxygenCon
    
        
        //Create the running queries
        store!.observQueryHeartRate()
        store!.observQueryOxygenSaturation()
        store!.startStepUpdate()
    }
    
    var body: some View {
        
        List
        {
                        VStack
                        {
                            Text("Current Heart Rate")
                            if heart
                            {
                                HStack
                                {
                                    Label(String(hrCon.getHeartRate()), systemImage: "heart.fill").foregroundColor(.red)
                                    Text("BPM").foregroundColor(.red).fontWeight(.heavy)
                                }
                               
                            }
                            else
                            {
                                HStack
                                {
                                    Label(String(hrCon.getHeartRate()), systemImage: "heart").foregroundColor(.red)
                                    Text("BPM").foregroundColor(.red).fontWeight(.heavy)
                                }
                                
                            }
                            NavigationLink(destination: HeartRateStatView(hrCon: hrCon).onAppear(){
                                store!.getWalkAvg()
                                store!.getRestRate()
                            }) {
                                
                            }
                        }
                        
                    
                    
                        VStack
                        {
                            Text("Steps taken")
                            
                            Label(String(stepsCon.getSteps()), systemImage: "figure.walk").foregroundColor(.green)
                                
                            ProgressView(value: Double(stepsCon.getSteps()), total: 10000.0).preferredColorScheme(.dark)
                            
                            Label(stepsCon.getPace(), systemImage: "speedometer").foregroundColor(.green)
                            NavigationLink(destination: Text("test View")) {
                                
                            }
                        }
                        
                        
                    
            VStack{
                Text("Oxygen Saturation").padding()
               
                
                HStack
                {
                    Text(String(oxygenCon.getOxygenLevel())).foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    Image(systemName: "percent")
                }
            }
                       
                    
                }
        
        .onAppear(){
            //Starts the function that updates the current value of State variable
            update()
        }
    }
    
    func update()
    {
        self.heart.toggle()
    
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1)
        {
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
