//
//  UserDao.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/5/22.
//

import Foundation
import SQLite

class UserDao {
    
    static var table = Table("user")
    static var userId = Expression<Int64>("user_id")
    static var name = Expression<String>("name")
    static var h = Expression<Double>("h")
    static var s = Expression<Double>("s")
    static var b = Expression<Double>("b")
    
    enum UserDaoError: Error {
        case userNotFound(id: Int64)
        
    }
    
    
    static func create(user: User) throws {
        do {
            let db = try Database.getDatabase()
            try db.run(table.insert(name <- user.name, h <- user.h, s <- user.s, b <- user.b))
        }
    }
    
    static func getAll() -> [User] {
        var users: [User] = []
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(table)
            for userRow in try Array(rowSet) {
                users.append(mapRowToUser(row: userRow))
            }
        } catch {
            
        }
        return users
    }
    
    static func get(id: Int64) throws -> User {
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(table.filter(userId == id))
            
            let results = try Array(rowSet)
            if results.count == 1 {
                return mapRowToUser(row: results.first!)
            }
            
            throw UserDaoError.userNotFound(id: id)
        }
    }
    
    static func update(user: User) throws {
        do {
            let db = try Database.getDatabase()
            let userRow = table.filter(userId == user.userId)
            try db.run(userRow.update(name <- user.name, h <- user.h, s <- user.s, b <- user.b))
        }
    }
    
    static func delete(id: Int64) throws {
        do {
            let db = try Database.getDatabase()
            let userRow = table.filter(userId == id)
            try db.run(userRow.delete())
        }
    }
    
    static func mapRowToUser(row: RowIterator.Element) -> User {
        return User(userId: row[userId], name: row[name], h: row[h], s: row[s], b: row[b])
    }
    
}
