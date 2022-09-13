//
//  WeightLiftingViews.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/1/22.
//

import SwiftUI
import UIKit

struct WeightLiftingMinimalView: View {
    @ObservedObject var weightLifting: WeightliftingDTO
    @Binding var refresh: Bool
    
    var body: some View {
        HStack {
            Text(weightLifting.weightliftingType.name)
            Spacer()
            ForEach(weightLifting.sets, id: \.weightliftingSetId) { wSet in
                VStack {
                    Text(String(wSet.reps))
                    Text(String((weightLifting.weightIsOffset && wSet.weight >= 0 ? "+" : "") + String(wSet.weight)))
                }
            }
        }
    }
}



struct EditWeightliftingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) private var editMode
    @EnvironmentObject var workout: WorkoutDTO
    
    @ObservedObject var weightlifting: WeightliftingDTO
    @State var wlSetEditIndex: Int = 0
    @State private var editingSet: Bool = false
    
    
    var body: some View {
        VStack {
            if weightlifting.sets.count > 0 && editingSet {
                NavigationLink(destination: EditWeightliftingSetView(weightlifting: weightlifting, wlSet: weightlifting.sets[wlSetEditIndex]), isActive: $editingSet) {EmptyView()}
            }
            List {
                NavigationLink(destination: IdentifiableLabelPickerView(selection: $weightlifting.weightliftingType, getAllFunction: WeightliftingTypeDao.getAll, createFunction: WeightliftingTypeDao.create, deleteFunction: WeightliftingTypeDao.delete, warning: "Type can only be deleted if no workouts depend on it")) {
                    HStack {
                        Text("Weightlifting Type")
                        Spacer()
                        Text(weightlifting.weightliftingType.name)
                            .foregroundColor(Color(uiColor: UIColor.systemGray4))
                    }
                }
                NavigationLink(destination: IdentifiableLabelMultiSelectionView(selection: $weightlifting.tags, getAllFunction: WeightliftingTagDao.getAll, createFunction: WeightliftingTagDao.create, deleteFunction: WeightliftingTagDao.delete, warning: "Tag can only be deleted if no workouts depend on it")) {
                    HStack(spacing: 0.0) {
                        Text("Weightlifting Tags")
                        Spacer()
                        ForEach(weightlifting.tags, id: \.id) { tag in
                            Text(" " + tag.name)
                                .foregroundColor(Color(uiColor: UIColor.systemGray4))
                                .font(.caption2)
                        }
                    }
                }
                Toggle("Weight Is Offset?", isOn: $weightlifting.weightIsOffset)
                Toggle("Weight Is Individual?", isOn: $weightlifting.weightIsIndividual)
                
                Section(header:
                HStack {
                    Text("Sets")
                    Spacer()
                    Button(editMode?.wrappedValue == EditMode.active ? "Done" : "Edit") {
                        editMode?.wrappedValue = editMode?.wrappedValue == EditMode.active ? EditMode.inactive : EditMode.active
                    }
                }) {
                    ForEach(weightlifting.sets.indices, id: \.self) { index in
                        let wlSet = weightlifting.sets[index]
                        Button {
                            wlSetEditIndex = index
                            editingSet = true
                        } label: {
                            HStack {
                                Text(String(wlSet.reps))
                                Text(String((weightlifting.weightIsOffset && wlSet.weight >= 0 ? "+" : "") + String(wlSet.weight)))
                            }
                        }
                        
                    }
                    .onMove { indexSet, index in
                        weightlifting.sets.move(fromOffsets: indexSet, toOffset: index)
                    }
                    .onDelete { indexSet in
                        weightlifting.sets.remove(atOffsets: indexSet)
                    }
                }
                Section {
                    Button {
                        weightlifting.sets.append(WeightliftingSet(weightliftingId: weightlifting.weightliftingId, reps: (weightlifting.sets.last ?? WeightliftingSet()).reps, weight: (weightlifting.sets.last ?? WeightliftingSet()).weight))
                        wlSetEditIndex = weightlifting.sets.count - 1
                        editingSet = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.accentColor)
                            Text("Add Set")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if weightlifting.weightliftingType.id != -1 {
                    Button("Done") {
                        do {
                            if weightlifting.weightliftingId == -1 {
                                print("creating new weightlifting")
                                print(weightlifting.toString())
                                let newWl = try WeightliftingDao.create(wl: weightlifting)
                                print("new weightlifting:")
                                print(newWl.toString())
                                workout.weightlifting.append(newWl)
                            } else {
                                try WeightliftingDao.update(wl: weightlifting)
                                for i in 0..<workout.weightlifting.count {
                                    if (workout.weightlifting[i].weightliftingId == weightlifting.weightliftingId) {
                                        workout.weightlifting[i] = weightlifting
                                        break
                                    }
                                }
                            }
                            dismiss()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            ToolbarItem(placement: .bottomBar) {
                if weightlifting.weightliftingId != -1 {
                    Button("Delete") {
                        do {
                            try WeightliftingDao.delete(id: weightlifting.weightliftingId)
                            workout.weightlifting = workout.weightlifting.filter({ wl in
                                wl.weightliftingId != weightlifting.weightliftingId
                            })
                            dismiss()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    .foregroundColor(Color(uiColor: .systemRed))
                }
            }
        }
    }
}

struct EditWeightliftingSetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var weightlifting: WeightliftingDTO
    @ObservedObject var wlSet: WeightliftingSet
    
    var body: some View {
        VStack {
            TextField("Enter Reps", value: $wlSet.reps, format: .number)
                .multilineTextAlignment(.center)
            TextField("Enter Weight", value: $wlSet.weight, format: .number)
                .multilineTextAlignment(.center)
            Button("Done") {
                dismiss()
            }
            .foregroundColor(wlSet.reps != 0 && wlSet.weight != 0 ? .accentColor : Color(UIColor.systemGray4))
        }
        .font(.title)
    }
}

//
//
//struct WeightLiftingBuilderDetailedView: View {
//    @ObservedObject var weightLifting: WeightLiftingBuilder
//    
//    var body: some View {
//        VStack {
//            HStack {
//                ForEach(weightLifting.tags, id: \.self) { tag in
//                    Text(tag)
//                        .opacity(0.5)
//                }
//            }
//            List {
//                ForEach(weightLifting.sets) { wSet in
//                    HStack {
//                        Text(String(wSet.reps))
//                        Text(String((weightLifting.weightAsOffset && wSet.weight >= 0 ? "+" : "") + String(wSet.weight)))
//                    }
//                }
//                .onMove { indexSet, index in
//                    weightLifting.sets.move(fromOffsets: indexSet, toOffset: index)
//                }
//                .onDelete { indexSet in
//                    weightLifting.sets.remove(atOffsets: indexSet)
//                }
//                NavigationLink(destination: AddWeightLiftingSetView(weightLifting: weightLifting)) {
//                    Image(systemName: "plus.circle")
//                        .foregroundColor(.accentColor)
//                    Text("Add Set")
//                        .foregroundColor(.accentColor)
//                }
//                
//            }
//            .toolbar { EditButton() }
//        }
//        .navigationBarTitle(weightLifting.type)
//    }
//}
//
//
//struct AddWeightLiftingView: View {
//    @Environment(\.dismiss) var dismiss
//    @Binding var weightLiftings: [WeightLiftingBuilder]
//    
//    @State private var selectedType: String = ""
//    @State private var selectedTags: [String] = []
//    @State private var weightAsOffset: Bool = false
//    @State private var individualWeight: Bool = false
//    
//    var body: some View {
//        Form {
//            NavigationLink(destination: TextFilePickerView(url: WeightLifting.getTypeUrl(), subject: "Weight-Lifting Type", selection: $selectedType)) {
//                HStack {
//                    Text("Weight Lifting Type:")
//                    Spacer()
//                    Text(selectedType)
//                        .foregroundColor(Color(uiColor: .systemGray4))
//                }
//            }
//            
//            NavigationLink(destination: TextFileMultiSelectionView(url: WeightLifting.getTagUrl(), creationPrompt: "Create New Tag", selection: $selectedTags)) {
//                HStack {
//                    Text("Weight Lifting Tags")
//                    Spacer()
//                    ForEach(selectedTags, id: \.self) { tag in
//                        Text(tag)
//                            .foregroundColor(Color(uiColor: .systemGray4))
//                    }
//                }
//            }
//            Toggle("Weight is offset?", isOn: $weightAsOffset)
//            Toggle("Individual weight?", isOn: $individualWeight)
//        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                if (selectedType != "") {
//                    Button("Done") {
//                        weightLiftings.append(WeightLiftingBuilder(type: selectedType, tags: selectedTags, weightAsOffset: weightAsOffset, individualWeight: individualWeight))
//                        dismiss()
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct AddWeightLiftingSetView: View {
//    @Environment(\.dismiss) var dismiss
//    @ObservedObject var weightLifting: WeightLiftingBuilder
//    
//    @State private var reps: Int?
//    @State private var weight: Double?
//    
//    var body: some View {
//        
//        VStack {
//            TextField("Enter Reps", value: $reps, format: .number)
//                .multilineTextAlignment(.center)
//            TextField("Enter Weight", value: $weight, format: .number)
//                .multilineTextAlignment(.center)
//            Button("Done") {
//                if reps != nil && weight != nil {
//                    weightLifting.sets.append(WeightLiftingSet(weight: weight!, reps: reps!))
//                    dismiss()
//                }
//            }
//            .foregroundColor(reps != nil && weight != nil ? .accentColor : Color(UIColor.systemGray4))
//        }
//        .font(.title)
//    }
//}
