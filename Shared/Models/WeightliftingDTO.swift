//
//  WeightLifting.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/15/22.
//

import Foundation

class WeightliftingDTO: ObservableObject, Equatable {
    
    var weightliftingId: Int64
    var workoutId: Int64
    var weightliftingType: IdentifiableLabel
    @Published var tags: [IdentifiableLabel]
    @Published var sets: [WeightliftingSet]
    @Published var weightIsOffset: Bool
    @Published var weightIsIndividual: Bool
    
    init(weightliftingId: Int64 = -1, workoutId: Int64 = -1, weightliftingType: IdentifiableLabel = IdentifiableLabel(), tags: [IdentifiableLabel] = [], sets: [WeightliftingSet] = [], weightIsOffset: Bool = false, weightIsIndividual: Bool = false) {
        self.weightliftingId = weightliftingId
        self.workoutId = workoutId
        self.weightliftingType = weightliftingType
        self.tags = tags
        self.sets = sets
        self.weightIsOffset = weightIsOffset
        self.weightIsIndividual = weightIsIndividual
    }
    
    static func == (lhs: WeightliftingDTO, rhs: WeightliftingDTO) -> Bool {
        return lhs.weightliftingId == rhs.weightliftingId
    }
    
    public func duplicate() -> WeightliftingDTO {
        return WeightliftingDTO(weightliftingId: weightliftingId, workoutId: workoutId, weightliftingType: weightliftingType, tags: tags, sets: sets, weightIsOffset: weightIsOffset, weightIsIndividual: weightIsIndividual)
    }
    
    public func toString() -> String {
        
        var setString = ""
        
        for s in sets {
            setString.append("(\(s.toString())), ")
        }
        return "id: \(weightliftingId), workout id: \(workoutId), type: (\(weightliftingType.toString())), sets: \(setString), offset?: \(weightIsOffset), Ind?: \(weightIsIndividual)"
    }
    
}

