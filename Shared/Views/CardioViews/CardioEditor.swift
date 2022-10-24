//
//  CardioEditor.swift
//  GainBrain
//
//  Created by Trevor Lee on 10/24/22.
//

import SwiftUI

struct CardioEditor: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var workout: WorkoutDTO
    
    @ObservedObject var cardio: CardioDTO
    
    @State var timeInterval: TimeIntervalClass = TimeIntervalClass()
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
            
            TimeIntervalPicker(timeInterval: $timeInterval)
                .onAppear {
                    timeInterval = TimeIntervalClass(timeInterval: cardio.duration ?? 0.0)
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
