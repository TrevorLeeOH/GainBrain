//
//  CardioViews.swift
//  GainBrain
//
//  Created by Trevor Lee on 9/1/22.
//

import SwiftUI

struct CardioMinimalView: View {
    @ObservedObject var cardio: CardioDTO
    
    @Binding var refresh: Bool
    
    var body: some View {
        
        HStack {
            Text(cardio.cardioType.name)
            Spacer()
            
            if let duration = cardio.duration {
                VStack {
                    Text("dur.")
                    Text(TimeIntervalClass(timeInterval: duration).toShortString())
                        .font(.caption)
                }
            }
            if let distance = cardio.distance {
                VStack {
                    Text("dst.")
                    Text(Config.instance.metricDistances ? String(round(distance.milesToKilometers() * 10) / 10.0).prefix(5) + " km" : String(round(distance * 10) / 10.0).prefix(5) + " mi")
                        .font(.caption)
                }
            }
            if let speed = cardio.speed {
                VStack {
                    Text("spd.")
                    Text(Config.instance.metricDistances ? String(round(speed.milesToKilometers() * 10) / 10.0).prefix(5) + " km/h" : String(round(speed * 10) / 10.0).prefix(5) + " mph")
                        .font(.caption)
                }
            }
            if let resistance = cardio.resistance {
                VStack {
                    Text("res.")
                    Text(String(resistance).prefix(5))
                        .font(.caption)
                }
            }
            if let incline = cardio.incline {
                VStack {
                    Text("inc.")
                    Text(String(incline).prefix(5))
                        .font(.caption)
                }
            }
        }
    }
}

struct CardioDetailView: View {
    @ObservedObject var cardio: CardioDTO
    
    var body: some View {
        List {
            if let duration = cardio.duration {
                Text("Duration: " + String(duration))
            }
            if let distance = cardio.distance {
                Text(Config.instance.metricDistances ? "\(distance.milesToKilometers()) km" : "\(distance) mi")
            }
            if let speed = cardio.speed {
                Text(Config.instance.metricDistances ? "\(speed.milesToKilometers()) km/h" : "\(speed) mph")
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
    @EnvironmentObject var workout: WorkoutDTO
    
    @ObservedObject var cardio: CardioDTO
    
    @StateObject var timeInterval: TimeIntervalClass = TimeIntervalClass()
    @State var distance: Double?
    @State var speed: Double?
    
            
    var body: some View {
        Form {
            
            NavigationLink(destination: IdentifiableLabelPickerView(selection: $cardio.cardioType, getAllFunction: CardioTypeDao.getAll, createFunction: CardioTypeDao.create, deleteFunction: CardioTypeDao.delete, warning: "Type can only be deleted if no workouts depend on it")) {
                HStack {
                    Text("Cardio Type")
                    Spacer()
                    Text(cardio.cardioType.name)
                        .foregroundColor(Color(uiColor: UIColor.systemGray4))
                }
                
            }
            NavigationLink(destination: IdentifiableLabelMultiSelectionView(selection: $cardio.tags, getAllFunction: CardioTagDao.getAll, createFunction: CardioTagDao.create, deleteFunction: CardioTagDao.delete, warning: "Tag can only be deleted if no workouts depend on it")) {
                HStack(spacing: 0.0) {
                    Text("Cardio Tags")
                    Spacer()
                    ForEach(cardio.tags, id: \.id) { tag in
                        Text(" " + tag.name)
                            .foregroundColor(Color(uiColor: UIColor.systemGray4))
                            .font(.caption2)
                    }
                }
            }
            
            TimeIntervalPicker(timeInterval: timeInterval)
                .onAppear {
                    timeInterval.setTimeInterval(timeInterval: cardio.duration ?? 0)
                    distance = Config.instance.metricDistances ? cardio.distance?.milesToKilometers() : cardio.distance
                    speed = Config.instance.metricDistances ? cardio.speed?.milesToKilometers() : cardio.speed
                }
            
            TextField(Config.instance.metricDistances ? "Distance (kilometers)" : "Distance (miles)", value: $distance, format: .number)
            TextField(Config.instance.metricDistances ? "Speed (km/h)" : "Speed (mph)", value: $speed, format: .number)
            TextField("Resistance", value: $cardio.resistance, format: .number)
            TextField("Incline", value: $cardio.incline, format: .number)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if cardio.cardioType.id != -1 {
                    Button("Save Changes") {
                        cardio.duration = timeInterval.toTimeInterval() <= 0.0 ? nil : timeInterval.toTimeInterval()
                        cardio.distance = Config.instance.metricDistances ? distance?.kilometersToMiles() : distance
                        cardio.speed = Config.instance.metricDistances ? speed?.kilometersToMiles() : speed
                        do {
                            if cardio.cardioId == -1 {
                                let newC = try CardioDao.create(cardio: cardio)
                                workout.cardio.append(newC)
                                
                            } else {
                                try CardioDao.update(cardio: cardio)
                                for i in 0..<workout.cardio.count {
                                    if (workout.cardio[i].cardioId == cardio.cardioId) {
                                        workout.cardio[i] = cardio
                                        break
                                    }
                                }
                            }
                            dismiss()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            ToolbarItem(placement: .bottomBar) {
                if cardio.cardioId != -1 {
                    Button("Delete") {
                        do {
                            try CardioDao.delete(id: cardio.cardioId)
                            workout.cardio = workout.cardio.filter({ c in
                                c.cardioId != cardio.cardioId
                            })
                            dismiss()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    .foregroundColor(Color(uiColor: .systemRed))
                }
            }
        }
    }
}




