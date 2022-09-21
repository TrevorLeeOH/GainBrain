//
//  CreateWorkoutView.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/13/22.
//

import SwiftUI

struct CreateWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @State private var type: IdentifiableLabel = IdentifiableLabel()
    @State private var selectedUsers: [User] = []
    
    @Binding var parentNavSwitch: String?
    
    var body: some View {
        
        Form {
            NavigationLink(destination: IdentifiableLabelPickerView(selection: $type, getAllFunction: WorkoutTypeDao.getAll, createFunction: WorkoutTypeDao.create, deleteFunction: WorkoutTypeDao.delete, warning: "Warning: Workout Type will only be deleted if no Workouts depend on it.")) {
                HStack {
                    Text("Workout Type:")
                    Spacer()
                    Text(type.name)
                        .foregroundColor(Color(UIColor.systemGray4))
                }
            }
            
            NavigationLink(destination: ProfileSelectionView(selectedUsers: $selectedUsers)) {
                HStack {
                    Text("Who Is Working Out?")
                    Spacer()
                    ForEach(selectedUsers, id: \.userId) { user in
                        Text(user.name.prefix(1))
                            .font(.headline)
                            .foregroundColor(user.getColor())
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if type.id != -1 && selectedUsers.count > 0 {
                    Button("Let's Do This!") {
                        do {
                            let _ = try SessionDao.createSession(users: selectedUsers, workoutType: type)
                            UINavigationBar.setAnimationsEnabled(false)
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                UINavigationBar.setAnimationsEnabled(true)
                                parentNavSwitch = "CREATE_WORKOUT"
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
}














