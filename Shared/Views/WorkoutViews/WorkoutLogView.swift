//
//  WorkoutLogView.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/15/22.
//

import SwiftUI


struct WorkoutLogProfilePickerView: View {
    
    @State var users: [User] = []
    @State var selection: User?
    @State var workouts: [WorkoutDTO] = []
    @State var showWorkoutLogMenu: Bool = false
    
    var body: some View {
        Group {
            if let user = selection {
                NavigationLink(destination: WorkoutLogMenu(user: user, workouts: workouts), isActive: $showWorkoutLogMenu) {EmptyView()}
            }
            
            
            List {
                ForEach(users, id: \.userId) { user in
                    Button(user.name) {
                        selection = user
                        showWorkoutLogMenu = true
                        workouts = WorkoutDao.getAllForUser(userId: user.userId)
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

struct WorkoutLogMenu: View {
    
    var user: User
    var workouts: [WorkoutDTO]
    
    @State var workoutsPerWeek: Double = 0.0
    @State var workoutHistoryRange: String = "last 2 weeks"
    
    func switchWorkoutHistoryRange() {
        if workoutHistoryRange == "all-time" {
            let workoutCount = workouts.filter { w in
                return w.date.distance(to: Date.now) <= 2592000
            }.count
            workoutsPerWeek = Double(workoutCount) * (7.0 / 30.0)
            workoutHistoryRange = "last 30 days"
        } else if workoutHistoryRange == "last 30 days" {
            let workoutCount = workouts.filter { w in
                return w.date.distance(to: Date.now) <= 604800 * 2.0
            }.count
            workoutsPerWeek = Double(workoutCount) / 2.0
            workoutHistoryRange = "last 2 weeks"
        } else {
            let numberOfWeeks = workouts.first!.date.distance(to: workouts.last!.date) / 604800.0
            workoutsPerWeek = Double(workouts.count) / numberOfWeeks
            workoutHistoryRange = "all-time"
        }
    }
    
    
    var body: some View {
        List {
            if !workouts.isEmpty {
                Button {
                    switchWorkoutHistoryRange()
                } label: {
                    HStack(spacing: 0.0) {
                        Text("Workouts Per Week (\(workoutHistoryRange)): ")
                            .font(.caption)
                        
                        Spacer()
                        if workoutsPerWeek < 1 {
                            Text("<1")
                        } else if Int(workoutsPerWeek) == Int(ceil(workoutsPerWeek)) {
                            Text(String(Int(workoutsPerWeek)))
                        } else {
                            Text("\(Int(workoutsPerWeek))-\(Int(ceil(workoutsPerWeek)))")
                        }
                        
                    }
                }
                
                VStack {
                    Text("Last Workout:")
                    WorkoutMinimalView(workout: workouts.last!)
                }
            }
            
            
            
            
            NavigationLink(destination: WorkoutLogView(workouts: workouts)) {
                Text("View Workout History")
                    .foregroundColor(.accentColor)
            }
            Button("View Exercise Statistics") {
                
            }
        }
        .navigationTitle(user.name)
        .onAppear {
            switchWorkoutHistoryRange()
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
