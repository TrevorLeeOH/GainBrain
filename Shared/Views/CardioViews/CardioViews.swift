//
//  CardioViews.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/1/22.
//

import SwiftUI



struct CardioDetailView: View {
    @ObservedObject var cardio: CardioDTO
    
    var body: some View {
        List {
            if let duration = cardio.duration {
                Text("Duration: " + String(duration))
            }
            if let distance = cardio.distance {
                Text(Config.instance.metricDistances ? "\(distance.milesToKilometers()) km" : "\(distance) mi")
            }
            if let speed = cardio.speed {
                Text(Config.instance.metricDistances ? "\(speed.milesToKilometers()) km/h" : "\(speed) mph")
            }
            if let resistance = cardio.resistance {
                Text("Resistance: " + String(resistance))
            }
            if let incline = cardio.incline {
                Text("Incline: " + String(incline))
            }
        }
        .navigationBarTitle(cardio.cardioType.name)
    }
}






