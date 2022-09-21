//
//  WeightliftingMinimalView.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/21/22.
//

import SwiftUI

struct WeightliftingMinimalView: View {
    @ObservedObject var weightlifting: WeightliftingDTO
    @Binding var refresh: Bool
    
    var body: some View {
        HStack {
            Text(weightlifting.weightliftingType.name)
            Spacer()
            ForEach(weightlifting.sets, id: \.weightliftingSetId) { wSet in
                VStack {
                    Text(String(wSet.reps))
                    Text(
                        String(weightlifting.weightIsOffset && wSet.weight >= 0 ? "+" : "")
                        + String(wSet.weight)
                    )
                }
            }
        }
    }
}
