//
//  Session.swift
//  GainBrain (iOS)
//
//  Created by Trevor Lee on 9/8/22.
//

import Foundation

class Session: ObservableObject {
    @Published var workouts: [WorkoutDTO]
    
    init(workouts: [WorkoutDTO]) {
        self.workouts = workouts
    }
}



