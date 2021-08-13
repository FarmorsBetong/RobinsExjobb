//
//  FibaroView.swift
//  Group8Application WatchKit Extension
//
//  Created by roblof-8 on 2021-02-22.
//

import SwiftUI


struct FibaroView: View {
    
    @State var bol = true
    var connection : Connection?
    
    init(connection: Connection){
        self.connection = connection
        
    }
    
    var body: some View {
        NavigationView {
            VStack{
                HStack{
                    
                    NavigationLink(
                        destination: lamp(connection: self.connection!).onAppear(){
                            self.connection!.send(msg: ["FIBARO":true,"GET":true ,"CODE":0]) //Call to fetch data for view.
                            //print("protocol FIBARO msg was created and sent")
                        }.onDisappear(){
                            print("Reset Fibaro outlets")
                            self.connection!.getFibContainer().resetStatus()
                        },
                        label: {
                            Image(systemName: "lightbulb")
                        })
                    
                    NavigationLink(
                        destination: DoorView(connection: self.connection!).onAppear(){
                            self.connection!.send(msg: ["FIBARO":true,"GET":true ,"CODE":1]) //Call to fetch data for view.
                            print("protocol FIBARO msg was created and sent")
                        }.onDisappear(){
                            print("Reset Fibaro door")
                            self.connection!.getFibCSDoor().resetStatus()
                        },
                        label: {
                            Image(systemName: "greetingcard.fill")
                        })
                      
                    
                }
            }
        }
    }
}
/*
struct FibaroView_Previews: PreviewProvider {
    static var previews: some View {
        FibaroView()
    }
}
*/
