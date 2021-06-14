//
//  ContentView.swift
//  test WatchKit Extension
//
//  Created by Robin Olofsson on 2021-01-28.
//

import SwiftUI
import HealthKit



struct ContentView: View {
    var phoneCon: PhoneConnection?
    var store: HealthStoreWatch?
    
    init(healthStore : HealthStoreWatch, phoneCon : PhoneConnection) {
        self.store = healthStore
        self.phoneCon = phoneCon
        //Move to init.
        store!.requestAuthorization(){ success in
            if success {
                print("Authorazation was sucessfully completed")
            }
        }
        store!.startWokrout()
    }
    
    var body: some View {
        
        VStack {
            Text("Group-8 App").padding()
            
            NavigationLink(
                destination: HealthView(store:store!),
                label: {
                    HStack {
                        Text("Health App")
                        Image(systemName: "heart")
                    }
            })
                
            NavigationLink(
                destination: FibaroView(phoneCon: self.phoneCon!),
                label: {
                    Text("Fibaro")
                    Image(systemName: "house")
            })
            
            NavigationLink(
                destination: PhilipHueView(phoneCon: self.phoneCon!).onAppear(){
                    print("Jag är i onappear \n")
                    self.phoneCon!.send(msg: ["HUE":true,"GET":true ,"CODE":0]) //Call to fetch data for view.
                }.onDisappear(){
                    phoneCon!.getHueContainer().resetStatus()
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
