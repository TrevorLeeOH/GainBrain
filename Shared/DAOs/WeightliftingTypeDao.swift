//
//  WeightliftingTypeDao.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/6/22.
//

import Foundation
import SQLite

class WeightliftingTypeDao {
    
    static var table = Table("weightlifting_type")
    static var weightliftingTypeId = Expression<Int64>("weightlifting_type_id")
    static var name = Expression<String>("name")
    
    enum weightliftingTypeError: Error {
        case weightliftingTypeNotFound(id: Int64)
    }
    
    static func create(type: IdentifiableLabel) throws {
        do {
            let db = try Database.getDatabase()
            try db.run(table.insert(name <- type.name))
        }
    }
    
    static func get(id: Int64) throws -> IdentifiableLabel {
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(table.filter(weightliftingTypeId == id))
            let result = try Array(rowSet)
            if result.count == 1 {
                return mapRowToType(row: result.first!)
            }
            throw weightliftingTypeError.weightliftingTypeNotFound(id: id)
        }
    }
    
    static func getAll() -> [IdentifiableLabel] {
        var types: [IdentifiableLabel] = []
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(table)
            for typeRow in try Array(rowSet) {
                types.append(mapRowToType(row: typeRow))
            }
        } catch {}
        return types
    }
    
    static func update(type: IdentifiableLabel) throws {
        do {
            let db = try Database.getDatabase()
            let typeRow = table.filter(weightliftingTypeId == type.id)
            try db.run(typeRow.update(name <- type.name))
        }
    }
    
    static func delete(id: Int64) throws {
        do {
            let db = try Database.getDatabase()
            let typeRow = table.filter(weightliftingTypeId == id)
            try db.run(typeRow.delete())
        }
    }
    
    static func mapRowToType(row: RowIterator.Element) -> IdentifiableLabel {
        return IdentifiableLabel(id: row[weightliftingTypeId], name: row[name])
    }
}
