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
            NavigationLink(destination: TextFilePickerView(url: Workout.getWorkoutTypesFile(), subject: "Workout Type", selection: $type)) {
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











