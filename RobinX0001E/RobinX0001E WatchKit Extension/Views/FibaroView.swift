//
//  FibaroView.swift
//  Group8Application WatchKit Extension
//
//  Created by roblof-8 on 2021-02-22.
//

import SwiftUI


struct FibaroView: View {
    
    @State var bol = true
    var phoneCon : PhoneConnection?
    
    init(phoneCon: PhoneConnection){
        self.phoneCon = phoneCon
        
    }
    
    var body: some View {
        NavigationView {
            VStack{
                HStack{
                    
                    NavigationLink(
                        destination: lamp(phoneCon: self.phoneCon!).onAppear(){
                            self.phoneCon!.send(msg: ["FIBARO":true,"GET":true ,"CODE":0]) //Call to fetch data for view.
                            print("protocol FIBARO msg was created and sent")
                        }.onDisappear(){
                            print("Reset Fibaro outlets")
                            self.phoneCon!.getFibContainer().resetStatus()
                        },
                        label: {
                            Image(systemName: "lightbulb")
                        })
                    
                    NavigationLink(
                        destination: DoorView(phoneCon: self.phoneCon!).onAppear(){
                            self.phoneCon!.send(msg: ["FIBARO":true,"GET":true ,"CODE":1]) //Call to fetch data for view.
                            print("protocol FIBARO msg was created and sent")
                        }.onDisappear(){
                            print("Reset Fibaro door")
                            self.phoneCon!.getFibCSDoor().resetStatus()
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
