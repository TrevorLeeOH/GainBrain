//
//  Workout.swift
//  GainBrain
//
//  Created by Trevor Lee on 7/11/22.
//

import Foundation
import System

class WorkoutDTO: ObservableObject, Equatable {
    
    var workoutId: Int64
    var user: User
    var workoutType: IdentifiableLabel
    @Published var date: Date
    @Published var duration: TimeInterval
    @Published var caloriesBurned: Int?
    @Published var notes: String?
    @Published var weightlifting: [WeightliftingDTO]
    @Published var cardio: [CardioDTO]
    
    init(workoutId: Int64 = -1, user: User, workoutType: IdentifiableLabel, date: Date = Date.now, duration: TimeInterval = -1, caloriesBurned: Int? = nil, notes: String? = nil, weightlifting: [WeightliftingDTO] = [], cardio: [CardioDTO] = []) {
        self.workoutId = workoutId
        self.user = user
        self.workoutType = workoutType
        self.date = date
        self.duration = duration
        self.caloriesBurned = caloriesBurned
        self.notes = notes
        self.weightlifting = weightlifting
        self.cardio = cardio
    }
    
    static func == (lhs: WorkoutDTO, rhs: WorkoutDTO) -> Bool {
        return lhs.workoutId == rhs.workoutId
    }
    
    public func duplicate() -> WorkoutDTO {
        return WorkoutDTO(workoutId: workoutId, user: user, workoutType: workoutType, date: date, duration: duration, caloriesBurned: caloriesBurned, notes: notes, weightlifting: weightlifting, cardio: cardio)
    }
    
    public func toString() -> String {
        return "id: \(workoutId), user: \(user.name), type: \(workoutType.name), date: \(date.description), duration: \(TimeIntervalClass(timeInterval: duration).toString())"
    }
    
}

extension Double {
    func TimeIntervalDescription() -> String {
        var dur = self
        var hours: Int = 0
        var minutes: Int = 0
        var seconds: Int = 0

        while (dur >= 3600) {
            hours += 1
            dur -= 3600
        }
        while (dur >= 60) {
            minutes += 1
            dur -= 60
        }
        while (dur > 0) {
            seconds += 1
            dur -= 1
        }

        let hoursStr = hours > 0 ? String(hours) + " hrs, " : ""
        let minutesStr = minutes > 0 ? String(hours) + " min, " : ""
        let secondsStr = String(seconds) + " sec"

        return hoursStr + minutesStr + secondsStr;
    }
    
    
}



