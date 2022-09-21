//
//  MainMenu.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/11/22.
//

import SwiftUI

struct MainMenu: SwiftUI.View {
    @Environment(\.dismiss) var dismiss
    
    @State var documentDirectory: String = "Document Directory Not Found"
    
    @State var sessionExists: Bool = false
    @State var navSwitch: String?
    
    @State private var session: Session = Session(workouts: [])
            
    var body: some SwiftUI.View {
        
        NavigationView {
            VStack {
                NavigationLink(destination: WorkoutViewMaster(session: session).navigationBarBackButtonHidden(true), tag: "CREATE_WORKOUT", selection: $navSwitch) {EmptyView()}
                
                
                
                Text("Gain Brain")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                VStack(spacing: 32) {
                    
                    if sessionExists {
                        MainMenuItemView(view: AnyView(Button("Resume Workout") { navSwitch = "CREATE_WORKOUT" }))
                    } else {
                        MainMenuItemView(view: AnyView(NavigationLink(destination: CreateWorkoutView(parentNavSwitch: $navSwitch).navigationTitle("Create New Workout")) {
                            Text("Start Workout")
                        }))
                    }
                    
                    
                    MainMenuItemView(view: AnyView(
                        NavigationLink(destination: WorkoutLogProfilePickerView().navigationTitle("Select Profile"), label: {
                            Text("View Workouts")
                        })
                    ))
                    
                    MainMenuItemView(view: AnyView(NavigationLink(destination: SettingsView()) {
                        Text("Settings")
                    }))
                    
                    MainMenuItemView(view: AnyView(NavigationLink(destination: DebugView()) {
                        Text("Debug")
                    }))

                }
                .font(.title)
                Spacer()
            }
            .onAppear {
                print("Appeared")
                sessionExists = SessionDao.sessionExists()
                if sessionExists {
                    do {
                        session = try SessionDao.getSession()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
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
    
    var body: some SwiftUI.View {
        
        VStack {
            
            
            
            NavigationLink(destination: DismissDebugView()) {
                Text("Dismiss debug view")
            }
            
            
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
                let workouts = WorkoutDao.getAllForUser(userId: 1)
                
                for w in workouts {
                    print(w.toString())
                }
                
            }
            .padding()
            
                   
            
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


struct DismissDebugView: View {
    
    var body: some View {
        VStack {
            Text("DismissDebugView")
                .font(.largeTitle)
            NavigationLink(destination: Debuggeronie()) {
                Text("debuggerionie")
            }
        }
        
    }
}


struct Debuggeronie: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var showAlert: Bool = false
    
    
    var body: some View {
        VStack {
            Text("Dubuggeronie")
                .font(.largeTitle)
            Button("dismiss view") {
                UINavigationBar.setAnimationsEnabled(false)
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    UINavigationBar.setAnimationsEnabled(true)
                }
                
            }

        }
        
    }
}





