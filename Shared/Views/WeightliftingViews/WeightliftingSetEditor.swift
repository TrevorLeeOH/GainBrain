//
//  WeightliftingSetEditor.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/21/22.
//

import SwiftUI

struct WeightliftingSetEditor: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var weightlifting: WeightliftingDTO
    @ObservedObject var wlSet: WeightliftingSet
    
    @State var reps: Int?
    @State var weight: Double?
    
    var body: some View {
        VStack {
            TextField("Enter Reps", value: $reps, format: .number)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
            TextField("Enter Weight", value: $weight, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
            Button("Done") {
                wlSet.reps = reps!
                wlSet.weight = Config.instance.metricWeights ? weight!.kgToLbs() : weight!
                dismiss()
            }
            .disabled(reps == nil || weight == nil)
            .foregroundColor(reps != 0 && weight != 0 ? .accentColor : Color(UIColor.systemGray4))
        }
        .onAppear {
            let objWeight = Config.instance.metricWeights ? wlSet.weight.lbsToKg() : wlSet.weight
            weight = objWeight == 0 ? nil : objWeight
            reps = wlSet.reps == 0 ? nil : wlSet.reps
        }
        .font(.title)
    }
}
