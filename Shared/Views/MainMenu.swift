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
                            Text("Log")
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
            
            
            
            NavigationLink(destination: CalendarDebugView(dayRange: Calendar.current.range(of: .day, in: .month, for: Date.now)!)) {
                Text("Calendar debug view")
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


struct CalendarDebugView: View {
    @State var currentDate: Date = Date.now
    @State var calendar: Calendar = Calendar(identifier: .gregorian)
    @State var workouts: [WorkoutDTO] = []
    var dayRange: Range<Int>
    @State var leadingSpace: Int = 0
    
    
    @State var dayBoxSize: CGFloat = 35.0
    
    @State var selectedMonth: Date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: Date.now)))!
    
    
    
    
    
    var body: some View {
        VStack {
            
            
            
            Button("Print info") {
                print(Calendar.current.firstWeekday)
                print(Calendar.current.minimumDaysInFirstWeek)
            }
            
            
            
            HStack {
                Button {
                    
                    let index = Calendar.current.component(.weekday, from: selectedMonth) // this returns an Int
                    leadingSpace = index - 1
                } label: {
                    Image(systemName: "arrow.left")
                }
                
                Text(Calendar.current.component(.month, from: selectedMonth).description)
                
                Button {
                    let index = Calendar.current.component(.weekday, from: selectedMonth) // this returns an Int
                    leadingSpace = index - 1
                } label: {
                    Image(systemName: "arrow.right")
                }
            }
            
            
            GeometryReader { geo in
                let size = geo.frame(in: .local).width / 7.0
                
                let columns: [GridItem] = Array(repeating: GridItem(.fixed(size), spacing: 0.0), count: 7)
                
                LazyVGrid(columns: columns, spacing: 0.0) {
                    
                    
                    ForEach(0..<7) { num in
                        Text(Calendar.current.weekdaySymbols[num].prefix(3))
                            .font(.system(size: size / 4.0))
                            .frame(width: size)
                    }
                    
                    ForEach(Array(repeating: true, count: leadingSpace).indices, id: \.self) { _ in
                        Text("")
                            .frame(width: size, height: size)
                            
                    }
                    
                    ForEach(dayRange) { num in
                        Text(String(num))
                            .font(.system(size: size / 2.0))
                            .frame(width: size, height: size)
                            .border(.blue)
                    }
                }
            }
            
            
            
        }
        .onAppear {
            workouts = WorkoutDao.getAllForUser(userId: 1)
            
            
            //Calendar.current.weekdaySymbols[index - 1] // subtract 1 since the index starts at 1
            
        }
        
    }
}


struct Debuggeronie: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var wls: [WeightliftingDTO] = []
    
    @State private var refresh: Bool = false
    
    
    var body: some View {
        List {
            ForEach(wls, id: \.weightliftingId) { wl in
                WeightliftingMinimalView(weightlifting: wl, refresh: $refresh)
            }
        }
        .onAppear {
            do {
                try wls = WeightliftingDao.getAllFiltered(userId: 1, weightliftingType: WeightliftingTypeDao.get(id: 1))
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}





