//
//  IdentifiableLabelViews.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/11/22.
//

import SwiftUI

struct IdentifiableLabelPickerView: View {
    @Environment(\.dismiss) var dismiss
        
    @State var options: [IdentifiableLabel] = []
    
    @Binding var selection: IdentifiableLabel
    
    @State var filter: String = ""
    
    @State private var sheetIsActive: Bool = false
    @State private var deleteConfirmation: Bool = false
    
    var getAllFunction: () -> [IdentifiableLabel]
    var createFunction: (IdentifiableLabel) throws -> Void
    var deleteFunction: (Int64) throws -> Void
    var warning: String
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "magnifyingglass").opacity(0.3)
                    TextField("Filter", text: $filter)
                }
            }

            ForEach(options, id: \.id) { option in
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
        .alert("Are You Sure?", isPresented: $deleteConfirmation) {
            Button("Delete", role: .destructive) {
                do {
                    try deleteFunction(selection.id)
                    print("deleted")
                    selection = IdentifiableLabel()
                    options = getAllFunction()
                } catch {
                    print(error.localizedDescription)
                }
            }
        } message: {
            Text(warning)
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
        .onAppear { options = getAllFunction() }
        .sheet(isPresented: $sheetIsActive) { options = getAllFunction() } content: {
            IdentifiableLabelCreateView(isActive: $sheetIsActive, create: createFunction)
        }
        
    }
}


struct IdentifiableLabelCreateView: View {
    
    @Binding var isActive: Bool
    var create: (IdentifiableLabel) throws -> Void
    @State var userInput: String = ""
    @State var errorMessage: String = ""
    
    var body: some View {
        VStack {
            TextField("Type Here", text: $userInput)
                .font(.title)
                .multilineTextAlignment(.center)
                .onSubmit {
                    do {
                        try create(IdentifiableLabel(name: userInput))
                        isActive = false
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                    
                }
            Text(errorMessage).foregroundColor(Color(uiColor: .systemRed))
        }
        
    }
}



struct IdentifiableLabelMultiSelectionView: View {
    @Environment(\.dismiss) var dismiss
        
    @State var options: [IdentifiableLabel] = []
    @Binding var selection: [IdentifiableLabel]
    @State private var filter: String = ""
    @State private var sheetIsActive: Bool = false
    @State private var deleteConfirmation: Bool = false
    
    var getAllFunction: () -> [IdentifiableLabel]
    var createFunction: (IdentifiableLabel) throws -> Void
    var deleteFunction: (Int64) throws -> Void
    var warning: String
    
    
    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "magnifyingglass").opacity(0.3)
                    TextField("Filter", text: $filter)
                }
            }
            ForEach(options, id: \.id) { option in
                if filter == "" || option.name.lowercased().contains(filter.lowercased()) {
                    HStack {
                        Image(systemName: selection.contains(option) ? "checkmark.circle.fill" : "circle")
                            .renderingMode(.original)
                            .foregroundColor(selection.contains(option) ? .accentColor : Color(uiColor: .systemGray4))
                        Button(option.name) {
                            if selection.contains(option) {
                                selection = selection.filter({ o in
                                    o != option
                                })
                            } else {
                                selection.append(option)
                            }
                        }
                    }
                    .listRowBackground(selection.contains(option) ? Color(uiColor: .systemGray4) : nil)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                if selection.count > 0 {
                    Button("Delete") {
                        deleteConfirmation = true
                    }
                    .foregroundColor(Color(uiColor: .systemRed))
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Create") {
                    sheetIsActive = true
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onAppear { options = getAllFunction() }
        .sheet(isPresented: $sheetIsActive) { options = getAllFunction() } content: {
            IdentifiableLabelCreateView(isActive: $sheetIsActive, create: createFunction)
        }
        .alert("Are You Sure?", isPresented: $deleteConfirmation) {
            Button("Delete", role: .destructive) {
                for index in 0..<selection.count {
                    do {
                        try deleteFunction(selection[index].id)
                        selection.remove(at: index)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                options = getAllFunction()
            }
        } message: {
            Text(warning)
        }
    }
}
