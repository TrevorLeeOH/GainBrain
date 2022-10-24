//
//  WorkoutDetailedView.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/21/22.
//

import SwiftUI

struct WorkoutDetailedView: View {
    
    @ObservedObject public var workout: WorkoutDTO
    @State private var refresh: Bool = false
    
    func doNothing(user: User) -> Void {}
    
    var body: some View {
        ZStack {
            VStack(spacing: 0.0) {
                HStack(spacing: 0.0) {
                    List {
                        Section(header: Text("Workout Type")) {
                            Text(workout.workoutType.name)
                        }
                        Section(header: Text("Duration")) {
                            Text(TimeIntervalClass(timeInterval: workout.duration).toString())
                        }
                    }
                    List {
                        Section(header: Text("Date")) {
                            Text(workout.date.toLocalFormattedString())
                        }
                        Section(header: Text("Calories Burned")) {
                            Text(workout.caloriesBurned != nil ? String(workout.caloriesBurned!) : "n/a")
                        }
                    }
                }
                .frame(height: 220)
                List {
                    Section(header: Text("Weightlifting")) {
                        ForEach(workout.weightlifting, id: \.weightliftingId) { wl in
                            WeightliftingMinimalView(weightlifting: wl, refresh: $refresh)
                        }
                    }
                    Section(header: Text("Cardio")) {
                        ForEach(workout.cardio, id: \.cardioId) { cardio in
                            CardioMinimalView(cardio: cardio, refresh: $refresh)
                        }
                    }
                    
                    if let notes = workout.notes {
                        Section(header: Text("Notes")) {
                            Text(notes)
                        }
                    }
                }
            }
            .cornerRadius(16.0)
        }
        .padding(8.0)
        .background(workout.user.getColor())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: WorkoutBuilderView( inSession: false, removeProfile: doNothing).environmentObject(workout)) {
                    Text("Edit")
                        .foregroundColor(.accentColor)
                }
            }
        }
        
    }
}


