//
//  WeightliftingTagDao.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/6/22.
//

import Foundation
import SQLite

class WeightliftingTagDao {
    
    static var weightliftingTagTable = Table("weightlifting_tag")
    static var weightliftingWeightliftingTagTable = Table("weightlifting_weightlifting_tag")
    static var weightliftingTagId = Expression<Int64>("weightlifting_tag_id")
    static var name = Expression<String>("name")
    static var weightliftingId = Expression<Int64>("weightlifting_id")
    
    enum WeightliftingTagError: Error {
        case WeightliftingTagNotFound(id: Int64)
    }
    
    static func create(type: IdentifiableLabel) throws {
        do {
            let db = try Database.getDatabase()
            try db.run(weightliftingTagTable.insert(name <- type.name))
        }
    }
    
    static func get(id: Int64) throws -> IdentifiableLabel {
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(weightliftingTagTable.filter(weightliftingTagId == id))
            let result = try Array(rowSet)
            if result.count == 1 {
                return mapRowToTag(row: result.first!)
            }
            throw WeightliftingTagError.WeightliftingTagNotFound(id: id)
        }
    }
    
    static func getAll() -> [IdentifiableLabel] {
        var tags: [IdentifiableLabel] = []
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(weightliftingTagTable)
            for tagRow in try Array(rowSet) {
                tags.append(mapRowToTag(row: tagRow))
            }
        } catch {}
        return tags
    }
    
    static func getAllForWeightlifting(id: Int64) -> [IdentifiableLabel] {
        var tags: [IdentifiableLabel] = []
        
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(weightliftingTagTable
                .join(weightliftingWeightliftingTagTable, on: weightliftingTagTable[weightliftingTagId] == weightliftingWeightliftingTagTable[weightliftingTagId])
                .filter(weightliftingWeightliftingTagTable[weightliftingId] == id))
            for row in try Array(rowSet) {
                tags.append(IdentifiableLabel(id: row[weightliftingTagTable[weightliftingTagId]], name: row[name]))
            }
            
        } catch {}
        
        return tags
    }
    
    static func update(tag: IdentifiableLabel) throws {
        do {
            let db = try Database.getDatabase()
            let tagRow = weightliftingTagTable.filter(weightliftingTagId == tag.id)
            try db.run(tagRow.update(name <- tag.name))
        }
    }
    
    static func updateAllForWeightlifting(id: Int64, tags: [IdentifiableLabel]) throws {
        do {
            let db = try Database.getDatabase()
            try deleteAllForWeightlifting(id: id)
            for tag in tags {
                try db.run(weightliftingWeightliftingTagTable.insert(weightliftingId <- id, weightliftingTagId <- tag.id))
            }
        }
    }
    
    static func deleteAllForWeightlifting(id: Int64) throws {
        do {
            let db = try Database.getDatabase()
            let targetRows = weightliftingWeightliftingTagTable.filter(weightliftingId == id)
            try db.run(targetRows.delete())
        }
    }
    
    
    
    static func delete(id: Int64) throws {
        do {
            let db = try Database.getDatabase()
            let tagRow = weightliftingTagTable.filter(weightliftingTagId == id)
            try db.run(tagRow.delete())
        }
    }
    
    static func mapRowToTag(row: RowIterator.Element) -> IdentifiableLabel {
        return IdentifiableLabel(id: row[weightliftingTagId], name: row[name])
    }
}


