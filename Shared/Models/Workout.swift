//
//  Workout.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/6/22.
//

import Foundation

class Workout: Equatable {
    
    public var workoutId: Int64
    public var userId: Int64
    @Published public var workoutTypeId: Int64
    @Published public var date: Date
    @Published public var duration: Double
    @Published public var caloriesBurned: Int?
    @Published public var notes: String?
    
    init(workoutId: Int64 = -1, userId: Int64, workoutTypeId: Int64, date: Date = Date.now, duration: Double = -1, caloriesBurned: Int? = nil, notes: String? = nil) {
        self.workoutId = workoutId
        self.userId = userId
        self.workoutTypeId = workoutTypeId
        self.date = date
        self.duration = duration
        self.caloriesBurned = caloriesBurned
        self.notes = notes
    }
    
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        return lhs.workoutId == rhs.workoutId
    }
    
    public func toString() -> String {
        return "workout id: \(workoutId), user id: \(userId), workout type id: \(workoutTypeId), date: \(date), duration: \(duration), calories burned: \(caloriesBurned ?? -1), notes: \(notes ?? "")"
    }
    
}
