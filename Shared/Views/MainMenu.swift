//
//  MainMenu.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/11/22.
//

import SwiftUI

struct MainMenu: View {
    
    @State var documentDirectory: String = "Document Directory Not Found"
        
    var body: some View {
        
        NavigationView {
            VStack {
                Text("Gain Brain")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                VStack(spacing: 32) {
                    
                    MainMenuItemView(view: AnyView(NavigationLink(destination: CreateWorkoutView().navigationTitle("Create New Workout")) {
                        Text("Start Workout")
                    }))
                    
                    MainMenuItemView(view: AnyView(NavigationLink(destination: WorkoutDaoView()) {
                        Text("View Workouts")
                    }))
                    
                    MainMenuItemView(view: AnyView(NavigationLink(destination: DebugView()) {
                        Text("Debug")
                    }))
                }
                .font(.title)
                
                
                Spacer()
                    
                ScrollView(Axis.Set.horizontal) {
                    Text(documentDirectory)
                        .padding()
                        .onAppear {
                            documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.path
                        }
                }
            }
        }
    }
}


struct MainMenuItemView: View {
    
    var view: AnyView
    
    var body: some View {
        view
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 30.0)
                    .foregroundColor(Color(UIColor.systemGray5))
            }
    }
}


struct DebugView: View {
    
    
    var body: some View {
        
        VStack {
            
            Button("Init Database") {
                Database.initializeDatabase()
            }
            
            
            Button("Print FilePath") {
                let documentDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                print(documentDirectory.path)
            }
            
            
        }
        
    }
    
}







