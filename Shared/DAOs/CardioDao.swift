//
//  CardioDao.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/6/22.
//

import Foundation
import SQLite

class CardioDao {
    
    static var table = Table("cardio")
    
    static var cardioId = Expression<Int64>("cardio_id")
    static var workoutId = Expression<Int64>("workout_id")
    static var cardioTypeId = Expression<Int64>("cardio_type_id")
    static var duration = Expression<Double?>("duration")
    static var distance = Expression<Double?>("distance")
    static var speed = Expression<Double?>("speed")
    static var resistance = Expression<Double?>("resistance")
    static var incline = Expression<Double?>("incline")
    
    enum CardioDaoError: Error {
        case CardioNotFound(cardioId: Int64)
    }
    
    static func create(cardio: CardioDTO) throws {
        do {
            let db = try Database.getDatabase()
            let cId = try db.run(table.insert(
                workoutId <- cardio.workoutId,
                cardioTypeId <- cardio.cardioType.id,
                duration <- cardio.duration,
                distance <- cardio.distance,
                speed <- cardio.speed,
                resistance <- cardio.resistance,
                incline <- cardio.incline
            ))
            try CardioTagDao.updateTagsForCardio(cardio: get(id: cId))
        }
    }
    
    static func get(id: Int64) throws -> CardioDTO {
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(table.filter(cardioId == id))
            let result = try Array(rowSet)
            if result.count == 1 {
                return try mapRowToCardioDTO(row: result.first!)
            } else {
                throw CardioDaoError.CardioNotFound(cardioId: id)
            }
        }
    }
    
    static func getAllForWorkout(id: Int64) -> [CardioDTO] {
        
        var cardios: [CardioDTO] = []
        
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(table.filter(workoutId == id))
            for row in try Array(rowSet) {
                try cardios.append(mapRowToCardioDTO(row: row))
            }
            
        } catch {}
        
        return cardios
        
        
    }
    
    static func debugGetAll() -> [CardioDTO] {
        var cardios: [CardioDTO] = []
        
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(table)
            for row in try Array(rowSet) {
                try cardios.append(mapRowToCardioDTO(row: row))
            }
        } catch {}
        
        return cardios
    }
    
    static func debugDeleteAll() throws {
        do {
            let db = try Database.getDatabase()
            try db.run(table.delete())
        }
    }
    
    static func update(cardio: CardioDTO) throws {
        do {
            let db = try Database.getDatabase()
            let cardioRow = table.filter(cardioId == cardio.cardioId)
            try db.run(cardioRow.update(cardioTypeId <- cardio.cardioType.id,
                                        duration <- cardio.duration,
                                        distance <- cardio.distance,
                                        speed <- cardio.speed,
                                        resistance <- cardio.resistance,
                                        incline <- cardio.incline))
            try CardioTagDao.updateTagsForCardio(cardio: cardio)
        }
    }
    
    static func delete(id: Int64) throws {
        do {
            let db = try Database.getDatabase()
            let cardioRow = table.filter(cardioId == id)
            try db.run(cardioRow.delete())
        }
    }
    
    static func mapRowToCardioDTO(row: RowIterator.Element) throws -> CardioDTO {
        return try CardioDTO(cardioId: row[cardioId],
                             workoutId: row[workoutId],
                             cardioType: CardioTypeDao.get(id: row[cardioTypeId]),
                             tags: CardioTagDao.getAllForCardio(id: row[cardioId]),
                             duration: row[duration],
                             distance: row[distance],
                             speed: row[speed],
                             resistance: row[resistance],
                             incline: row[incline])
    }
    
}
