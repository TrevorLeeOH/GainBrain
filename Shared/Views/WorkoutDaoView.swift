////
////  WorkoutDaoView.swift
////  GainBrain
////
////  Created by Trevor Lee on 8/6/22.
////
//
//import SwiftUI
//
//struct WorkoutDaoView: View {
//
//    @State private var profiles: [Profile] = []
//    @State private var selectedProfile: UUID?
//
//    @State private var withinRange: Bool = false
//    @State private var fromDate: Date = Date()
//    @State private var toDate: Date = Date()
//
//    var body: some View {
//        Form {
//            Picker("Select Profile", selection: $selectedProfile) {
//                ForEach(profiles) {
//                    Text($0.name)
//                        .tag(UUID?.some($0.id))
//                        .foregroundColor($0.color.toColor())
//                }
//            }
//            Toggle("Within Specified Range", isOn: $withinRange)
//            if withinRange {
//                DatePicker("From Date", selection: $fromDate, displayedComponents: .date)
//                DatePicker("To Date", selection: $toDate, displayedComponents: .date)
//            }
//            if selectedProfile != nil {
//                NavigationLink(destination: withinRange ? WorkoutRetrievalResultsView(workouts: WorkoutDao.getWorkoutsInDateRange(profileId: selectedProfile!, startDate: fromDate, endDate: toDate)) : WorkoutRetrievalResultsView(workouts: WorkoutDao.getAllWorkouts(profileId: selectedProfile!))) {
//                    Text("Search")
//                }
//            }
//
//        }
//        .onAppear {
//            profiles = Profile.getProfiles()
//        }
//    }
//}
//
//struct WorkoutRetrievalResultsView: View {
//
//    var workouts: [Workout]
//    @State private var filteredWorkouts: [Workout] = []
//    @State private var showFilters: Bool = true
//    @State private var showResults: Bool = true
//
//    @State private var typeFilter: Set<String> = Set<String>()
//
//    @State private var filterDuration: Bool = false
//    @State private var minDuration: Double = 0.0
//    @State private var maxDuration: Double = 0.0
//
//    @State private var requireWeightLifting: Bool = false
//    @State private var requireCardio: Bool = false
//
//
//    func filterByType() {
//        if typeFilter.count > 0 {
//            filteredWorkouts = filteredWorkouts.filter({ w in typeFilter.contains(w.type) })
//        }
//    }
//
//    func filterByDuration() {
//        if filterDuration {
//            filteredWorkouts = filteredWorkouts.filter({ w in
//                w.duration >= minDuration && w.duration <= maxDuration
//            })
//        }
//    }
//
//    func getDurationText(_ duration: Double) -> String {
//        if duration >= 3600 {
//            return String(duration / 3600) + " Hrs"
//        } else if duration >= 60 {
//            return String(duration / 60) + " Min"
//        } else {
//            return String(duration) + " Sec"
//        }
//    }
//
//    func filterByExercise() {
//        if requireWeightLifting {
//            filteredWorkouts = filteredWorkouts.filter({ w in
//                w.weight_lifting.count > 0
//            })
//        }
//        if requireCardio {
//            filteredWorkouts = filteredWorkouts.filter({ w in
//                w.cardio.count > 0
//            })
//        }
//    }
//
//    func applyFilters() {
//        filteredWorkouts = workouts
//        filterByType()
//        filterByDuration()
//        filterByExercise()
//    }
//
//    var body: some View {
//
//        Form {
//
//            Section(
//                header:
//                    Text("Filters " + "(tap to " + (showFilters ? "hide)" : "show)")).onTapGesture { withAnimation { showFilters.toggle() } }) {
//                if showFilters {
//                    NavigationLink(destination: WorkoutTypeFilterView(typeFilter: $typeFilter)) {
//                        HStack {
//                            Text("Type")
//                            Spacer()
//                            if (typeFilter.count > 0) {
//                                ForEach(Array(typeFilter), id: \.self) { type in
//                                    Text(type).foregroundColor(Color(UIColor.systemGray4))
//                                }
//                            } else {
//                                Text("All").foregroundColor(Color(UIColor.systemGray4))
//                            }
//                        }
//                    }
//
//                    NavigationLink(destination: WorkoutDurationFilterView(workouts: workouts, active: $filterDuration, minDuration: $minDuration, maxDuration: $maxDuration)) {
//                        HStack {
//                            Text("Duration")
//                            Spacer()
//                            if (filterDuration) {
//                                Text(getDurationText(minDuration) + " < Dur < " + getDurationText(maxDuration))
//                                    .foregroundColor(Color(UIColor.systemGray4))
//                            } else {
//                                Text("All").foregroundColor(Color(UIColor.systemGray4))
//                            }
//                        }
//                    }
//
//                    NavigationLink(destination: WorkoutExerciseFilterView(requireWeightLifting: $requireWeightLifting, requireCardio: $requireCardio)) {
//                        Text("Req. Ex. Type(s)")
//                        Spacer()
//                        if (!requireWeightLifting && !requireCardio) {
//                            Text("None").foregroundColor(Color(UIColor.systemGray4))
//                        }
//                        if (requireWeightLifting) {
//                            Text("W.L.").foregroundColor(Color(UIColor.systemGray4))
//                        }
//                        if (requireCardio) {
//                            Text("Cardio").foregroundColor(Color(UIColor.systemGray4))
//                        }
//                    }
//                }
//            }
//            Section(header: Text("Results (tap to " + (showResults ? "hide)" : "show)")).onTapGesture { withAnimation { showResults.toggle() } }) {
//                if showResults {
//                    ForEach(filteredWorkouts.indices, id: \.self) { index in
//                        WorkoutMinimalView(workout: filteredWorkouts[index])
//                    }
//                }
//            }
//            Section {
//                NavigationLink(destination: Text("Get Statistics")) {
//                    Text("Get Statistics")
//                }
//            }
//        }
//        .onAppear {
//            filteredWorkouts = workouts
//            applyFilters()
//        }
//    }
//}
//
//
//
//
//struct WorkoutDurationFilterView: View {
//
//    var workouts: [Workout]
//    @Binding var active: Bool
//    @Binding var minDuration: Double
//    @Binding var maxDuration: Double
//
//    func getMaxDurationValue() -> Double {
//        if workouts.count == 0 {
//            return 1.0
//        }
//        return workouts.reduce(0.0, { m, w in
//            max(m, w.duration)
//        })
//    }
//
//    var body: some View {
//        Form {
//            Toggle(active ? "Turn Off Filter" : "Turn On Filter", isOn: $active)
//            Text("Min: " + minDuration.TimeIntervalDescription())
//            Slider(value: $minDuration, in: 0...getMaxDurationValue(), step: 1)
//            Text("Max: " + maxDuration.TimeIntervalDescription())
//            Slider(value: $maxDuration, in: 0...getMaxDurationValue(), step: 1)
//        }
//    }
//}
//
//struct WorkoutTypeFilterView: View {
//    @Environment(\.editMode) var editMode
//    @State var workoutTypes: [String] = []
//    @Binding var typeFilter: Set<String>
//
//    var body: some View {
//        List(selection: $typeFilter) {
//            ForEach(workoutTypes, id: \.self) { type in
//                Text(type)
//            }
//
//        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button("Clear Selection") {
//                    typeFilter.removeAll()
//                }
//            }
//        }
//        .onAppear {
//            do { try workoutTypes = Workout.getWorkoutTypes() } catch {
//                print(error.localizedDescription)
//            }
//            editMode?.wrappedValue = EditMode.active
//        }
//    }
//}
//
//
//struct WorkoutExerciseFilterView: View {
//    @Binding var requireWeightLifting: Bool
//    @Binding var requireCardio: Bool
//
//    var body: some View {
//        Form {
//            Toggle("Require Wight-lifting", isOn: $requireWeightLifting)
//            Toggle("Require Cardio", isOn: $requireCardio)
//        }
//    }
//}
//
//
//
//struct WorkoutMinimalView: View {
//
//    var workout: Workout
//    @State var dateFormatter: DateFormatter = DateFormatter()
//    var durationFormatter: DateComponentsFormatter = DateComponentsFormatter()
//
//    var body: some View {
//        NavigationLink(destination: WorkoutDetailedView(workout: workout, dateFormatter: dateFormatter)) {
//            HStack {
//                Text(workout.type + " | ") +
//                Text(dateFormatter.string(from: workout.date))
//
//            }
//        }
//        .onAppear {
//            dateFormatter = DateFormatter()
//            dateFormatter.dateFormat = "MMM d, yyyy @ h:mm a"
//            durationFormatter.allowedUnits =  [.hour, .minute, .second]
//            durationFormatter.unitsStyle = .abbreviated
//        }
//    }
//}
//
//
//struct WorkoutDetailedView: View {
//    var workout: Workout
//    var dateFormatter: DateFormatter
//
//    var body: some View {
//        List {
//            Section(header: Text("Weight-Lifting")) {
//                ForEach(workout.weight_lifting, id: \.self) { weightLifting in
//                    WeightLiftingStructMinimalView(weightLifting: weightLifting)
//                }
//            }
//
//            Section(header: Text("Cardio")) {
//                ForEach(workout.cardio, id: \.self) { cardio in
//                    CardioMinimalView(cardio: cardio)
//                }
//            }
//
//            Section {
//                Text("Duration: " + (workout.duration.TimeIntervalDescription()))
//                if workout.notes != nil {
//                    Text("Notes:\r" + workout.notes!)
//                }
//            }
//
//        }
//        .navigationTitle(workout.type)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Text(dateFormatter.string(from: workout.date))
//            }
//        }
//    }
//}
//
//
//struct WeightLiftingStructMinimalView: View {
//    var weightLifting: WeightLifting
//
//    var body: some View {
//        NavigationLink(destination: WeightLiftingStructDetailedView(weightLifting: weightLifting)) {
//            HStack {
//                Text(weightLifting.type)
//                Spacer()
//                ForEach(weightLifting.sets) { wSet in
//                    VStack {
//                        Text(String(wSet.reps))
//                        Text(String((weightLifting.weightAsOffset && wSet.weight >= 0 ? "+" : "") + String(wSet.weight)))
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct WeightLiftingStructDetailedView: View {
//    var weightLifting: WeightLifting
//
//    var columns = [
//        GridItem(.flexible(minimum: 0.0, maximum: .infinity), spacing: 0.0),
//        GridItem(.flexible(minimum: 0.0, maximum: .infinity), spacing: 0.0)
//    ]
//
//    var body: some View {
//        List {
//            LazyVGrid(columns: columns, spacing: 0.0) {
//                Text("Reps")
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .border(.black, width: 2.0)
//                Text("Weight")
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .border(.black, width: 2.0)
//                ForEach(weightLifting.sets) { wSet in
//                    Text(String(wSet.reps))
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .border(.gray, width: 1.0)
//                    Text(String(wSet.weight))
//                        .padding()
//                        .frame(maxWidth: .infinity)
//                        .border(.gray, width: 1.0)
//
//                }
//            }
//            HStack {
//                Text("Individual Weight?")
//                Text(weightLifting.individualWeight ? "Yes" : "No").opacity(0.5)
//            }
//        }
//        .navigationBarTitle(weightLifting.type)
//    }
//}
//
//
//struct WorkoutStatisticsView: View {
//    var body: some View {
//        EmptyView()
//    }
//}
//
//

