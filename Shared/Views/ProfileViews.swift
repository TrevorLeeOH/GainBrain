//
//  ProfileViews.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/1/22.
//

import SwiftUI

struct ProfileSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) var editMode
    @State private var profiles: [Profile] = []
    @State private var profileSelection: [Bool] = []
    @State private var createProfileSheet: Bool = false
    
    @Binding var selectedProfiles: [Profile]
    @State private var listSelection: Set<UUID> = Set<UUID>()
    
    @State var deleteConfirmation: Bool = false
    
    @State var profileToEdit: Profile?
    
    private func refresh() {
        profiles = Profile.getProfiles()
        while profileSelection.count < profiles.count {
            profileSelection.append(false)
        }
    }
    
    var body: some View {
        List(profiles, selection: $listSelection) { profile in
            Text(profile.name)
                .foregroundColor(profile.color.toColor())
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
            ToolbarItem(placement: .navigationBarTrailing) {
                if listSelection.count == 1 {
                    Button("Edit") {
                        do {
                            profileToEdit = try Profile.getProfile(id: listSelection.first!)
                            createProfileSheet = true
                        } catch {
                            print(error.localizedDescription)
                        }
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
            CreateProfileView(createProfileSheet: $createProfileSheet, profileToEdit: profileToEdit)
        }
    }
}

struct CreateProfileView: View {
    
    @Binding var createProfileSheet: Bool
    
    var profileToEdit: Profile?
    
    @State var profileName: String = ""
    
    @State var r: Double = 1.0
    @State var g: Double = 1.0
    @State var b: Double = 1.0
    @State var isEditing: Bool = false
    
    
    var body: some View {
        VStack {
            
            TextField("New Profile Name", text: $profileName)
                .multilineTextAlignment(.center)
                .font(.title)
                .padding()
            HStack {
                VStack {
                    HStack {
                        Text("Red: ")
                        Slider(value: $r, in: 0.0...1.0) { editing in
                            isEditing = editing
                        }
                    }
                    HStack {
                        Text("Green: ")
                        Slider(value: $g, in: 0.0...1.0) { editing in
                            isEditing = editing
                        }
                    }
                    HStack {
                        Text("Blue: ")
                        Slider(value: $b, in: 0.0...1.0) { editing in
                            isEditing = editing
                        }
                    }
                    
                }
                .padding(.horizontal)
                
                Spacer()
                    .frame(width: 50, height: 100)
                    .cornerRadius(10.0)
                    .background {
                        RoundedRectangle(cornerRadius: 10.0)
                            .fill(Color(red: r, green: g, blue: b))
                        
                    }
                    .padding(.trailing)
                
            }
            
            
            Button(profileToEdit != nil ? "Save" : "Create") {
                do {
                    if profileToEdit != nil {
                        try Profile.createProfile(profile: Profile(name: profileName, color: CodableColor(r: r, g: g, b: b, a: 1.0), id: profileToEdit!.id))
                    } else {
                        try Profile.createProfile(profile: Profile(name: profileName, color: CodableColor(r: r, g: g, b: b, a: 1.0)))
                    }
                    createProfileSheet = false
                } catch {
                    print(error.localizedDescription)
                }
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            Button("Cancel", role: .destructive) {
                createProfileSheet = false
            }
        }
        .onAppear {
            if profileToEdit != nil {
                profileName = profileToEdit!.name
                r = profileToEdit!.color.r
                g = profileToEdit!.color.g
                b = profileToEdit!.color.b
            }
        }
    }
}
