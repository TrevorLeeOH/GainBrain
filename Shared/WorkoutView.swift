//
//  WorkoutView.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/14/22.
//

import SwiftUI



struct WorkoutViewMaster: View {
    @Environment(\.dismiss) var dismiss
    var type: String
    @State var profiles: [Profile]
    var dismissParent: DismissAction
    
    func removeProfile(id: UUID) {
        profiles = profiles.filter { profile in
            return profile.id != id
        }
        if profiles.isEmpty {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                dismissParent()
            }
        }
    }
    
    var body: some View {
        TabView {
            ForEach(profiles) { profile in
                WorkoutView(profile: profile, date: Date.now, type: type, removeProfile: removeProfile)
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text(profile.name)
                    }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WorkoutView: View {
    
    var profile: Profile
    var date: Date
    var type: String
    
    var removeProfile: (UUID) -> Void
    
    @State private var showFinishWorkoutSheet: Bool = false
    
    @State private var refresh: Bool = false
    
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
                        NavigationLink(destination: EditWeightLiftingView(weightLifting: weightLiftings[index]).navigationBarTitleDisplayMode(.large)) {
                            WeightLiftingMinimalView(weightLifting: weightLiftings[index])
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


struct WeightLiftingMinimalView: View {
    @ObservedObject var weightLifting: WeightLiftingBuilder
    
    var body: some View {
        HStack {
            Text(weightLifting.type)
            Spacer()
            ForEach(weightLifting.sets) { wSet in
                VStack {
                    Text(String(wSet.reps))
                    Text(String((weightLifting.weightAsOffset && wSet.weight >= 0 ? "+" : "") + String(wSet.weight)))
                }
            }
        }
    }
}


struct AddWeightLiftingView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var weightLiftings: [WeightLiftingBuilder]
    
    @State private var selectedType: String = ""
    @State private var selectedTags: [String] = []
    @State private var weightAsOffset: Bool = false
    @State private var individualWeight: Bool = false
    
    var body: some View {
        Form {
            NavigationLink(destination: TextFilePickerView(url: WeightLifting.getTypeUrl(), subject: "Weight-Lifting Type", selection: $selectedType)) {
                HStack {
                    Text("Weight Lifting Type:")
                    Spacer()
                    Text(selectedType)
                        .foregroundColor(Color(uiColor: .systemGray4))
                }
            }
            
            NavigationLink(destination: TextFileMultiSelectionView(url: WeightLifting.getTagUrl(), creationPrompt: "Create New Tag", selection: $selectedTags)) {
                HStack {
                    Text("Weight Lifting Tags")
                    Spacer()
                    ForEach(selectedTags, id: \.self) { tag in
                        Text(tag)
                            .foregroundColor(Color(uiColor: .systemGray4))
                    }
                }
            }
            Toggle("Weight is offset?", isOn: $weightAsOffset)
            Toggle("Individual weight?", isOn: $individualWeight)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    weightLiftings.append(WeightLiftingBuilder(type: selectedType, tags: selectedTags, weightAsOffset: weightAsOffset, individualWeight: individualWeight))
                    dismiss()
                }
            }
        }
    }
}

struct EditWeightLiftingView: View {
    @ObservedObject var weightLifting: WeightLiftingBuilder
    
    var body: some View {
        VStack {
            HStack {
                ForEach(weightLifting.tags, id: \.self) { tag in
                    Text(tag)
                        .opacity(0.5)
                }
            }
            List {
                ForEach(weightLifting.sets) { wSet in
                    HStack {
                        Text(String(wSet.reps))
                        Text(String((weightLifting.weightAsOffset && wSet.weight >= 0 ? "+" : "") + String(wSet.weight)))
                    }
                }
                .onMove { indexSet, index in
                    weightLifting.sets.move(fromOffsets: indexSet, toOffset: index)
                }
                .onDelete { indexSet in
                    weightLifting.sets.remove(atOffsets: indexSet)
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    NavigationLink(destination: AddWeightLiftingSetView(weightLifting: weightLifting)) {
                        Text("Add Set")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
        .navigationBarTitle(weightLifting.type)
    }
}

struct AddWeightLiftingSetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var weightLifting: WeightLiftingBuilder
    
    @State private var reps: Int?
    @State private var weight: Double?
    
    var body: some View {
        
        VStack {
            TextField("Enter Reps", value: $reps, format: .number)
                .multilineTextAlignment(.center)
            TextField("Enter Weight", value: $weight, format: .number)
                .multilineTextAlignment(.center)
            Button("Done") {
                weightLifting.sets.append(WeightLiftingSet(weight: weight!, reps: reps!))
                dismiss()
            }
        }
        .font(.title)
        .toolbar {
            if reps != nil && weight != nil {
                Button("Done") {
                    weightLifting.sets.append(WeightLiftingSet(weight: weight!, reps: reps!))
                    dismiss()
                }
            }
        }
    }
}


struct CardioMinimalView: View {
    var cardio: Cardio
    
    var body: some View {
        NavigationLink(destination: CardioDetailView(cardio: cardio)) {
            HStack {
                Text(cardio.type)
                Spacer()
                ForEach(Array(cardio.statistics.keys), id: \.self) { key in
                    VStack {
                        Text(key.prefix(3) + ".")
                        Text(String(cardio.statistics[key]!))
                    }
                }
            }
        }
    }
}

struct CardioDetailView: View {
    var cardio: Cardio
    
    var body: some View {
        List {
            ForEach(Cardio.STATISTIC_TYPES, id: \.self) { type in
                if cardio.statistics[type] != nil {
                    Text(type + ": " + String(cardio.statistics[type]!))
                }
            }
        }
        .navigationBarTitle(cardio.type)
    }
}

struct AddCardioView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var cardios: [Cardio]
    
    @State var type: String = ""
    @State var tags: [String] = []
    @State var statisticSelections: [Double?] = Array(repeating: nil, count: Cardio.STATISTIC_TYPES.count)
        
    var body: some View {
        Form {
            
            NavigationLink(destination: TextFilePickerView(url: Cardio.getTypeUrl(), subject: "Cardio Type", selection: $type)) {
                
                HStack {
                    Text("Cardio Type")
                    Spacer()
                    Text(type)
                        .foregroundColor(Color(uiColor: UIColor.systemGray4))
                }
                
            }
            NavigationLink(destination: TextFileMultiSelectionView(url: Cardio.getTagUrl(), creationPrompt: "Create New Tag", selection: $tags)) {
                HStack(spacing: 0.0) {
                    Text("Cardio Tags")
                    Spacer()
                    ForEach(tags, id: \.self) { tag in
                        Text(" " + tag)
                            .foregroundColor(Color(uiColor: UIColor.systemGray4))
                            .font(.caption2)
                    }
                }
            }
            
            ForEach(Array(statisticSelections.indices), id: \.self) { index in
                TextField(Cardio.STATISTIC_TYPES[index], value: $statisticSelections[index], format: .number)
            }
            
            
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if (type != "") {
                    Button("Done") {
                        var newStatistics: Dictionary<String, Double> = [:]
                        for i in 0..<Cardio.STATISTIC_TYPES.count {
                            if statisticSelections[i] != nil {
                                newStatistics.updateValue(statisticSelections[i]!, forKey: Cardio.STATISTIC_TYPES[i])
                            }
                        }
                        let newCardio = Cardio(type: type, tags: tags, statistics: newStatistics)
                        cardios.append(newCardio)
                        dismiss()
                    }
                }
            }
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
        let workout = Workout(date: date, duration: round(date.distance(to: Date.now)), type: type, caloriesBurned: caloriesBurned, notes: notes, weight_lifting: wfs, cardio: cardios)
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


