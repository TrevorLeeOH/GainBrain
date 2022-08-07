//
//  TextFileManager.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/16/22.
//

import Foundation
import SwiftUI


struct TextFileManager {
    
    static func getAll(at: URL) throws -> [String] {
        let result: String = try String(contentsOf: at)
        return result.components(separatedBy: .newlines)
    }
    
    static func getAll(at: URL) throws -> String {
        return try String(contentsOf: at)
    }
    
    static func create(at: URL, type: String) throws {
        var contents: String = try getAll(at: at)
        contents += "\n" + type
        try contents.write(to: at, atomically: true, encoding: .utf8)
    }
    
    static func setAll(at: URL, types: [String]) throws {
        let dataToWrite: String = types.joined(separator: "\n")
        try dataToWrite.write(to: at, atomically: true, encoding: .utf8)
    }
    
    static func delete(at: URL, entry: String) throws {
        var contents: [String] = try getAll(at: at)
        
        for index: Int in 0..<contents.count {
            if contents[index] == entry {
                contents.remove(at: index)
                try setAll(at: at, types: contents)
                print("successful deletion")
                break;
            }
        }
    }
}

struct TextFileCreateView: View {
    var prompt: String
    var url: URL
    @Binding var isActive: Bool
    @State var userInput: String = ""
    
    var body: some View {
        TextField(prompt, text: $userInput)
            .font(.title)
            .multilineTextAlignment(.center)
            .onSubmit {
                do {
                    try TextFileManager.create(at: url, type: userInput)
                    isActive = false
                } catch {
                    print(error.localizedDescription)
                }
            }
    }
}



struct TextFileMultiSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.editMode) var editMode
    
    var url: URL
    var creationPrompt: String
    
    @State var options: [String] = []
    
    @Binding var selection: [String]
    @State private var listSelection: Set<String> = Set<String>()
    
    @State private var sheetIsActive: Bool = false
    
    private func refresh() {
        do {
            options = try TextFileManager.getAll(at: url)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    var body: some View {
        List(selection: $listSelection) {
            ForEach(options, id: \.self) { option in
                Text(option)
            }
            .onMove { indexSet, index in
                options.move(fromOffsets: indexSet, toOffset: index)
                do {
                    try TextFileManager.setAll(at: url, types: options)
                } catch {
                    print(error.localizedDescription)
                }
                
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(creationPrompt) {
                    sheetIsActive = true
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Delete", role: .destructive) {
                    for option in options {
                        if listSelection.contains(option) {
                            do {
                                try TextFileManager.delete(at: url, entry: option)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    refresh()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    selection.removeAll()
                    for option in options {
                        if listSelection.contains(option) {
                            selection.append(option)
                        }
                    }
                    dismiss()
                }
            }
        }
        .onAppear { refresh() ; editMode?.wrappedValue = EditMode.active }
        .sheet(isPresented: $sheetIsActive) { refresh() } content: {
            TextFileCreateView(prompt: "Enter New Tag", url: url,  isActive: $sheetIsActive)
        }
    }
}

struct TextFilePickerView: View {
    @Environment(\.dismiss) var dismiss
    
    var url: URL
    var subject: String
    
    @State var options: [String] = []
    
    @Binding var selection: String
    
    @State private var sheetIsActive: Bool = false
    
    private func refresh() {
        do {
            options = try TextFileManager.getAll(at: url)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    var body: some View {
        List {
            ForEach(options, id: \.self) { option in
                Button(option) {
                    selection = option
                    dismiss()
                }
            }
            .onMove { indexSet, index in
                options.move(fromOffsets: indexSet, toOffset: index)
                do {
                    try TextFileManager.setAll(at: url, types: options)
                } catch {
                    print(error.localizedDescription)
                }
                
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    do {
                        try TextFileManager.delete(at: url, entry: options[index])
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                refresh()
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Create new " + subject) {
                    sheetIsActive = true
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
        }
        .onAppear { refresh() }
        .sheet(isPresented: $sheetIsActive) { refresh() } content: {
            TextFileCreateView(prompt: "Enter New " + subject, url: url,  isActive: $sheetIsActive)
        }
    }
}
