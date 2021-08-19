//
//  HeartRateStatView.swift
//  RobinX0001E WatchKit Extension
//
//  Created by roblof-8 on 2021-08-06.
//

import SwiftUI

struct HeartRateStatView: View {
    
    @ObservedObject var hrCon : HeartRateContainer
    
    init(hrCon : HeartRateContainer){
        self.hrCon = hrCon
    }
    var body: some View {
        List {
            VStack{
                
                    Text("Resting Rate").foregroundColor(.white).fontWeight(.bold)
                    HStack{
                        Text(String(hrCon.getRestingRate())).foregroundColor(.white)
                        Text("BPM").foregroundColor(.red)
                    }
                    Text("Today").fontWeight(.bold)
                
            }
            VStack{
               
                    Text("Walking avg rate").foregroundColor(.white).fontWeight(.bold)
                    HStack{
                        Text(String(hrCon.getWalkingAvg())).foregroundColor(.white)
                        Text("BPM").foregroundColor(.red)
                    }
                Text("Today").padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: -10))
                
            }
        }
    }// end of body view
} // end of view
/*
struct HeartRateStatView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateStatView()
    }
}*/
