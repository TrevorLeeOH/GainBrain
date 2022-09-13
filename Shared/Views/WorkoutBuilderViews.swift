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
                try Session.deleteSession()
                dismiss()
            } else {
                try Session.updateSession(session: session)
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
            NavigationLink(destination: EditWorkoutPropertiesView().environmentObject(workout), tag: "EDIT_WORKOUT", selection: $navigationSwitch) { EmptyView() }
            
            Text(workout.user.name)
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding(.bottom)
                .background(workout.user.getColor())
            
            List {
                Button("Print weightlifting") {
                    for x in workout.weightlifting {
                        print(x.toString())
                    }
                }
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
                
                Button("Edit Workout Properties") {
                    navigationSwitch = "EDIT_WORKOUT"
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
            FinishWorkoutView(isPresented: $showFinishWorkoutSheet, removeProfile: removeProfile).environmentObject(workout)
        }
    }
}


struct EditWorkoutPropertiesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var workout: WorkoutDTO
    @State var workoutType: IdentifiableLabel = IdentifiableLabel()
    @State var notes: String = ""
    @State var caloriesBurned: Int?
    
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
            
            TextEditor(text: $notes)
            
            TextField("Calories Burned", value: $caloriesBurned, format: .number)
            
            NavigationLink(destination: EditWorkoutDatesAndTimes().environmentObject(workout)) {
                Text("Edit Dates/Times")
            }
            
            
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if workoutType.id != -1 {
                    Button("Save Changes") {
                        let workoutToSave = workout.duplicate()
                        workoutToSave.workoutType = workoutType
                        workoutToSave.notes = notes
                        workoutToSave.caloriesBurned = caloriesBurned
                        do {
                            try WorkoutDao.update(workout: workoutToSave)
                            workout.workoutType = workoutType
                            workout.notes = notes
                            workout.caloriesBurned = caloriesBurned
                            dismiss()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
        .onAppear {
            workoutType = workout.workoutType
            notes = workout.notes ?? ""
            caloriesBurned = workout.caloriesBurned
        }
    }
}

struct EditWorkoutDatesAndTimes: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var workout: WorkoutDTO
    
    @State var date: Date = Date()
    @StateObject var duration: TimeIntervalClass = TimeIntervalClass()
    @State var showAlert: Bool = false

    var body: some View {
        Form {
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
            
        }
        .alert("Caution", isPresented: $showAlert) {
            Button("Set Custom Dates/Times", role: .destructive) {
                let workoutToSave = workout.duplicate()
                workoutToSave.date = date
                workoutToSave.duration = duration.toTimeInterval()
                do {
                    try WorkoutDao.update(workout: workoutToSave)
                    workout.date = date
                    workout.duration = duration.toTimeInterval()
                    dismiss()
                } catch {
                    print(error.localizedDescription)
                }
            }
        } message: {
            Text("Start date/time and duration are automatically set when creating and finishing a workout. Editing these values here will overwrite that process.")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save Changes") {
                    showAlert = true
                }
            }
        }
        .onAppear {
            date = workout.date
            if workout.duration != -1 {
                duration.hours = Int(workout.duration / 3600)
                duration.minutes = Int(workout.duration / 60)
                duration.seconds = Int(workout.duration / 3600)
            }
        }
    }
}

struct FinishWorkoutView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var workout: WorkoutDTO
    
    var removeProfile: (User) -> Void
    
    @State var notes: String = ""
    @State var caloriesBurned: Int?
    
    func saveWorkout() throws {
        //code here
        
    }
    
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
                    print(workout.date.description)
                    print(workout.date.distance(to: Date.now))
                    workout.notes = notes == "" ? nil : notes
                    workout.caloriesBurned = caloriesBurned
                    if workout.duration == -1 {
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


