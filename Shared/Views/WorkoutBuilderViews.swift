//
//  WorkoutView.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/14/22.
//

import SwiftUI


struct WorkoutViewMaster: View {
    @Environment(\.dismiss) var dismiss
    
    var session: Session
    
    var dismissParent: DismissAction
    
    func removeProfile(user: User) {
        session.workouts = session.workouts.filter { w in
            return w.user != user
        }
        if session.workouts.isEmpty {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                dismissParent()
            }
        }
    }

    var body: some View {
        EmptyView()
        TabView {
            ForEach(session.workouts, id: \.workoutId) { workout in
                WorkoutBuilderView(removeProfile: removeProfile)
                    .environmentObject(workout)
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
    @EnvironmentObject var workout: WorkoutDTO
    
    var removeProfile: (User) -> Void
    
    @State private var showFinishWorkoutSheet: Bool = false
    
    @State private var cardioTemplate: CardioDTO = CardioDTO()
    @State private var weightliftingTemplate: WeightliftingDTO = WeightliftingDTO()
    @State private var navigationSwitch: String?
    
    @State private var refresh: Bool = false
    
    private func loadExercises() {
        print("refreshed")
        refresh.toggle()
    }
    
    var body: some View {
        VStack(spacing: 0.0) {
            NavigationLink(destination: EditWeightliftingView(weightlifting: weightliftingTemplate).environmentObject(workout), tag: "EDIT_WEIGHTLIFTING", selection: $navigationSwitch) { EmptyView() }
            NavigationLink(destination: EditCardioView(cardio: cardioTemplate).environmentObject(workout), tag: "EDIT_CARDIO", selection: $navigationSwitch) { EmptyView() }
            
            Text(workout.user.name)
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding(.bottom)
                .background(workout.user.getColor())
            
            List {
                
//                DatePicker("Date/Time", selection: workout.date, displayedComponents: [.date, .hourAndMinute])
                
                
                Section(header: Text("Weightlifting")) {
                    ForEach(workout.weightlifting, id: \.weightliftingId) { wl in
                        Button {
                            weightliftingTemplate = wl.duplicate()
                            navigationSwitch = "EDIT_WEIGHTLIFTING"
                        } label: {
                            WeightLiftingMinimalView(weightLifting: wl, refresh: $refresh)
                        }
                    }
                    Button {
                        weightliftingTemplate = WeightliftingDTO(workoutId: workout.workoutId)
                        navigationSwitch = "EDIT_WEIGHTLIFTING"
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.accentColor)
                            Text("Add weightlifting")
                                .foregroundColor(.accentColor)
                        }
                    }

                }
                Section(header: Text("Cardio")) {
                    ForEach(workout.cardio, id: \.cardioId) { cardio in
                        Button {
                            cardioTemplate = cardio.duplicate()
                            navigationSwitch = "EDIT_CARDIO"
                        } label: {
                            CardioMinimalView(cardio: cardio, refresh: $refresh)
                        }
                    }
                    Button {
                        cardioTemplate = CardioDTO(workoutId: workout.workoutId)
                        navigationSwitch = "EDIT_CARDIO"
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.accentColor)
                            Text("Add cardio")
                                .foregroundColor(.accentColor)
                        }
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
        .onAppear {
            loadExercises()
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


