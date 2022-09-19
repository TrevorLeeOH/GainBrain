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
    @Published var index: Int
    
    init(weightliftingSetId: Int64 = -1, weightliftingId: Int64 = -1, reps: Int = 0, weight: Double = 0, index: Int = -1) {
        self.weightliftingSetId = weightliftingSetId
        self.weightliftingId = weightliftingId
        self.reps = reps
        self.weight = weight
        self.index = index
    }
    
    public func duplicate() -> WeightliftingSet {
        return WeightliftingSet(weightliftingSetId: weightliftingSetId, weightliftingId: weightliftingId, reps: reps, weight: weight, index: index)
    }
    
    public func toString() -> String {
        return "id: \(weightliftingSetId), wl id: \(weightliftingId), reps: \(reps), weight: \(weight), index: \(index)"
    }
    
    public func weightToString() -> String {
        return Config.instance.metricWeights ?
        String(round(weight.lbsToKg() * 10) / 10.0) + " kg"
        : String(round(weight * 10) / 10.0) + " lbs"
    }
}
