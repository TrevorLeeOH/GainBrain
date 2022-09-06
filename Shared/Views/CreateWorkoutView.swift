//
//  CreateWorkoutView.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/13/22.
//

import SwiftUI

struct CreateWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @State private var type: IdentifiableLabel?
    @State private var selectedUsers: [User] = []
    
    var body: some View {
        Form {
            NavigationLink(destination: WorkoutTypePickerView(selection: $type)) {
                HStack {
                    Text("Workout Type:")
                    Spacer()
                    Text(type != nil ? type!.name : "")
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
                if type != nil && selectedUsers.count > 0 {
//                    NavigationLink(destination: WorkoutViewMaster(type: type!, profiles: selectedUsers, dismissParent: dismiss).navigationBarBackButtonHidden(true)) {
//                        Text("Let's Do This")
//                    }
                }
            }
        }
    }
}


struct WorkoutTypePickerView: View {
    @Environment(\.dismiss) var dismiss
        
    @State var options: [IdentifiableLabel] = []
    
    @Binding var selection: IdentifiableLabel?
    
    @State var filter: String = ""
    
    @State private var sheetIsActive: Bool = false
    
    @State private var deleteConfirmation: Bool = false
    
    private func loadOptions() {
        options = WorkoutTypeDao.getAll()
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "magnifyingglass").opacity(0.3)
                    TextField("Filter", text: $filter)
                }
            }
            
            ForEach(options) { option in
                if filter == "" || option.name.lowercased().contains(filter.lowercased()) {
                    Button(option.name) {
                        selection = option
                        dismiss()
                    }
                }
            }
            .onDelete { indexSet in
                selection = options[indexSet.first!]
                deleteConfirmation = true
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Create") {
                    sheetIsActive = true
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
        }
        .onAppear { loadOptions() }
        .sheet(isPresented: $sheetIsActive) { loadOptions() } content: {
            WorkoutTypePickerViewCreateView(isActive: $sheetIsActive)
        }
        .alert("Confirm Delete", isPresented: $deleteConfirmation) {
            Button("Delete Workout Type", role: .destructive) {
                do {
                    try WorkoutTypeDao.delete(id: selection!.id)
                    print("deleted workout type")
                    selection = nil
                    loadOptions()
                } catch {
                    print(error.localizedDescription)
                }
            }
        } message: {
            Text("Warning: Workout Type will only be deleted if no Workouts depend on it.")
        }
    }
}


struct WorkoutTypePickerViewCreateView: View {
    
    @Binding var isActive: Bool
    @State var userInput: String = ""
    
    var body: some View {
        TextField("Type Here", text: $userInput)
            .font(.title)
            .multilineTextAlignment(.center)
            .onSubmit {
                do {
                    try WorkoutTypeDao.create(type: IdentifiableLabel(name: userInput))
                    print("Created workout type")
                    isActive = false
                } catch {
                    print(error.localizedDescription)
                }
            }
    }
}








