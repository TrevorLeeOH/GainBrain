//
//  Workout.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/6/22.
//

import Foundation

struct Workout {
    
    public var workoutId: Int64
    public var userId: Int64
    public var workoutTypeId: Int64
    public var date: Date
    public var duration: Double
    public var caloriesBurned: Int?
    public var notes: String?
    
}
