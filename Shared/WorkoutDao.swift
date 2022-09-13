//
//  WorkoutDao.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/12/22.
//

import Foundation
import SQLite

class WorkoutDao {
    
    static var table = Table("workout")
    static var workoutId = Expression<Int64>("workout_id")
    static var userId = Expression<Int64>("user_id")
    static var workoutTypeId = Expression<Int64>("workout_type_id")
    static var date = Expression<Date>("date")
    static var duration = Expression<Double>("duration")
    static var caloriesBurned = Expression<Int?>("calories_burned")
    static var notes = Expression<String?>("notes")
    
    enum WorkoutDaoError: Error {
        case WorkoutNotFound(workoutId: Int64)
    }
    
    
    
    static func create(workout: WorkoutDTO) throws -> WorkoutDTO {
        do {
            let db = try Database.getDatabase()
            let newId = try db.run(table.insert(userId <- workout.user.userId,
                                                workoutTypeId <- workout.workoutType.id,
                                                date <- workout.date,
                                                duration <- workout.duration,
                                                caloriesBurned <- workout.caloriesBurned,
                                                notes <- workout.notes))
            return try get(workoutId: newId)
        }
    }
    
    static func get(workoutId: Int64) throws -> WorkoutDTO {
        print("called get with id of \(workoutId)")
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(table.filter(self.workoutId == workoutId))
            let result = try Array(rowSet)
            if result.count == 1 {
                return try mapRowToWorkoutDTO(row: result.first!)
            }
            
            throw WorkoutDaoError.WorkoutNotFound(workoutId: workoutId)
        }
    }
    
    static func getAllForUser(userId: Int64) -> [WorkoutDTO] {
        var workouts: [WorkoutDTO] = []
        
        do {
            let db = try Database.getDatabase()
            let rowSet = try db.prepareRowIterator(table.filter(self.userId == userId))
            for row in try Array(rowSet) {
                try workouts.append(mapRowToWorkoutDTO(row: row))
            }
        } catch {}
        
        return workouts
    }
    
    //Only for workout table values -- does not update cardio or weightlifting
    static func update(workout: WorkoutDTO) throws {
        do {
            let db = try Database.getDatabase()
            let targetRow = table.filter(workoutId == workout.workoutId)
            try db.run(targetRow.update(workoutTypeId <- workout.workoutType.id,
                                        date <- workout.date,
                                        duration <- workout.duration,
                                        caloriesBurned <- workout.caloriesBurned,
                                        notes <- workout.notes))
        }
    }
    
    static func debugDeleteAll() throws {
        do {
            let db = try Database.getDatabase()
            try db.run(table.delete())
        }
    }
    
    static func delete(id: Int64) throws {
        do {
            let db = try Database.getDatabase()
            let targetRow = table.filter(workoutId == id)
            try CardioDao.deleteAllForWorkout(id: id)
            try WeightliftingDao.deleteAllForWorkout(id: id)
            try db.run(targetRow.delete())
            
        }
    }
    
    static func mapRowToWorkout(row: RowIterator.Element) -> Workout {
        return Workout(workoutId: row[workoutId],
                       userId: row[userId],
                       workoutTypeId: row[workoutTypeId],
                       date: row[date],
                       duration: row[duration],
                       caloriesBurned: row[caloriesBurned],
                       notes: row[notes])
    }
    
    static func mapRowToWorkoutDTO(row: RowIterator.Element) throws -> WorkoutDTO {
        return try WorkoutDTO(workoutId: row[workoutId],
                              user: UserDao.get(id: row[userId]),
                              workoutType: WorkoutTypeDao.get(id: row[workoutTypeId]),
                              date: row[date],
                              duration: row[duration],
                              caloriesBurned: row[caloriesBurned],
                              notes: row[notes],
                              weightlifting: WeightliftingDao.getAllForWorkout(id: row[workoutId]),
                              cardio: CardioDao.getAllForWorkout(id: row[workoutId]))
    }
    
    
    
    
    
//    static func getAllWorkouts(profileId: UUID) -> [Workout] {
//
//        var workouts: [Workout] = []
//
//        do {
//            let urls = try FileManager.default.contentsOfDirectory(at: getWorkoutDirectory(profileId: profileId), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
//
//            for url in urls {
//                do {
//                    try workouts.append(load(url: url))
//                } catch {
//                    print("Workout couldn't be loaded in getAllWorkouts")
//                }
//            }
//
//        } catch {
//            print("Failed to get contents of workout directory in getAllWorkouts")
//        }
//        return workouts
//    }
//
//    static func getWorkoutsInDateRange(profileId: UUID, startDate: Date, endDate: Date) -> [Workout] {
//
//        let start: Int = Int(startDate.timeIntervalSince1970)
//        let end: Int = Int(endDate.timeIntervalSince1970)
//
//
//        var workouts: [Workout] = []
//
//        do {
//            let urls = try FileManager.default.contentsOfDirectory(at: getWorkoutDirectory(profileId: profileId), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
//
//            for url in urls {
//
//                let fileName = url.lastPathComponent
//                let fileNameWithoutExtension = fileName.prefix(upTo: fileName.index(fileName.endIndex, offsetBy: -5))
//                let timeStamp = Int(fileNameWithoutExtension)
//                if timeStamp != nil && timeStamp! >= start && timeStamp! <= end {
//
//                    do {
//                        try workouts.append(load(url: url))
//                    } catch {
//                        print("Workout couldn't be loaded in getWorkoutsInDateRange")
//                    }
//                }
//            }
//        } catch {
//            print("Failed to get contents of workout directory in getWorkoutsInDateRange")
//        }
//
//        return workouts
//    }
//
//    static func save(workout: Workout, profileId: UUID) throws {
//
//        let filePath: URL = try getWorkoutDirectory(profileId: profileId)
//        let fileName: String = String(Int(workout.date.timeIntervalSince1970))
//        let url = filePath.appendingPathComponent(fileName + ".json")
//
//        let encoder = JSONEncoder()
//        let workoutData = try encoder.encode(workout)
//        try workoutData.write(to: url)
//    }
//
//    static func load(url: URL) throws -> Workout {
//
//        let decoder = JSONDecoder()
//        let workoutData: Data = try Data(contentsOf: url)
//        let loadedWorkout: Workout = try decoder.decode(Workout.self, from: workoutData)
//        return loadedWorkout
//
//
//    }
//
//    static func deleteAllForProfile(_ profileId: UUID) throws {
//        let filePath: URL = try getWorkoutDirectory(profileId: profileId)
//        try FileManager.default.removeItem(at: filePath)
//    }
//
//    static func getWorkoutDirectory() throws -> URL {
//        let workout_url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Workouts")
//        if !FileManager.default.fileExists(atPath: workout_url.path) {
//            try FileManager.default.createDirectory(at: workout_url, withIntermediateDirectories: true, attributes: nil)
//        }
//        return workout_url
//    }
//
//    static func getWorkoutDirectory(profileId: UUID) throws -> URL {
//        let workout_url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Workouts").appendingPathComponent(profileId.uuidString)
//        if !FileManager.default.fileExists(atPath: workout_url.path) {
//            try FileManager.default.createDirectory(at: workout_url, withIntermediateDirectories: true, attributes: nil)
//        }
//        return workout_url
//    }
//
//
//
    
}

