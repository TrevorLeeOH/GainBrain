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
    
    enum WeightliftingDaoException: Error {
        case WeightliftingNotFound(id: Int64)
    }
    
    static func create(wl: WeightliftingDTO) throws -> WeightliftingDTO {
        do {
            let db = try Database.getDatabase()
            let wlId = try db.run(table.insert(
                workoutId <- wl.workoutId,
                weightliftingTypeId <- wl.weightliftingType.id,
                weightIsOffset <- wl.weightIsOffset,
                weightIsIndividual <- wl.weightIsIndividual))
            
            let newWl = try get(id: wlId)
            try WeightliftingTagDao.updateTagsForWeightlifting(weightlifting: newWl)
            try WeightliftingSetDao.updateAllForWeightlifting(wl: newWl)
            return try get(id: wlId)
        }
    }
    
    static func get(id: Int64) throws -> WeightliftingDTO {
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(table.filter(weightliftingId == id))
            let result = try Array(rowSet)
            if result.count == 1 {
                return try mapRowToWeightliftingDTO(row: result.first!)
            } else {
                throw WeightliftingDaoException.WeightliftingNotFound(id: id)
            }
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
    
    static func update(wl: WeightliftingDTO) throws {
        do {
            let db = try Database.getDatabase()
            let wlRow = table.filter(weightliftingId == wl.weightliftingId)
            try db.run(wlRow.update(weightliftingTypeId <- wl.weightliftingType.id,
                                        weightIsOffset <- wl.weightIsOffset,
                                        weightIsIndividual <- wl.weightIsIndividual))
            try WeightliftingTagDao.updateTagsForWeightlifting(weightlifting: wl)
            try WeightliftingSetDao.updateAllForWeightlifting(wl: wl)
        }
    }
    
    static func delete(id: Int64) throws {
        do {
            let db = try Database.getDatabase()
            let targetRow = table.filter(weightliftingId == id)
            try db.run(targetRow.delete())
            try WeightliftingTagDao.deleteAllForWeightlifting(id: id)
            try WeightliftingSetDao.deleteAllForWeightlifting(id: id)
        }
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
