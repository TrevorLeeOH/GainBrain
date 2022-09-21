//
//  WorkoutLogView.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/15/22.
//

import SwiftUI


struct WorkoutLogProfilePickerView: View {
    
    @State var users: [User] = []
    @State var workouts: [WorkoutDTO] = []
    @State var showWorkoutLogView: Bool = false
    
    var body: some View {
        Group {
            NavigationLink(destination: WorkoutLogView(workouts: workouts), isActive: $showWorkoutLogView) { EmptyView() }
            
            List {
                ForEach(users, id: \.userId) { user in
                    Button(user.name) {
                        workouts = WorkoutDao.getAllForUser(userId: user.userId)
                        showWorkoutLogView = true
                    }
                    .foregroundColor(user.getColor())
                }
            }
            .onAppear {
                users = UserDao.getAll()
            }
        }
        
    }
}

struct WorkoutLogView: View {
    
    var workouts: [WorkoutDTO]
    @State var filteredWorkouts: [WorkoutDTO] = []
    
    @State var filterDate: Bool = false
    @State var startDate: Date = Calendar(identifier: .gregorian).startOfDay(for: Date())
    @State var endDate: Date = Calendar(identifier: .gregorian).startOfDay(for: Date()).addingTimeInterval(86390)
    
    @State var filterType: Bool = false
    @State var selectedTypes: [IdentifiableLabel] = []
    
    private func applyFilters() {
        filteredWorkouts = []
        filteredWorkouts = workouts
        if filterDate {
            filteredWorkouts = filteredWorkouts.filter({ w in
                return w.date >= startDate && w.date <= endDate
            })
        }
        if filterType {
            filteredWorkouts = filteredWorkouts.filter({ w in
                return selectedTypes.contains(w.workoutType)
            })
        }
    }
    
    var body: some View {
        VStack {
            
            Form {
                NavigationLink(destination: WorkoutLogDateRangePicker(filterDate: $filterDate, startDate: $startDate, endDate: $endDate)) {
                    HStack {
                        Text("Date Filter")
                        if filterDate {
                            Spacer()
                            Text(startDate.toDateString() + " - " + endDate.toDateString())
                                .font(.caption)
                                .foregroundColor(Color(UIColor.systemGray4))
                        }
                    }
                }
                NavigationLink(destination: WorkoutLogTypePicker(filterType: $filterType, selectedTypes: $selectedTypes)) {
                    HStack {
                        Text("Type Filter")
                        if filterType {
                            Spacer()
                            ForEach(selectedTypes, id: \.id) { t in
                                Text(t.name)
                                    .font(.caption)
                                    .foregroundColor(Color(UIColor.systemGray4))
                            }
                        }
                    }
                }
                
            }
            List {
                ForEach(filteredWorkouts, id: \.workoutId) { w in
                    NavigationLink(destination: WorkoutDetailedView(workout: w).navigationBarTitleDisplayMode(.inline)) {
                        WorkoutMinimalView(workout: w)
                    }
                    
                }
            }
            
        }
        .onAppear {
            applyFilters()
        }
    }
}

struct WorkoutLogDateRangePicker: View {
    @Binding var filterDate: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    var body: some View {
        Form {
            Toggle("Filter by Date", isOn: $filterDate)
            DatePicker("Start Date", selection: $startDate, in: PartialRangeThrough(endDate), displayedComponents: [.date])
            DatePicker("End Date", selection: $endDate, in: PartialRangeFrom(startDate), displayedComponents: [.date])
        }
    }
}

struct WorkoutLogTypePicker: View {
    @Binding var filterType: Bool
    @Binding var selectedTypes: [IdentifiableLabel]
    
    @State var types: [IdentifiableLabel] = []
    
    var body: some View {
        List {
            Toggle("Filter by Type", isOn: $filterType)
            
            ForEach(types, id: \.id) { type in
                HStack {
                    Image(systemName: selectedTypes.contains(type) ? "checkmark.circle.fill" : "circle")
                        .renderingMode(.original)
                        .foregroundColor(selectedTypes.contains(type) ? .accentColor : Color(uiColor: .systemGray4))
                    Button(type.name) {
                        if selectedTypes.contains(type) {
                            selectedTypes = selectedTypes.filter { t in
                                t != type
                            }
                        } else {
                            selectedTypes.append(type)
                        }
                    }
                }
                .listRowBackground(selectedTypes.contains(type) ? Color(uiColor: .systemGray4) : nil)
            }
        }
        .onAppear {
            types = WorkoutTypeDao.getAll()
        }
    }
}
