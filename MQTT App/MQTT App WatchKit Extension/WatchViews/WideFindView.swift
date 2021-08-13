//
//  WideFindView.swift
//  RobinX0001E WatchKit Extension
//
//  Created by roblof-8 on 2021-07-28.
//

import SwiftUI

struct WideFindView: View {
    
    var con : IOSCommunication?
    @ObservedObject var coordinates : CoordsContainer
    
    init(phoneCon : IOSCommunication) {
        self.con = phoneCon
        coordinates = self.con!.coordinateContainer
    }
    var body: some View {
        let pos = coordinates.getPosition()
        VStack{
            Label(coordinates.getLocaion(), systemImage : "location")
            
            HStack{
                Label(String(pos[0]), systemImage: "x.circle")
            }
            HStack{
                Label(String(pos[1]), systemImage: "y.circle")
            }
            HStack{
                Label(String(pos[2]), systemImage: "z.circle")
            }
            
        }
    }
}

/*
struct WideFindView_Previews: PreviewProvider {
    static var previews: some View {
        WideFindView()
    }
}*/
