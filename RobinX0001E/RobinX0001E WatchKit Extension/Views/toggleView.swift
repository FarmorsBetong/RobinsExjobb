//
//  toggleView.swift
//  Group8Application WatchKit Extension
//
//  Created by roblof-8 on 2021-03-07.
//

import Foundation
import SwiftUI

struct ToggleView : View {
    
    @State var isChecked: Bool
    private var firstClick : prepLoad
   
    var connection: Connection?
    let name: String?
    let id : Int?
    
    init(connection : Connection, name : String, id : Int, status : Bool){
        self.connection = connection
        self.name = name
        self.id = id
        self.firstClick = prepLoad()
        if status
        {
            _isChecked = State(initialValue: true)
        }
        else {
            _isChecked = State(initialValue: false)
        }
    }
    
    var body: some View{
        
        Toggle(isOn: $isChecked) {
            HStack{
                Image(systemName: "lightbulb.fill").padding()
                Text("\(name!)")
                
                if isChecked {
                    Text("\(self.turnOn(node: self.id!))")
                }
                else{
                    Text("\(self.turnOff(node: self.id!))")
                }
            }
        }
        .onAppear(){
            self.firstClick.setFinishedLoading()
        }
    }

    //Turn on func
    func turnOn(node : Int) -> String
    {
        if self.firstClick.getLoaded(){
            print("ON")
            sendMsgToPhone(onOff: 1, node: node)
            return ""
        }
        return ""
    }
    
    
    //Turn off
    func turnOff(node : Int) -> String
    {
        if self.firstClick.getLoaded(){
            print("Off")
            sendMsgToPhone(onOff: 0, node: node)
            return ""
        }
        return ""
    }
    
    func sendMsgToPhone(onOff : Int, node : Int){
        
        guard let connection = connection else {return}
        
        var dic = [String : Any]()
        dic["FIBARO"] = true
        dic["CODE"] = onOff
        dic["NODE"] = node
        
        connection.send(msg: dic)
        print("protocol FIBARO msg was created and sent")
    }
}
/*
class prepLoad{

    var prep: Bool = false

    func setFinishedLoading() -> String{
        self.prep = true
        print("den e \(self.prep) nu")
        return ""
    }

    func getLoaded() -> Bool{
        return self.prep
    }
}

*/
