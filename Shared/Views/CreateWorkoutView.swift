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
    
    @State private var session: Session = Session(workouts: [])
    @State private var creatingWorkout: Bool = false
    
    
    
    var body: some View {
        Group {
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
                if Session.sessionExists() {
                    Button("Resume Previous Workout") {
                        do {
                            session = try Session.getSession()
                            creatingWorkout = true
                        } catch {
                            print(error.localizedDescription)
                        }
                        
                    }
                }
                
                
            }
            
            
            
            NavigationLink(destination: WorkoutViewMaster(session: session, dismissParent: dismiss).navigationBarBackButtonHidden(true), isActive: $creatingWorkout) {EmptyView()}
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if type.id != -1 && selectedUsers.count > 0 {
                    Button("Let's Do This!") {
                        do {
                            session = try Session.createSession(users: selectedUsers, workoutType: type)
                            creatingWorkout = true
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
}














