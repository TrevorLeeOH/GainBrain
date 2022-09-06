//
//  WeightliftingSet.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/6/22.
//

import Foundation

class WeightliftingSet: ObservableObject {
    
    var weightliftingSetId: Int64
    var weightliftingId: Int64
    @Published var reps: Int
    @Published var weight: Double
    
    init(weightliftingSetId: Int64 = -1, weightliftingId: Int64, reps: Int = 0, weight: Double = 0) {
        self.weightliftingSetId = weightliftingSetId
        self.weightliftingId = weightliftingId
        self.reps = reps
        self.weight = weight
    }
}
