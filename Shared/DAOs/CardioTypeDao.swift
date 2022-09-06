//
//  CardioTypeDao.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/6/22.
//

import Foundation
import SQLite

class CardioTypeDao {
    
    static var table = Table("cardio_type")
    static var cardioTypeId = Expression<Int64>("cardio_type_id")
    static var name = Expression<String>("name")
    
    enum CardioTypeError: Error {
        case CardioTypeNotFound(id: Int64)
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
            let rowSet = try db.prepareRowIterator(table.filter(cardioTypeId == id))
            let result = try Array(rowSet)
            if result.count == 1 {
                return mapRowToType(row: result.first!)
            }
            throw CardioTypeError.CardioTypeNotFound(id: id)
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
            let typeRow = table.filter(cardioTypeId == type.id)
            try db.run(typeRow.update(name <- type.name))
        }
    }
    
    static func delete(id: Int64) throws {
        do {
            let db = try Database.getDatabase()
            let typeRow = table.filter(cardioTypeId == id)
            try db.run(typeRow.delete())
        }
    }
    
    static func mapRowToType(row: RowIterator.Element) -> IdentifiableLabel {
        return IdentifiableLabel(id: row[cardioTypeId], name: row[name])
    }
}
