//
//  CardioViews.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/1/22.
//

import SwiftUI

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
