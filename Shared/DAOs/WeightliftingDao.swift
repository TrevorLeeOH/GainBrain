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
    
    static func create(wl: WeightliftingDTO) throws {
        do {
            let db = try Database.getDatabase()
            try db.run(table.insert(
                workoutId <- wl.workoutId,
                weightliftingTypeId <- wl.weightliftingType.id,
                weightIsOffset <- wl.weightIsOffset,
                weightIsIndividual <- wl.weightIsIndividual))
        }
    }
    
    static func getAllForWorkout(id: Int64) -> [WeightliftingDTO] {
        var wls: [WeightliftingDTO] = []
        
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(table.filter(workoutId == id))
            for row in try Array(rowSet) {
                try wls.append(mapRowToWeightliftingDTO(row: row))
            }
        } catch {}
        
        return wls
    }
    
    
    static func mapRowToWeightliftingDTO(row: RowIterator.Element) throws -> WeightliftingDTO {
        return try WeightliftingDTO(weightliftingId: row[weightliftingId],
                                    workoutId: row[workoutId],
                                    weightliftingType: WeightliftingTypeDao.get(id: row[weightliftingTypeId]),
                                    tags: WeightliftingTagDao.getAllForWeightlifting(id: row[weightliftingId]),
                                    sets: WeightliftingSetDao.getAllForWeightlifting(id: row[weightliftingId]),
                                    weightIsOffset: row[weightIsOffset],
                                    weightIsIndividual: row[weightIsIndividual])
        
    }
}
