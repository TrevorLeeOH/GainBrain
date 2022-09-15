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
        
    func removeProfile(user: User) {
        session.workouts = session.workouts.filter { w in
            return w.user != user
        }
        do {
            if session.workouts.isEmpty {
                try SessionDao.deleteSession()
                dismiss()
            } else {
                try SessionDao.updateSession(session: session)
            }
        } catch {
            print(error.localizedDescription)
        }
    }

    var body: some View {
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
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var workout: WorkoutDTO
    
    var inSession: Bool = true
    
    var removeProfile: (User) -> Void
    
    @State private var showFinishWorkoutSheet: Bool = false
    
    @State private var cardioTemplate: CardioDTO = CardioDTO()
    @State private var weightliftingTemplate: WeightliftingDTO = WeightliftingDTO()
    @State private var navigationSwitch: String?
    
    @State private var refresh: Bool = false
    
    @State private var showDeleteConfirmation: Bool = false
    
    private func loadExercises() {
        print("refreshed")
        refresh.toggle()
    }
    
    var body: some View {
        VStack(spacing: 0.0) {
            
            NavigationLink(destination: EditWeightliftingView(weightlifting: weightliftingTemplate).environmentObject(workout), tag: "EDIT_WEIGHTLIFTING", selection: $navigationSwitch) { EmptyView() }
            NavigationLink(destination: EditCardioView(cardio: cardioTemplate).environmentObject(workout), tag: "EDIT_CARDIO", selection: $navigationSwitch) { EmptyView() }
            NavigationLink(destination: EditWorkoutPropertiesView().environmentObject(workout), tag: "EDIT_WORKOUT", selection: $navigationSwitch) { EmptyView() }
            
            
            VStack(spacing: 0.0) {
                Text(workout.user.name)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
                    .padding(8.0)
                
                Rectangle().fill(Color(uiColor: .systemBackground)).frame(height: 1.0)
                
                HStack(spacing: 0.0) {
                    Text(workout.workoutType.name)
                        .font(.headline)
                    Spacer()
                    Text(workout.date.toLocalFormattedString())
                        .font(.subheadline)
                        .italic()
                }
                .padding(.top, 8.0)
                .padding(.horizontal, 24.0)
                Button {
                    navigationSwitch = "EDIT_WORKOUT"
                } label: {
                    Text("Edit Workout Properties")
                        .font(.caption)
                }
                .padding(8.0)
                
                Rectangle().fill(Color(uiColor: .systemBackground)).frame(height: 1.0)
                
                List {
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
                            weightliftingTemplate = WeightliftingDTO(weightliftingId: -2)
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
                            cardioTemplate = CardioDTO(cardioId: -2)
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
                .cornerRadius(16.0)
                .padding(.vertical, 4.0)
                
                if inSession {
                    Rectangle().fill(Color(uiColor: .systemBackground)).frame(height: 1.0)
                    
                    Button {
                        showFinishWorkoutSheet = true
                    } label: {
                        Text("Finish Workout")
                            .frame(maxWidth: .infinity)
                            .frame(height: 26.0)
                    }
                    .padding(.horizontal, 20.0)
                    .padding(.vertical, 8.0)
                    .font(.headline)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.roundedRectangle(radius: 10.0))
                } else {
                    Button("Delete Workout", role: .destructive) {
                        showDeleteConfirmation = true
                    }
                    .padding(8.0)
                }
            }
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(16.0)
            .padding(.horizontal, 8.0)
            .padding(.vertical, 8.0)
        }
        .background(workout.user.getColor())
        .padding(.bottom, 1.0)
        .onAppear {
            loadExercises()
        }
        .sheet(isPresented: $showFinishWorkoutSheet) {
            
        } content: {
            FinishWorkoutView(isPresented: $showFinishWorkoutSheet, removeProfile: removeProfile)
        }
        .alert("Confirmation", isPresented: $showDeleteConfirmation) { //not available during sessions
            Button("Delete", role: .destructive) {
                do {
                    try WorkoutDao.delete(id: workout.workoutId)
                    dismiss()
                } catch {
                    print(error.localizedDescription)
                }
            }
        } message: {
            Text("Permanently delete workout?")
        }
    }
}


struct EditWorkoutPropertiesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var workout: WorkoutDTO
    @State var workoutType: IdentifiableLabel = IdentifiableLabel()
    @State var notes: String = ""
    @State var caloriesBurned: Int?
    @State var date: Date = Date.now
    @StateObject var duration: TimeIntervalClass = TimeIntervalClass()
    @State var showAlert: Bool = false
    
    var body: some View {
        Form {
            
            
            NavigationLink(destination: IdentifiableLabelPickerView(selection: $workoutType, getAllFunction: WorkoutTypeDao.getAll, createFunction: WorkoutTypeDao.create, deleteFunction: WorkoutTypeDao.delete, warning: "Warning: Workout Type will only be deleted if no Workouts depend on it.")) {
                HStack {
                    Text("Workout Type:")
                    Spacer()
                    Text(workoutType.name)
                        .foregroundColor(Color(UIColor.systemGray4))
                }
            }
            
            TextField("Calories Burned", value: $caloriesBurned, format: .number)
            
            
            DatePicker("Date/Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
            HStack {
                Text("Duration:")
                VStack {
                    Text("Hours")
                        .font(.caption)
                    TextField("Hours", value: $duration.hours, format: .number)
                }
                VStack {
                    Text("Minutes")
                        .font(.caption)
                    TextField("Minutes", value: $duration.minutes, format: .number)
                }
                VStack {
                    Text("Seconds")
                        .font(.caption)
                    TextField("Seconds", value: $duration.seconds, format: .number)
                        
                }
            }
            .multilineTextAlignment(.center)
            
            Section(header: Text("Notes")) {
                TextEditor(text: $notes)
                    .frame(height: 200)
            }
            
            
            
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if workoutType.id != -1 {
                    Button("Save Changes") {
                        showAlert = true
                    }
                }
            }
        }
        .onAppear {
            workoutType = workout.workoutType
            notes = workout.notes ?? ""
            caloriesBurned = workout.caloriesBurned
            date = workout.date
            if workout.duration != 0.0 {
                duration.hours = Int(workout.duration / 3600.0)
                duration.minutes = Int(workout.duration / 60.0)
                duration.seconds = Int(workout.duration / 3600.0)
            }
        }
        .alert("Caution", isPresented: $showAlert) {
            Button("Save Changes", role: .destructive) {
                let workoutToSave = workout.duplicate()
                workoutToSave.workoutType = workoutType
                workoutToSave.notes = notes
                workoutToSave.caloriesBurned = caloriesBurned
                workoutToSave.date = date
                if workout.duration != 0.0 {
                    workoutToSave.duration = duration.toTimeInterval()
                }
                do {
                    try WorkoutDao.update(workout: workoutToSave)
                    workout.workoutType = workoutType
                    workout.notes = notes
                    workout.caloriesBurned = caloriesBurned
                    workout.date = date
                    if workout.duration != 0.0 {
                        workout.duration = duration.toTimeInterval()
                    }
                    dismiss()
                } catch {
                    print(error.localizedDescription)
                }
            }
        } message: {
            Text("Duration is automatically set upon finishing a workout. Editing the duration here will override that process.")
        }
    }
}



struct FinishWorkoutView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var workout: WorkoutDTO
    
    var removeProfile: (User) -> Void
    
    @State var notes: String = ""
    @State var caloriesBurned: Int?
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Notes:")) {
                    TextEditor(text: $notes)
                }
                Section(header: Text("Calories Burned")) {
                    TextField("", value: $caloriesBurned, format: .number)
                }
            }
            HStack {
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
                Spacer()
                Button("Save And Exit") {
                    workout.notes = notes == "" ? nil : notes
                    workout.caloriesBurned = caloriesBurned
                    if workout.duration == 0.0 {
                        workout.duration = workout.date.distance(to: Date.now)
                    }
                    do {
                        try WorkoutDao.update(workout: workout)
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
                do {
                    try WorkoutDao.delete(id: workout.workoutId)
                    isPresented = false
                    removeProfile(workout.user)
                } catch {
                    print(error.localizedDescription)
                }
                    
            }
            .padding()
        }
        .onAppear {
            notes = workout.notes ?? ""
            caloriesBurned = workout.caloriesBurned
        }
    }
}


