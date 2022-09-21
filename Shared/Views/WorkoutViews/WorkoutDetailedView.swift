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
                    
                    
                    //User
                    
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

struct WorkoutDetailedView_Previews: PreviewProvider {
    static var previews: some View {
        
        let fakeWorkout = WorkoutDTO(workoutId: 1,
                                     user: User(userId: 1, name: "fakeName", h: 0.2, s: 0.8, b: 0.8),
                                     workoutType: IdentifiableLabel(id: 1, name: "fakeType"),
                                     date: Date.now,
                                     duration: TimeIntervalClass(hours: 1, minutes: 20, seconds: 35).toTimeInterval(),
                                     caloriesBurned: 250,
                                     notes: "Here is a long sentence of fake notes. Here is a long sentence of fake notes. Here is a long sentence of fake notes. Here is a long sentence of fake notes.",
                                     weightlifting: [
                                        WeightliftingDTO(
                                            weightliftingId: 1,
                                            workoutId: 1,
                                            weightliftingType: IdentifiableLabel(id: 1, name: "FakeType"),
                                            tags: [],
                                            sets: [
                                                WeightliftingSet(
                                                    weightliftingSetId: 1,
                                                    weightliftingId: 1,
                                                    reps: 12, weight: 20.0,
                                                    index: 0)
                                            ],
                                            weightIsOffset: false,
                                            weightIsIndividual: true)
                                     ],
                                     cardio: [
                                        CardioDTO(
                                            cardioId: 1,
                                            workoutId: 1,
                                            cardioType: IdentifiableLabel(id: 1, name: "FakeType"),
                                            tags: [],
                                            duration: 30.0,
                                            distance: 5.0,
                                            speed: 5.0,
                                            resistance: nil,
                                            incline: nil)
                                     ])
        
        WorkoutDetailedView(workout: fakeWorkout)
    }
}
