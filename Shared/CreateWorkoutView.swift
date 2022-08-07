//
//  CreateWorkoutView.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/13/22.
//

import SwiftUI

struct CreateWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @State private var type: String = ""
    @State private var selectedProfiles: [Profile] = []
    
    var body: some View {
        Form {
                        
            NavigationLink(destination: WorkoutTypePicker(selection: $type)) {
                HStack {
                    Text("Workout Type:")
                    Spacer()
                    Text(type)
                        .foregroundColor(Color(UIColor.systemGray4))
                }
            }
            
            NavigationLink(destination: ProfileSelectionView(selectedProfiles: $selectedProfiles)) {
                HStack {
                    Text("Who Is Working Out?")
                    Spacer()
                    ForEach(selectedProfiles) { profile in
                        Text(profile.name.prefix(1))
                            .font(.headline)
                            .foregroundColor(profile.color.toColor())
                    }
                }
                
            }
        }
        .toolbar {
            if type != "" && selectedProfiles.count > 0 {
                NavigationLink(destination: WorkoutViewMaster(type: type, profiles: selectedProfiles, dismissParent: dismiss).navigationBarBackButtonHidden(true)) {
                    Text("Let's Do This")
                }
            }
        }
    }
}


struct CreateWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        CreateWorkoutView()
    }
}


struct ProfileSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) var editMode
    @State private var profiles: [Profile] = []
    @State private var profileSelection: [Bool] = []
    @State private var createProfileSheet: Bool = false
    
    @Binding var selectedProfiles: [Profile]
    @State private var listSelection: Set<UUID> = Set<UUID>()
    
    @State var deleteConfirmation: Bool = false
    
    private func refresh() {
        profiles = Profile.getProfiles()
        while profileSelection.count < profiles.count {
            profileSelection.append(false)
        }
    }
    
    var body: some View {
        List(profiles, selection: $listSelection) {
            Text($0.name)
                .foregroundColor($0.color.toColor())
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Create New Profile") {
                    createProfileSheet = true
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if listSelection.count > 0 {
                    Button("Remove", role: .destructive) {
                        deleteConfirmation = true
                    }
                    .foregroundColor(Color(uiColor: .systemRed))
                }
                
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if listSelection.count > 0 {
                    Button("Select") {
                        selectedProfiles.removeAll()
                        for profile in profiles {
                            if listSelection.contains(profile.id) {
                                selectedProfiles.append(profile)
                            }
                        }
                        dismiss()
                    }
                }
            }
        }
        .onAppear { refresh() ; editMode?.wrappedValue = EditMode.active }
        .alert("Confirm Delete", isPresented: $deleteConfirmation) {
            Button("Delete Profile And Workouts", role: .destructive) {
                listSelection.forEach { id in
                    do {
                        try Profile.deleteProfile(profileId: id)
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }
                refresh()
            }
        } message: {
            Text("Warning: Profile and all corresponding workouts will be deleted. This cannot be undone.")
        }
        .sheet(isPresented: $createProfileSheet) { refresh() } content: {
            CreateProfileView(createProfileSheet: $createProfileSheet)
        }
    }
}

struct CreateProfileView: View {
    
    @Binding var createProfileSheet: Bool
    @State var profileName: String = ""
    @State var selection: CodableColor = CodableColor(r: 0.0, g: 0.0, b: 0.0, a: 1.0)
    
    @State var r: Double = 0.0
    @State var g: Double = 0.0
    @State var b: Double = 0.0
    
    @State var isEditing: Bool = false
    
    
    var body: some View {
        VStack {
            
            TextField("New Profile Name", text: $profileName)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: r, green: g, blue: b))
            HStack {
                Text("Red: ")
                Slider(value: $r, in: 0.0...1.0) { editing in
                    isEditing = editing
                }
            }
            .padding(.horizontal)
            HStack {
                Text("Green: ")
                Slider(value: $g, in: 0.0...1.0) { editing in
                    isEditing = editing
                }
            }
            .padding(.horizontal)
            HStack {
                Text("Blue: ")
                Slider(value: $b, in: 0.0...1.0) { editing in
                    isEditing = editing
                }
            }
            .padding(.horizontal)
            
            Button("Create") {
                do {
                    try Profile.createProfile(profile: Profile(name: profileName, color: CodableColor(r: r, g: g, b: b, a: 1.0)))
                    createProfileSheet = false
                } catch {
                    print(error.localizedDescription)
                }
            }
            Button("Cancel") {
                createProfileSheet = false
            }
            
        }
    }
}

struct WorkoutTypePicker: View {
    @Environment(\.dismiss) var dismiss
    @State var workoutTypes: [String] = []
    
    @Binding var selection: String
    
    @State var addWorkoutSheet: Bool = false
    @State var newType: String = ""
    
    @State var deleteConfirmation: Bool = false
    @State var workoutToDelete: String?
    
    private func refresh() {
        do {
            workoutTypes = try Workout.getWorkoutTypes()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    var body: some View {
        List {
            ForEach(workoutTypes.indices, id: \.self) { index in
                Button(workoutTypes[index]) {
                    selection = workoutTypes[index]
                    dismiss()
                }
            }
            .onMove(perform: { indexSet, index in
                workoutTypes.move(fromOffsets: indexSet, toOffset: index)
                do {
                    try Workout.setWorkoutTypes(types: workoutTypes)
                } catch {
                    print(error.localizedDescription)
                }
            })
            .onDelete { indexSet in
                workoutToDelete = workoutTypes[indexSet.first!]
                deleteConfirmation = true
            }
        }
        .alert("Confirm Delete", isPresented: $deleteConfirmation, actions: {
            
            Button("Delete", role: .destructive) {
                if workoutToDelete != nil {
                    do {
                        try Workout.delete(workoutType: workoutToDelete!)
                        deleteConfirmation = false
                        refresh()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }, message: {
            VStack {
                Text("Warning: Existing workout data may utilize this workout type")
                
            }
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .bottomBar) {
                Button("Add Workout Type") {
                    addWorkoutSheet = true
                }
            }
            
        }
        .onAppear {
            refresh()
        }
        .sheet(isPresented: $addWorkoutSheet) {
            refresh()
        } content: {
            TextField("New Workout Type", text: $newType)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                .onSubmit {
                    do {
                        try Workout.createWorkoutType(type: newType)
                        addWorkoutSheet = false
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
        }
    }
}







