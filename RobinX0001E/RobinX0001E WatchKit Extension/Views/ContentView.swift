//
//  ContentView.swift
//  test WatchKit Extension
//
//  Created by Robin Olofsson on 2021-01-28.
//

import SwiftUI
import HealthKit



struct ContentView: View {
    var connection: Connection?
    var store: HealthStoreWatch?
    
    init(healthStore : HealthStoreWatch, connection : Connection) {
        self.store = healthStore
        self.connection = connection
        //Move to init.
        store!.requestAuthorization()
        { success in
            if success
            {
                print("Authorazation was sucessfully completed")
            }
        }
        store!.startWorkout()
    }
    
    var body: some View {
        
        VStack {
            Text("Robins Application").padding()
            
            NavigationLink(
                destination: HealthView(store:store!),
                label: {
                    HStack {
                        Text("Health App")
                        Image(systemName: "heart")
                    }
            })
                
            NavigationLink(
                destination: FibaroView(connection: self.connection!),
                label: {
                    Text("Fibaro")
                    Image(systemName: "house")
            })
            
            NavigationLink(
                destination: PhilipHueView(con: self.connection!).onAppear(){
                    self.connection!.send(msg: ["HUE":true,"GET":true ,"CODE":0]) //Call to fetch data for view.
                }.onDisappear(){
                    connection!.getHueContainer().resetStatus()
                    print("Reset HUE ")
                },
                label: {
                    Text("PhilipHue")
                    Image(systemName: "lightbulb.fill")
            })
        }
    
        
        
    }
    
}

/*
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
*/
