//
//  WeightliftingDao.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/6/22.
//

import Foundation
import SQLite

class WeightliftingDao {
    
    static var table = Table("weightlifting")
    static var weightliftingId = Expression<Int64>("weightlifting_id")
    static var workoutId = Expression<Int64>("workout_id")
    static var weightliftingTypeId = Expression<Int64>("weightlifting_type_id")
    static var weightIsOffset = Expression<Bool>("weight_is_offset")
    static var weightIsIndividual = Expression<Bool>("weight_is_individual")
    
    static func create() {
        
    }
}
