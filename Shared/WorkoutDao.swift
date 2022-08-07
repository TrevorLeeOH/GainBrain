//
//  WorkoutDao.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/12/22.
//

import Foundation

class WorkoutDao {
    
    static func getAllWorkouts(profileId: UUID) -> [Workout] {
        
        var workouts: [Workout] = []
        
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: getWorkoutDirectory(profileId: profileId), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
            for url in urls {
                do {
                    try workouts.append(load(url: url))
                } catch {
                    print("Workout couldn't be loaded in getAllWorkouts")
                }
            }
            
        } catch {
            print("Failed to get contents of workout directory in getAllWorkouts")
        }
        return workouts
    }
    
    static func getWorkoutsInDateRange(profileId: UUID, startDate: Date, endDate: Date) -> [Workout] {
        
        let start: Int = Int(startDate.timeIntervalSince1970)
        let end: Int = Int(endDate.timeIntervalSince1970)
        
        
        var workouts: [Workout] = []
        
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: getWorkoutDirectory(profileId: profileId), includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
            for url in urls {
                
                let fileName = url.lastPathComponent
                let fileNameWithoutExtension = fileName.prefix(upTo: fileName.index(fileName.endIndex, offsetBy: -5))
                let timeStamp = Int(fileNameWithoutExtension)
                if timeStamp != nil && timeStamp! >= start && timeStamp! <= end {
                    
                    do {
                        try workouts.append(load(url: url))
                    } catch {
                        print("Workout couldn't be loaded in getWorkoutsInDateRange")
                    }
                }
            }
        } catch {
            print("Failed to get contents of workout directory in getWorkoutsInDateRange")
        }
        
        return workouts
    }

    static func save(workout: Workout, profileId: UUID) throws {
        
        let filePath: URL = try getWorkoutDirectory(profileId: profileId)
        let fileName: String = String(Int(workout.date.timeIntervalSince1970))
        let url = filePath.appendingPathComponent(fileName + ".json")
        
        let encoder = JSONEncoder()
        let workoutData = try encoder.encode(workout)
        try workoutData.write(to: url)
    }
    
    static func load(url: URL) throws -> Workout {
        
        let decoder = JSONDecoder()
        let workoutData: Data = try Data(contentsOf: url)
        let loadedWorkout: Workout = try decoder.decode(Workout.self, from: workoutData)
        return loadedWorkout
            
        
    }
    
    static func deleteAllForProfile(_ profileId: UUID) throws {
        let filePath: URL = try getWorkoutDirectory(profileId: profileId)
        try FileManager.default.removeItem(at: filePath)
    }
    
    static func getWorkoutDirectory() throws -> URL {
        let workout_url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Workouts")
        if !FileManager.default.fileExists(atPath: workout_url.path) {
            try FileManager.default.createDirectory(at: workout_url, withIntermediateDirectories: true, attributes: nil)
        }
        return workout_url
    }
    
    static func getWorkoutDirectory(profileId: UUID) throws -> URL {
        let workout_url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Workouts").appendingPathComponent(profileId.uuidString)
        if !FileManager.default.fileExists(atPath: workout_url.path) {
            try FileManager.default.createDirectory(at: workout_url, withIntermediateDirectories: true, attributes: nil)
        }
        return workout_url
    }
    
    
    
    
}

