//
//  WeightLiftingViews.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/1/22.
//

import SwiftUI

struct WeightLiftingBuilderMinimalView: View {
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


struct WeightLiftingBuilderDetailedView: View {
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
                NavigationLink(destination: AddWeightLiftingSetView(weightLifting: weightLifting)) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.accentColor)
                    Text("Add Set")
                        .foregroundColor(.accentColor)
                }
                
            }
            .toolbar { EditButton() }
        }
        .navigationBarTitle(weightLifting.type)
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
                if (selectedType != "") {
                    Button("Done") {
                        weightLiftings.append(WeightLiftingBuilder(type: selectedType, tags: selectedTags, weightAsOffset: weightAsOffset, individualWeight: individualWeight))
                        dismiss()
                    }
                }
            }
        }
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
                if reps != nil && weight != nil {
                    weightLifting.sets.append(WeightLiftingSet(weight: weight!, reps: reps!))
                    dismiss()
                }
            }
            .foregroundColor(reps != nil && weight != nil ? .accentColor : Color(UIColor.systemGray4))
        }
        .font(.title)
    }
}
