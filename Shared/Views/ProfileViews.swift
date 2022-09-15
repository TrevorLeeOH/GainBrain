//
//  ProfileViews.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/1/22.
//

import SwiftUI

struct ProfileSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var users: [User] = []
    @Binding var selectedUsers: [User]
    
    var body: some View {
        List {
            ForEach(users, id: \.userId) { user in
                HStack {
                    Image(systemName: selectedUsers.contains(user) ? "checkmark.circle.fill" : "circle")
                        .renderingMode(.original)
                        .foregroundColor(selectedUsers.contains(user) ? .accentColor : Color(uiColor: .systemGray4))
                    Button(user.name) {
                        if selectedUsers.contains(user) {
                            selectedUsers = selectedUsers.filter { u in
                                u != user
                            }
                        } else {
                            selectedUsers.append(user)
                        }
                    }
                    .foregroundColor(user.getColor())
                }
                .listRowBackground(selectedUsers.contains(user) ? Color(uiColor: .systemGray4) : nil)
            }
            
            Section {
                NavigationLink(destination: CreateProfileView()) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.accentColor)
                    Text("Create New Profile")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if selectedUsers.count > 0 {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .bottomBar) {
                if selectedUsers.count == 1 {
                    NavigationLink(destination: CreateProfileView(user: selectedUsers.first!.duplicate())) {
                        Text("Edit Profile")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .onAppear {
            print("Pulled users from database")
            users = []
            users = UserDao.getAll()
            for i in 0..<selectedUsers.count {
                if !users.contains(selectedUsers[i]) {
                    selectedUsers.remove(at: i)
                }
            }
        }
    }
}

struct CreateProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var user: User = User()
    @State var isEditing: Bool = false
    
    @State var deleteConfirmation: Bool = false
    
    
    var body: some View {
        Form {
            TextField("New Profile Name", text: $user.name)
                .multilineTextAlignment(.center)
                .font(.title)
                .padding(.vertical, 5.0)
            HStack {
                VStack(spacing: 0.0) {
                    HStack {
                        Text("Hue: ")
                        Slider(value: $user.h, in: 0.0...1.0) { editing in
                            isEditing = editing
                        }
                    }
                    HStack {
                        Text("Saturation: ")
                        Slider(value: $user.s, in: 0.0...1.0) { editing in
                            isEditing = editing
                        }
                    }
                    HStack {
                        Text("Brightness: ")
                        Slider(value: $user.b, in: 0.0...1.0) { editing in
                            isEditing = editing
                        }
                    }
                }
                
                Spacer()
                    .frame(width: 50, height: 100)
                    .cornerRadius(10.0)
                    .background {
                        RoundedRectangle(cornerRadius: 10.0)
                            .fill(Color(hue: user.h, saturation: user.s, brightness: user.b))
                        
                    }
                    .padding(.leading)
            }
        }
        .alert("Confirm Delete", isPresented: $deleteConfirmation) {
            Button("Delete Profile And Workouts", role: .destructive) {
                do {
                    try UserDao.delete(id: user.userId)
                    print("successfully deleted user")
                    dismiss()
                } catch {
                    print(error.localizedDescription)
                }
            }
        } message: {
            Text("Warning: Profile and all corresponding workouts will be deleted. This cannot be undone.")
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save And Exit") {
                    do {
                        if user.userId == -1 {
                            try UserDao.create(user: user)
                            print("Successfully created new user")
                        } else {
                            try UserDao.update(user: user)
                            print("Successfully updated user")
                        }
                        dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            ToolbarItem(placement: .bottomBar) {
                if user.userId != -1 {
                    Button("Delete User") {
                        deleteConfirmation = true
                    }
                    .foregroundColor(Color(uiColor: .systemRed))
                }
            }
        }
    }
}



