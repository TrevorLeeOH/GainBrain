//
//  MainMenu.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/11/22.
//

import SwiftUI
import SQLite

struct MainMenu: SwiftUI.View {
    
    @State var documentDirectory: String = "Document Directory Not Found"
        
    var body: some SwiftUI.View {
        
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
                    
                    MainMenuItemView(view: AnyView(NavigationLink(destination: EmptyView()) {
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


struct MainMenuItemView: SwiftUI.View {
    
    var view: AnyView
    
    var body: some SwiftUI.View {
        view
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 30.0)
                    .foregroundColor(Color(UIColor.systemGray5))
            }
    }
}


struct DebugView: SwiftUI.View {
    @State var value: Int64 = -1
    
    @State var selection: [IdentifiableLabel] = []
    
    var body: some SwiftUI.View {
        
        VStack {
            
            TextField("enter value", value: $value, format: .number)
            
            
            Button("Init Database") {
                Database.initializeDatabase()
            }
            .padding()
            
            Button("Print Cardios") {
                let cardios = CardioDao.debugGetAll()
                
                for c in cardios {
                    print("cardio id: \(c.cardioId), workout id: \(c.workoutId)")
                }
            }
            
            Button("Print Workouts") {
                let workouts = WorkoutDao.getAllForUser(userId: value)
                
                for w in workouts {
                    print(w.toString())
                }
                
            }
            .padding()
            
            Button("Delete ALL cardio") {
                do {
                    try CardioDao.debugDeleteAll()
                } catch {
                    print(error.localizedDescription)
                }
            }.padding()
            
            Button("DO VERY SPECIFIC THING") {
                
                do {
                    let db = try Database.getDatabase()
                    let targetRow = Table("workout").filter(Expression<Int64>("workout_id") == 1)
                    try db.run(targetRow.update(Expression<Int64>("workout_type_id") <- 1))
                    
                } catch {
                    print(error.localizedDescription)
                }
                
                
            }.padding()
                
                   
            
            Button("delete ALL workouts") {
                do {
                    try WorkoutDao.debugDeleteAll()
                } catch {
                    print(error.localizedDescription)
                }
                
            }.padding()
            
            
            Button("Print FilePath") {
                let documentDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                print(documentDirectory.path)
            }
            
            
        }
        
    }
    
}







