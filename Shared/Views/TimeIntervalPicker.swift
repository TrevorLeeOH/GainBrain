//
//  TimeIntervalPicker.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/19/22.
//

import SwiftUI

struct TimeIntervalPicker: View {
        
    @ObservedObject var timeInterval: TimeIntervalClass
    
    var body: some View {
        HStack {
            Text("Duration:")
            VStack {
                Text("Hours")
                    .font(.caption)
                TextField("Hours", value: $timeInterval.hours, format: .number)
            }
            VStack {
                Text("Minutes")
                    .font(.caption)
                TextField("Minutes", value: $timeInterval.minutes, format: .number)
            }
            VStack {
                Text("Seconds")
                    .font(.caption)
                TextField("Seconds", value: $timeInterval.seconds, format: .number)
            }
        }
        .multilineTextAlignment(.center)
    }
}
