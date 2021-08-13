//
//  PhilipHueToggleView.swift
//  Group8Application WatchKit Extension
//
//  Created by Sven Andersson on 3/10/21.
//

import SwiftUI

struct PhilipHueToggleView: View {
    
    @State var isClicked: Bool
    private var lightId : String
    private var WMC : Connection
    private var firstClick : prepLoad
    
    init(WMC : Connection, id : String, onOff : Int){
        self.lightId = id
        self.WMC = WMC
        self.firstClick = prepLoad()
        if onOff == 1{
            _isClicked = State(initialValue: true)
        }else{
            _isClicked = State(initialValue: false)
        }
    }
    
    func toggleClicked(status : Bool) -> String{
        //print("toggleClicked with status: \(status)")
       //print("And light id of \(self.lightId)")
        //print("Preparing call to turn off/on light")
        
        //print("Preparing call to turn off/on light")
        if !(self.firstClick.getLoaded()){
            return ""
        }
        if status{
            self.WMC.send(msg: ["HUE":true,"NODE":self.lightId, "CODE": 1])
        }else{
            self.WMC.send(msg: ["HUE":true,"NODE":self.lightId, "CODE": 0])
        }
        return ""
    }
    
    var body: some View {
        Toggle(isOn : self.$isClicked){
            HStack{
                Text("\(lightId)").padding()
                
                if (self.isClicked){
                    Text("\(toggleClicked(status : true))")
                }else{
                    Text("\(toggleClicked(status : false))")
                }
            }
        }
        .onAppear(){
            self.firstClick.setFinishedLoading()
        }
    }
}

class prepLoad{
    
    var prep: Bool = false
    
    func setFinishedLoading() -> Void{
        self.prep = true
    }
    
    func getLoaded() -> Bool{
        return self.prep
    }
    
    
}

/*
struct PhilipHueToggleView_Previews: PreviewProvider {
    static var previews: some View {
        PhilipHueToggleView()
    }
}
*/
