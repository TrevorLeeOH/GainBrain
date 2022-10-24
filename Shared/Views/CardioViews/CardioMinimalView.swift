//
//  CardioMinimalView.swift
//  GainBrain
//
//  Created by Trevor Lee on 10/24/22.
//

import SwiftUI

struct CardioMinimalView: View {
    @ObservedObject var cardio: CardioDTO
    
    @Binding var refresh: Bool
    
    var body: some View {
        
        HStack {
            Text(cardio.cardioType.name)
            Spacer()
            
            if let duration = cardio.duration {
                VStack {
                    Text("dur.")
                    Text(TimeIntervalClass(timeInterval: duration).toShortString())
                        .font(.caption)
                }
            }
            if let distance = cardio.distance {
                VStack {
                    Text("dst.")
                    Text(Config.instance.metricDistances ? String(round(distance.milesToKilometers() * 10) / 10.0).prefix(5) + " km" : String(round(distance * 10) / 10.0).prefix(5) + " mi")
                        .font(.caption)
                }
            }
            if let speed = cardio.speed {
                VStack {
                    Text("spd.")
                    Text(Config.instance.metricDistances ? String(round(speed.milesToKilometers() * 10) / 10.0).prefix(5) + " km/h" : String(round(speed * 10) / 10.0).prefix(5) + " mph")
                        .font(.caption)
                }
            }
            if let resistance = cardio.resistance {
                VStack {
                    Text("res.")
                    Text(String(resistance).prefix(5))
                        .font(.caption)
                }
            }
            if let incline = cardio.incline {
                VStack {
                    Text("inc.")
                    Text(String(incline).prefix(5))
                        .font(.caption)
                }
            }
        }
    }
}
