//
//  DBSetup.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/3/22.
//

import Foundation
import SQLite

class Database {
    
    static func getDatabase() throws -> Connection {
        do {
            let documentDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let db = try Connection(documentDirectory.appendingPathComponent("db.sqlite3").path)
            return db
        }
    }
    
    static func initializeDatabase() {
        let documentDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let dbPath = documentDirectory.appendingPathComponent("db.sqlite3").path
        
        if FileManager.default.fileExists(atPath: dbPath) {
            do {
                try FileManager.default.removeItem(atPath: dbPath)
            } catch {
                print(error.localizedDescription)
                return
            }
            
        }
        
        do {
            let db = try getDatabase()
            
            
            //User Table
            let user = Table("user")
            let userId = Expression<Int64>("user_id")
            let name = Expression<String>("name")
            let h = Expression<Double>("h")
            let s = Expression<Double>("s")
            let b = Expression<Double>("b")
            
            try db.run(user.create { t in
                t.column(userId, primaryKey: true)
                t.column(name)
                t.column(h)
                t.column(s)
                t.column(b)
            })
            
            //Workout Type Table
            let workoutType = Table("workout_type")
            let workoutTypeId = Expression<Int64>("workout_type_id")
            let workoutTypeName = Expression<String>("name")
            
            try db.run(workoutType.create { t in
                t.column(workoutTypeId, primaryKey: true)
                t.column(workoutTypeName)
            })
            
            //Workout Table
            let workout = Table("workout")
            let workoutId = Expression<Int64>("workout_id")
            let userIdFK = Expression<Int64>("user_id")
            let workoutTypeIdFK = Expression<Int64>("workout_type_id")
            let date = Expression<Date>("date")
            let workoutDuration = Expression<TimeInterval>("duration")
            let caloriesBurned = Expression<Int?>("calories_burned")
            let notes = Expression<String?>("notes")
            
            try db.run(workout.create { t in
                t.column(workoutId, primaryKey: true)
                t.column(userIdFK, references: user, userId)
                t.column(workoutTypeIdFK, references: workoutType, workoutTypeId)
                t.column(date)
                t.column(workoutDuration)
                t.column(caloriesBurned)
                t.column(notes)
            })
            
            //Cardio Tag Table
            let cardioTag = Table("cardio_tag")
            let cardioTagId = Expression<Int64>("cardio_tag_id")
            let cardioTagName = Expression<String>("name")
            
            try db.run(cardioTag.create { t in
                t.column(cardioTagId, primaryKey: true)
                t.column(cardioTagName)
            })
            
            
            //Cardio Type Table
            let cardioType = Table("cardio_type")
            let cardioTypeId = Expression<Int64>("cardio_type_id")
            let cardioTypeName = Expression<Int64>("name")
            
            try db.run(cardioType.create { t in
                t.column(cardioTypeId, primaryKey: true)
                t.column(cardioTypeName)
            })
            
            //Cardio Table
            let cardio = Table("cardio")
            let cardioId = Expression<Int64>("cardio_id")
            let workoutIdCardioFK = Expression<Int64>("workout_id")
            let cardioTypeIdFK = Expression<Int64>("cardio_type_id")
            let duration = Expression<Double?>("duration")
            let distance = Expression<Double?>("distance")
            let speed = Expression<Double?>("speed")
            let resistance = Expression<Double?>("resistance")
            let incline = Expression<Double?>("incline")
            
            try db.run(cardio.create { t in
                t.column(cardioId, primaryKey: true)
                t.column(workoutIdCardioFK, references: workout, workoutId)
                t.column(cardioTypeIdFK, references: cardioType, cardioTypeId)
                t.column(duration)
                t.column(distance)
                t.column(speed)
                t.column(resistance)
                t.column(incline)
            })
            
            //Cardio Cardio Tag Table
            let cardioCardioTag = Table("cardio_cardio_tag")
            let cardioIdFK = Expression<Int64>("cardio_id")
            let cardioTagIdFK = Expression<Int64>("cardio_tag_id")
            
            try db.run(cardioCardioTag.create { t in
                t.column(cardioIdFK, references: cardio, cardioId)
                t.column(cardioTagIdFK, references: cardioTag, cardioTagId)
            })
            
            //Weightlifting Type Table
            let weightliftingType = Table("weightlifting_type")
            let weightliftingTypeId = Expression<Int64>("weightlifting_type_id")
            let weightliftingTypeName = Expression<Int64>("name")
            
            try db.run(weightliftingType.create { t in
                t.column(weightliftingTypeId, primaryKey: true)
                t.column(weightliftingTypeName)
            })
            
            //Weightlifting Table
            let weightlifting = Table("weightlifting")
            let weightliftingId = Expression<Int64>("weightlifting_id")
            let workoutIdWeightliftingFK = Expression<Int64>("workout_id")
            let weightliftingTypeFK = Expression<Int64>("weightlifting_type_id")
            let offset = Expression<Bool>("weight_is_offset")
            let individual = Expression<Bool>("weight_is_individual")
            
            try db.run(weightlifting.create { t in
                t.column(weightliftingId, primaryKey: true)
                t.column(workoutIdWeightliftingFK, references: workout, workoutId)
                t.column(weightliftingTypeFK, references: weightliftingType, weightliftingTypeId)
                t.column(offset, defaultValue: false)
                t.column(individual, defaultValue: false)
            })
            
            //Weightlifting Set Table
            let weightliftingSet = Table("weightlifting_set")
            let weightliftingSetId = Expression<Int64>("weightlifting_set_id")
            let weightliftingIdFK = Expression<Int64>("weightlifting_id")
            let reps = Expression<Int>("reps")
            let weight = Expression<Double>("weight")
            let wSetIndex = Expression<Int>("index")
            
            try db.run(weightliftingSet.create { t in
                t.column(weightliftingSetId, primaryKey: true)
                t.column(weightliftingIdFK, references: weightlifting, weightliftingId)
                t.column(reps)
                t.column(weight)
                t.column(wSetIndex)
            })
            
            //Weightlifting Tag Table
            let weightliftingTag = Table("weightlifting_tag")
            let weightliftingTagId = Expression<Int64>("weightlifting_tag_id")
            let weightliftingTagName = Expression<Int64>("name")
            
            try db.run(weightliftingTag.create { t in
                t.column(weightliftingTagId, primaryKey: true)
                t.column(weightliftingTagName)
            })
            
            //Weightlifting Weightlifting Tag Table
            let weightliftingWeightliftingTag = Table("weightlifting_weightlifting_tag")
            let weightliftingIdTagFK = Expression<Int64>("weightlifting_id")
            let weightliftingTagIdFK = Expression<Int64>("weightlifting_tag_id")
            
            try db.run(weightliftingWeightliftingTag.create { t in
                t.column(weightliftingIdTagFK, references: weightlifting, weightliftingId)
                t.column(weightliftingTagIdFK, references: weightliftingTag, weightliftingTagId)
            })
            
            
        } catch {
            print(error.localizedDescription)
        }
    }
}




    

