//
//  CardioViews.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/1/22.
//

import SwiftUI

struct CardioMinimalView: View {
    var cardio: CardioDTO
    
    var body: some View {
        HStack {
            Text(cardio.cardioType.name)
            Spacer()
            
            if let duration = cardio.duration {
                VStack {
                    Text("dur.")
                    Text(String(duration))
                }
            }
            if let distance = cardio.distance {
                VStack {
                    Text("dst.")
                    Text(String(distance))
                }
            }
            if let speed = cardio.speed {
                VStack {
                    Text("spd.")
                    Text(String(speed))
                }
            }
            if let resistance = cardio.resistance {
                VStack {
                    Text("res.")
                    Text(String(resistance))
                }
            }
            if let incline = cardio.incline {
                VStack {
                    Text("inc.")
                    Text(String(incline))
                }
            }
        }
    }
}

struct CardioDetailView: View {
    var cardio: CardioDTO
    
    var body: some View {
        List {
            if let duration = cardio.duration {
                Text("Duration: " + String(duration))
            }
            if let distance = cardio.distance {
                Text("Distance: " + String(distance))
            }
            if let speed = cardio.speed {
                Text("Speed: " + String(speed))
            }
            if let resistance = cardio.resistance {
                Text("Resistance: " + String(resistance))
            }
            if let incline = cardio.incline {
                Text("Incline: " + String(incline))
            }
        }
        .navigationBarTitle(cardio.cardioType.name)
    }
}

struct EditCardioView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var cardio: CardioDTO
    
    var cardioId: Int64?
        
    var body: some View {
        Form {
            
            NavigationLink(destination: CardioTypePickerView(selection: $cardio.cardioType)) {
                HStack {
                    Text("Cardio Type")
                    Spacer()
                    Text(cardio.cardioType.name)
                        .foregroundColor(Color(uiColor: UIColor.systemGray4))
                }
                
            }
//            NavigationLink(destination: TextFileMultiSelectionView(url: Cardio.getTagUrl(), creationPrompt: "Create New Tag", selection: $tags)) {
//                HStack(spacing: 0.0) {
//                    Text("Cardio Tags")
//                    Spacer()
//                    ForEach(tags, id: \.self) { tag in
//                        Text(" " + tag)
//                            .foregroundColor(Color(uiColor: UIColor.systemGray4))
//                            .font(.caption2)
//                    }
//                }
//            }
            
            TextField("Duration", value: $cardio.duration, format: .number)
            TextField("Distance", value: $cardio.distance, format: .number)
            TextField("Speed", value: $cardio.speed, format: .number)
            TextField("Resistance", value: $cardio.resistance, format: .number)
            TextField("Incline", value: $cardio.incline, format: .number)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if cardio.cardioType.id != -1 {
                    Button("Done") {
                        do {
                            if cardio.cardioId == -1 {
                                try CardioDao.create(cardio: cardio)
                            } else {
                                try CardioDao.update(cardio: cardio)
                            }
                            dismiss()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
}


struct CardioTypePickerView: View {
    @Environment(\.dismiss) var dismiss
        
    @State var options: [IdentifiableLabel] = []
    
    @Binding var selection: IdentifiableLabel
    
    @State var filter: String = ""
    
    @State private var sheetIsActive: Bool = false
    
    @State private var deleteConfirmation: Bool = false
    
    private func loadOptions() {
        options = CardioTypeDao.getAll()
    }
    
    func createNewType(name: String) -> String? {
        do {
            try CardioTypeDao.create(type: IdentifiableLabel(name: name))
        } catch {
            return error.localizedDescription
        }
        return nil
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "magnifyingglass").opacity(0.3)
                    TextField("Filter", text: $filter)
                }
            }
            
            ForEach(options) { option in
                if filter == "" || option.name.lowercased().contains(filter.lowercased()) {
                    Button(option.name) {
                        selection = option
                        dismiss()
                    }
                }
            }
            .onDelete { indexSet in
                selection = options[indexSet.first!]
                deleteConfirmation = true
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Create") {
                    sheetIsActive = true
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
        }
        .onAppear { loadOptions() }
        .sheet(isPresented: $sheetIsActive) { loadOptions() } content: {
            IdentifiableLabelCreateView(isActive: $sheetIsActive, create: createNewType)
        }
        .alert("Confirm Delete", isPresented: $deleteConfirmation) {
            Button("Delete Cardio Type", role: .destructive) {
                do {
                    try CardioTypeDao.delete(id: selection.id)
                    print("deleted cardio type")
                    selection = IdentifiableLabel()
                    loadOptions()
                } catch {
                    print(error.localizedDescription)
                }
            }
        } message: {
            Text("Warning: Cardio Type will only be deleted if no workouts depend on it.")
        }
    }
}


struct IdentifiableLabelCreateView: View {
    
    @Binding var isActive: Bool
    var create: (String) -> String?
    @State var userInput: String = ""
    
    @State var errorMessage: String = ""
    
    var body: some View {
        VStack {
            TextField("Type Here", text: $userInput)
                .font(.title)
                .multilineTextAlignment(.center)
                .onSubmit {
                    errorMessage = ""
                    if let error: String = create(userInput) {
                        errorMessage = error
                    } else {
                        isActive = false
                    }
                    
                }
            Text(errorMessage).foregroundColor(Color(uiColor: .systemRed))
        }
        
    }
}
