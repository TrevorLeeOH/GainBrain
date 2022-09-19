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
    @State var value: Int64 = -1
    
    @State var selection: [IdentifiableLabel] = []
    
    
    var body: some SwiftUI.View {
        
        VStack {
            
            TextField("enter value", value: $value, format: .number)
            
            
            Button("test rounding") {
                print("\(1.23456) text")
                print("\(round(1.23456 * 100) / 100.0) text")
            }
            
            Text("\(1.23456) text")
            Text(String(round(1.23456 * 100) / 100.0))
            
            
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


struct dismissDebugView: View {
    
    
    var body: some View {
        
            NavigationLink(destination: Debuggeronie()) {
                Text("debuggerionie")
            }
        
        
        
        
        
        
    }
}


struct Debuggeronie: View {
    
    
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack {
            Button("Debug") {
                showAlert = true
            }

        }
        .alert("Are You Sure?", isPresented: $showAlert) {
            Button("Delete", role: .destructive) {
                print("deleted")
            }
        } message: {
            Text("Howdy doody")
        }
        
    }
}






struct TempViewWorkoutView: SwiftUI.View {
    
    @State var workouts: [WorkoutDTO] = []
    @State var selectedWorkout: WorkoutDTO?
    @State var editingWorkout: Bool = false
    
    private func doNothing(user: User) {
        
    }
    
    var body: some SwiftUI.View {
        Group {
            if let workout = selectedWorkout {
                NavigationLink(destination: WorkoutBuilderView(inSession: false, removeProfile: doNothing).environmentObject(workout).navigationBarTitleDisplayMode(.inline), isActive: $editingWorkout) {
                    EmptyView()
                }
            }
            
            List {
                ForEach(workouts, id: \.workoutId) { w in
                    Button {
                        selectedWorkout = w
                        editingWorkout = true
                    } label: {
                        WorkoutMinimalView(workout: w)
                        
                    }
                    
                    
                    
                }
                
            }
            .frame(height: 300)
            
            
            .onAppear {
                workouts = []
                let users = UserDao.getAll()
                for user in users {
                    let userWorkouts = WorkoutDao.getAllForUser(userId: user.userId)
                    workouts.append(contentsOf: userWorkouts)
                }
            }
        }
        
        
        
    }
}

