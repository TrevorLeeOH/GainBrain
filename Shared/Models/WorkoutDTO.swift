//
//  Workout.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/11/22.
//

import Foundation
import System

class WorkoutDTO: ObservableObject, Equatable {
    
    var workoutId: Int64
    var user: User
    var workoutType: IdentifiableLabel
    @Published var date: Date
    @Published var duration: TimeInterval?
    @Published var caloriesBurned: Int?
    @Published var notes: String?
    @Published var weightLifting: [WeightLiftingBuilder]
    @Published var cardio: [Cardio]
    
    init(workoutId: Int64 = -1, user: User, workoutType: IdentifiableLabel, date: Date = Date.now, duration: TimeInterval? = nil, caloriesBurned: Int? = nil, notes: String? = nil, weightLifting: [WeightLiftingBuilder] = [], cardio: [Cardio] = []) {
        self.workoutId = workoutId
        self.user = user
        self.workoutType = workoutType
        self.date = date
        self.duration = duration
        self.caloriesBurned = caloriesBurned
        self.notes = notes
        self.weightLifting = weightLifting
        self.cardio = cardio
    }
    
    static func == (lhs: WorkoutDTO, rhs: WorkoutDTO) -> Bool {
        return lhs.workoutId == rhs.workoutId
    }
    
}




