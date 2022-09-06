//
//  WorkoutView.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/14/22.
//

import SwiftUI


struct WorkoutViewMaster: View {
    @Environment(\.dismiss) var dismiss
    var type: IdentifiableLabel
    var date: Date = Date.now
    @State var users: [User]
    
    var dismissParent: DismissAction
    
    func removeProfile(id: Int64) {
        users = users.filter { user in
            return user.userId != id
        }
        if users.isEmpty {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                dismissParent()
            }
        }
    }

    var body: some View {
        EmptyView()
//        TabView {
//            ForEach(users) { user in
//                WorkoutBuilderView(user: user, date: Date.now, type: type, removeProfile: removeProfile)
//                    .tabItem {
//                        Image(systemName: "person.circle")
//                        Text(profile.name)
//                    }
//            }
//        }
//        .navigationViewStyle(.columns)
//        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WorkoutBuilderView: View {
    
    var profile: Profile
    var date: Date
    var type: String
    
    var removeProfile: (UUID) -> Void
    
    @State private var showFinishWorkoutSheet: Bool = false
    
    @State private var weightLiftings: [WeightLiftingBuilder] = []
    @State private var cardios: [Cardio] = []
    
    var body: some View {
        VStack(spacing: 0.0) {
            Text(profile.name)
                .font(.title)
                .frame(maxWidth: .infinity)
                .padding(.bottom)
                .background(profile.color.toColor())
            List {
                
                Section(header: Text("Weight Lifting")) {
                    ForEach(weightLiftings.indices, id: \.self) { index in
                        NavigationLink(destination: WeightLiftingBuilderDetailedView(weightLifting: weightLiftings[index]).navigationBarTitleDisplayMode(.large)) {
                            WeightLiftingBuilderMinimalView(weightLifting: weightLiftings[index])
                        }
                        .contextMenu {
                            Button("Delete") {
                                weightLiftings.remove(at: index)
                            }
                        }
                    }
                    NavigationLink(destination: AddWeightLiftingView(weightLiftings: $weightLiftings)) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.accentColor)
                        Text("Add weight-lifting")
                            .foregroundColor(.accentColor)
                    }
                    
                }
                Section(header: Text("Cardio")) {
                    ForEach(cardios.indices, id: \.self) { index in
                        CardioMinimalView(cardio: cardios[index])
                            .contextMenu {
                            Button("Delete") {
                                cardios.remove(at: index)
                            }                            
                        }
                    }
                    NavigationLink(destination: AddCardioView(cardios: $cardios)) {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.accentColor)
                        Text("Add cardio")
                            .foregroundColor(.accentColor)
                    }
                }
                
            }
            .overlay {
                RoundedRectangle(cornerRadius: 16.0).stroke(profile.color.toColor(), lineWidth: 8.0)
            }
            .padding(4.0)
            .border(profile.color.toColor(), width: 6.0)
            
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
        .sheet(isPresented: $showFinishWorkoutSheet) {
            
        } content: {
            FinishWorkoutView(isPresented: $showFinishWorkoutSheet, date: date, type: type, profile: profile, weightLiftings: weightLiftings, cardios: cardios, removeProfile: removeProfile)
        }
    }
}


struct FinishWorkoutView: View {
    @Binding var isPresented: Bool
    var date: Date
    var type: String
    var profile: Profile
    var weightLiftings: [WeightLiftingBuilder]
    var cardios: [Cardio]
    
    var removeProfile: (UUID) -> Void
    
    @State private var caloriesBurned: Int?
    @State private var notes: String = ""
    
    
    func saveWorkout() throws {
        var wfs: [WeightLifting] = [];
        for w in weightLiftings {
            wfs.append(w.toStruct())
        }
        let workout = Workout(id: -1, date: date, duration: round(date.distance(to: Date.now)), type: type, caloriesBurned: caloriesBurned, notes: notes, weight_lifting: wfs, cardio: cardios)
        try WorkoutDao.save(workout: workout, profileId: profile.id)
        
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Notes:")) {
                    TextEditor(text: $notes)
                }
                Section(header: Text("Calories Burned (optional)")) {
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
                    do {
                        try saveWorkout()
                        isPresented = false
                        removeProfile(profile.id)
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                }
                Button("debug button") {
                    print(Date.now)
                    print(round(date.distance(to: Date.now)))
                }
                Spacer()
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
            Button("Discard Workout", role: .destructive) {
                isPresented = false
                removeProfile(profile.id)
            }
            .padding()
        }
    }
}


