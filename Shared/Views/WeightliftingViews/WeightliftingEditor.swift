//
//  WeightliftingEditor.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/21/22.
//

import SwiftUI

struct WeightliftingEditor: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) private var editMode
    @EnvironmentObject var workout: WorkoutDTO
    
    @ObservedObject var weightlifting: WeightliftingDTO
    @State var wlSetEditIndex: Int = 0
    @State private var editingSet: Bool = false
    
    
    var body: some View {
        VStack {
            if weightlifting.sets.count > 0 && editingSet {
                NavigationLink(destination: WeightliftingSetEditor(weightlifting: weightlifting, wlSet: weightlifting.sets[wlSetEditIndex]), isActive: $editingSet) {EmptyView()}
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
                                Text(String(weightlifting.weightIsOffset && wlSet.weight >= 0 ? "+" : "") + wlSet.weightToString())
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
                    Button("Save Changes") {
                        do {
                            if weightlifting.weightliftingId == -1 {
                                let newWl = try WeightliftingDao.create(wl: weightlifting)
                                workout.weightlifting.append(newWl)
                            } else {
                                let newWl = try WeightliftingDao.update(wl: weightlifting)
                                for i in 0..<workout.weightlifting.count {
                                    if (workout.weightlifting[i].weightliftingId == weightlifting.weightliftingId) {
                                        workout.weightlifting[i] = newWl
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
