//
//  CardioTagDao.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/6/22.
//

import Foundation
import SQLite

class CardioTagDao {
    
    static var cardioTagTable = Table("cardio_tag")
    static var cardioCardioTagTable = Table("cardio_cardio_tag")
    static var cardioTagId = Expression<Int64>("cardio_tag_id")
    static var name = Expression<String>("name")
    static var cardioId = Expression<Int64>("cardio_id")
    
    enum CardioTagError: Error {
        case CardioTagNotFound(id: Int64)
    }
    
    static func create(tag: IdentifiableLabel) throws {
        do {
            let db = try Database.getDatabase()
            try db.run(cardioTagTable.insert(name <- tag.name))
        }
    }
    
    static func get(id: Int64) throws -> IdentifiableLabel {
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(cardioTagTable.filter(cardioTagId == id))
            let result = try Array(rowSet)
            if result.count == 1 {
                return mapRowToTag(row: result.first!)
            }
            throw CardioTagError.CardioTagNotFound(id: id)
        }
    }
    
    static func getAll() -> [IdentifiableLabel] {
        var tags: [IdentifiableLabel] = []
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(cardioTagTable)
            for tagRow in try Array(rowSet) {
                tags.append(mapRowToTag(row: tagRow))
            }
        } catch {}
        return tags
    }
    
    static func getAllForCardio(id: Int64) -> [IdentifiableLabel] {
        var tags: [IdentifiableLabel] = []
        
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(cardioTagTable
                .join(cardioCardioTagTable, on: cardioTagTable[cardioTagId] == cardioCardioTagTable[cardioTagId])
                .filter(cardioId == id))
            for row in try Array(rowSet) {
                tags.append(IdentifiableLabel(id: row[cardioTagTable[cardioTagId]], name: row[name]))
            }
            
        } catch {}
        
        return tags
    }
    
    static func update(tag: IdentifiableLabel) throws {
        do {
            let db = try Database.getDatabase()
            let tagRow = cardioTagTable.filter(cardioTagId == tag.id)
            try db.run(tagRow.update(name <- tag.name))
        }
    }
    
    static func delete(id: Int64) throws {
        do {
            let db = try Database.getDatabase()
            let tagRow = cardioTagTable.filter(cardioTagId == id)
            try db.run(tagRow.delete())
        }
    }
    
    static func deleteAllForCardio(id: Int64) throws {
        do {
            let db = try Database.getDatabase()
            let targetRows = cardioCardioTagTable.filter(cardioId == id)
            try db.run(targetRows.delete())
        }
    }
    
    static func updateTagsForCardio(cardio: CardioDTO) throws {
        do {
            let db = try Database.getDatabase()
            try deleteAllForCardio(id: cardio.cardioId)
            for tag in cardio.tags {
                try db.run(cardioCardioTagTable.insert(cardioId <- cardio.cardioId, cardioTagId <- tag.id))
            }
        }
    }
    
    static func mapRowToTag(row: RowIterator.Element) -> IdentifiableLabel {
        return IdentifiableLabel(id: row[cardioTagId], name: row[name])
    }
}

