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
    static var index = Expression<Int>("index")
    
    static func create(wSet: WeightliftingSet) throws {
        do {
            let db = try Database.getDatabase()
            try db.run(table.insert(weightliftingId <- wSet.weightliftingId, reps <- wSet.reps, weight <- wSet.weight, index <- wSet.index))
        }
    }
    
    static func getAllForWeightlifting(id: Int64) -> [WeightliftingSet] {
        var weightliftingSets: [WeightliftingSet] = []
        
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(table.filter(weightliftingId == id))
            for row in try Array(rowSet) {
                weightliftingSets.append(mapRowToWeightliftingSet(row: row))
            }
            
        } catch {}
        
        return weightliftingSets
    }
    
    static func updateAllForWeightlifting(wl: WeightliftingDTO) throws {
        do {
            try deleteAllForWeightlifting(id: wl.weightliftingId)
            for index in 0..<wl.sets.count {
                wl.sets[index].index = index
                try create(wSet: wl.sets[index])
            }
        }
    }
    
    static func deleteAllForWeightlifting(id: Int64) throws {
        do {
            let db = try Database.getDatabase()
            let targetRows = table.filter(weightliftingId == id)
            try db.run(targetRows.delete())
        }
    }
    
    static func mapRowToWeightliftingSet(row: RowIterator.Element) -> WeightliftingSet {
        return WeightliftingSet(weightliftingSetId: row[weightliftingSetId], weightliftingId: row[weightliftingId], reps: row[reps], weight: row[weight], index: row[index])
    }
    
}
