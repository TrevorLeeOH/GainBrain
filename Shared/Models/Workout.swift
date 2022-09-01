//
//  Workout.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/11/22.
//

import Foundation
import System



struct Workout: Codable, Hashable {
    
    var date: Date
    var duration: TimeInterval?
    var type: String
    var caloriesBurned: Int?
    var notes: String?
    
    var weight_lifting: [WeightLifting]
    var cardio: [Cardio]
    
    init(date: Date, duration: TimeInterval?, type: String, caloriesBurned: Int?, notes: String?, weight_lifting: [WeightLifting], cardio: [Cardio]) {
        self.date = date
        self.duration = duration
        self.type = type
        self.caloriesBurned = caloriesBurned
        self.notes = notes
        self.weight_lifting = weight_lifting
        self.cardio = cardio
    }
    
    
    static func getWorkoutTypes() throws -> [String] {
        let result: String = try String(contentsOf: getWorkoutTypesFile())
        return result.components(separatedBy: .newlines)
    }
    
    static func getWorkoutTypes() throws -> String {
        return try String(contentsOf: getWorkoutTypesFile())
    }
    
    static func createWorkoutType(type: String) throws {
        var contents: String = try getWorkoutTypes()
        contents += "\n" + type
        try contents.write(to: getWorkoutTypesFile(), atomically: true, encoding: .utf8)
    }
    
    static func setWorkoutTypes(types: [String]) throws {
        let dataToWrite: String = types.joined(separator: "\n")
        try dataToWrite.write(to: getWorkoutTypesFile(), atomically: true, encoding: .utf8)
    }
    
    static func getWorkoutTypesFile() -> URL {
        let url: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("WorkoutTypes.txt")
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
        return url
    }
    
    static func delete(workoutType: String) throws {
        var contents: [String] = try getWorkoutTypes()
        
        for index: Int in 0..<contents.count {
            if contents[index] == workoutType {
                contents.remove(at: index)
                try setWorkoutTypes(types: contents)
                print("successful deletion")
                break;
            }
        }
    }
    
    
}



