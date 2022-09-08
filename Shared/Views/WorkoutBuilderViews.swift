//
//  WorkoutView.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/14/22.
//

import SwiftUI


struct WorkoutViewMaster: View {
    @Environment(\.dismiss) var dismiss
    
    @State var workouts: [WorkoutDTO]
    
    var dismissParent: DismissAction
    
    func removeProfile(user: User) {
        workouts = workouts.filter { w in
            return w.user != user
        }
        if workouts.isEmpty {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                dismissParent()
            }
        }
    }

    var body: some View {
        EmptyView()
        TabView {
            ForEach(workouts, id: \.workoutId) { workout in
                WorkoutBuilderView(workout: workout, removeProfile: removeProfile)
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text(workout.user.name)
                    }
            }
        }
        .navigationViewStyle(.columns)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WorkoutBuilderView: View {
    
    @StateObject var workout: WorkoutDTO
    
    var removeProfile: (User) -> Void
    
    @State private var showFinishWorkoutSheet: Bool = false
    
    
    var body: some View {
        VStack(spacing: 0.0) {
            Text(workout.user.name)
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding(.bottom)
                .background(workout.user.getColor())
            
            List {
                
                DatePicker("Date/Time", selection: $workout.date, displayedComponents: [.date, .hourAndMinute])
                Button("print Workout") {
                    print(workout.date)
                }
                
//                Section(header: Text("Weight Lifting")) {
//                    ForEach(weightLiftings.indices, id: \.self) { index in
//                        NavigationLink(destination: WeightLiftingBuilderDetailedView(weightLifting: weightLiftings[index]).navigationBarTitleDisplayMode(.large)) {
//                            WeightLiftingBuilderMinimalView(weightLifting: weightLiftings[index])
//                        }
//                        .contextMenu {
//                            Button("Delete") {
//                                weightLiftings.remove(at: index)
//                            }
//                        }
//                    }
//                    NavigationLink(destination: AddWeightLiftingView(weightLiftings: $weightLiftings)) {
//                        Image(systemName: "plus.circle")
//                            .foregroundColor(.accentColor)
//                        Text("Add weight-lifting")
//                            .foregroundColor(.accentColor)
//                    }
//
//                }
                Section(header: Text("Cardio")) {
                    ForEach(CardioDao.getAllForWorkout(id: workout.workoutId), id: \.cardioId) { cardio in
                        NavigationLink(destination: EditCardioView(cardio: cardio.duplicate())) {
                            CardioMinimalView(cardio: cardio)
                        }
                    }
                    NavigationLink(destination: EditCardioView(cardio: CardioDTO(workoutId: workout.workoutId))) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.accentColor)
                        Text("Add cardio")
                            .foregroundColor(.accentColor)
                    }
                }
                
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16.0).stroke(workout.user.getColor(), lineWidth: 8.0)
            }
            .padding(4.0)
            .border(workout.user.getColor(), width: 6.0)
            
            Button("Finish Workout") {
                showFinishWorkoutSheet = true
            }
            .padding(10)
            .font(.headline)
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            Rectangle().fill(Color(UIColor.systemGray))
                .frame(height: 1.0)
        }
        .sheet(isPresented: $showFinishWorkoutSheet) {
            
        } content: {
            FinishWorkoutView(isPresented: $showFinishWorkoutSheet, workout: workout, removeProfile: removeProfile)
        }
    }
}


struct FinishWorkoutView: View {
    @Binding var isPresented: Bool
    @ObservedObject var workout: WorkoutDTO
    
    var removeProfile: (User) -> Void
    
    @State var notes: String = ""
    
    func saveWorkout() throws {
        //code here
        
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Notes:")) {
                    TextEditor(text: $notes)
                }
                Section(header: Text("Calories Burned (optional)")) {
                    TextField("", value: $workout.caloriesBurned, format: .number)
                }
            }
            HStack {
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
                Spacer()
                Button("Save And Exit") {
                    do {
                        try saveWorkout()
                        isPresented = false
                        removeProfile(workout.user)
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }
                
                Spacer()
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            Button("Discard Workout", role: .destructive) {
                isPresented = false
                removeProfile(workout.user)
            }
            .padding()
        }
    }
}


