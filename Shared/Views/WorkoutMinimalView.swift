//
//  WorkoutMinimalView.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/15/22.
//

import SwiftUI

struct WorkoutMinimalView: View {
    
    var workout: WorkoutDTO
    
    var body: some View {
        HStack {
            Text(workout.workoutType.name)
            Spacer()
            Text(workout.date.toLocalFormattedString())
        }
        
    }
}

