//
//  WeightliftingSetDao.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/6/22.
//

import Foundation
import SQLite

class WeightliftingSetDao {
    
    static var table = Table("weightlifting_set")
    
    static var weightliftingSetId = Expression<Int64>("weightlifting_set_id")
    static var weightliftingId = Expression<Int64>("weightlifting_id")
    static var reps = Expression<Int>("reps")
    static var weight = Expression<Double>("weight")
    
    static func create() {
        
    }
    
    
}
